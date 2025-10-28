import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entity_node.dart';
import '../models/relationship.dart';

/// State Notifier for managing entity nodes in the graph
class EntityNodesNotifier extends StateNotifier<List<EntityNode>> {
  EntityNodesNotifier() : super([]);

  void addNode(EntityNode node) {
    state = [...state, node];
  }

  void updateNode(EntityNode updatedNode) {
    state = [
      for (final node in state)
        if (node.id == updatedNode.id) updatedNode else node,
    ];
  }

  void removeNode(String nodeId) {
    state = state.where((node) => node.id != nodeId).toList();
  }

  void clearNodes() {
    state = [];
  }

  EntityNode? getNodeById(String id) {
    try {
      return state.firstWhere((node) => node.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EntityNode> getNodesByType(EntityNodeType type) {
    return state.where((node) => node.type == type).toList();
  }

  List<EntityNode> getNodesByRiskLevel(RiskLevel riskLevel) {
    return state.where((node) => node.riskLevel == riskLevel).toList();
  }

  List<EntityNode> searchNodes(String query) {
    final lowerQuery = query.toLowerCase();
    return state.where((node) {
      return node.label.toLowerCase().contains(lowerQuery) ||
          (node.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          node.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}

/// State Notifier for managing relationships in the graph
class RelationshipsNotifier extends StateNotifier<List<Relationship>> {
  RelationshipsNotifier() : super([]);

  void addRelationship(Relationship relationship) {
    state = [...state, relationship];
  }

  void updateRelationship(Relationship updatedRelationship) {
    state = [
      for (final rel in state)
        if (rel.id == updatedRelationship.id) updatedRelationship else rel,
    ];
  }

  void removeRelationship(String relationshipId) {
    state = state.where((rel) => rel.id != relationshipId).toList();
  }

  void clearRelationships() {
    state = [];
  }

  Relationship? getRelationshipById(String id) {
    try {
      return state.firstWhere((rel) => rel.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Relationship> getRelationshipsForNode(String nodeId) {
    return state.where((rel) {
      return rel.sourceNodeId == nodeId || rel.targetNodeId == nodeId;
    }).toList();
  }

  List<Relationship> getRelationshipsByType(RelationshipType type) {
    return state.where((rel) => rel.type == type).toList();
  }

  /// Get all nodes connected to a specific node
  List<String> getConnectedNodeIds(String nodeId) {
    final connectedIds = <String>{};
    for (final rel in state) {
      if (rel.sourceNodeId == nodeId) {
        connectedIds.add(rel.targetNodeId);
      }
      if (rel.targetNodeId == nodeId && !rel.isDirected) {
        connectedIds.add(rel.sourceNodeId);
      }
    }
    return connectedIds.toList();
  }

  /// Remove all relationships connected to a specific node
  void removeRelationshipsForNode(String nodeId) {
    state = state.where((rel) {
      return rel.sourceNodeId != nodeId && rel.targetNodeId != nodeId;
    }).toList();
  }
}

/// Provider for entity nodes
final entityNodesProvider =
    StateNotifierProvider<EntityNodesNotifier, List<EntityNode>>((ref) {
  return EntityNodesNotifier();
});

/// Provider for relationships
final relationshipsProvider =
    StateNotifierProvider<RelationshipsNotifier, List<Relationship>>((ref) {
  return RelationshipsNotifier();
});

/// Derived provider: Get nodes by investigation ID
final nodesByInvestigationProvider =
    Provider.family<List<EntityNode>, String>((ref, investigationId) {
  final nodes = ref.watch(entityNodesProvider);
  return nodes
      .where((node) =>
          node.attributes['investigationId'] == investigationId)
      .toList();
});

/// Derived provider: Get relationships by investigation ID
final relationshipsByInvestigationProvider =
    Provider.family<List<Relationship>, String>((ref, investigationId) {
  final relationships = ref.watch(relationshipsProvider);
  return relationships
      .where((rel) =>
          rel.attributes['investigationId'] == investigationId)
      .toList();
});

/// Derived provider: Get high-risk nodes
final highRiskNodesProvider = Provider<List<EntityNode>>((ref) {
  final nodes = ref.watch(entityNodesProvider);
  return nodes
      .where((node) =>
          node.riskLevel == RiskLevel.high ||
          node.riskLevel == RiskLevel.critical)
      .toList();
});

/// Derived provider: Graph statistics
final graphStatsProvider = Provider<GraphStats>((ref) {
  final nodes = ref.watch(entityNodesProvider);
  final relationships = ref.watch(relationshipsProvider);

  return GraphStats(
    totalNodes: nodes.length,
    totalRelationships: relationships.length,
    nodesByType: _countByType(nodes),
    relationshipsByType: _countByRelationType(relationships),
  );
});

Map<EntityNodeType, int> _countByType(List<EntityNode> nodes) {
  final counts = <EntityNodeType, int>{};
  for (final node in nodes) {
    counts[node.type] = (counts[node.type] ?? 0) + 1;
  }
  return counts;
}

Map<RelationshipType, int> _countByRelationType(List<Relationship> relationships) {
  final counts = <RelationshipType, int>{};
  for (final rel in relationships) {
    counts[rel.type] = (counts[rel.type] ?? 0) + 1;
  }
  return counts;
}

class GraphStats {
  final int totalNodes;
  final int totalRelationships;
  final Map<EntityNodeType, int> nodesByType;
  final Map<RelationshipType, int> relationshipsByType;

  GraphStats({
    required this.totalNodes,
    required this.totalRelationships,
    required this.nodesByType,
    required this.relationshipsByType,
  });
}
