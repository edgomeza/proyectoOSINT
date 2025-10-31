import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entity_node.dart';
import '../models/relationship.dart';
import '../services/elasticsearch_service.dart';
import '../services/logstash_service.dart';

/// State Notifier for managing entity nodes in the graph
class EntityNodesNotifier extends StateNotifier<List<EntityNode>> {
  final ElasticsearchService _elasticsearchService;
  final LogstashService _logstashService;
  static const String _nodesIndex = 'osint-entity-nodes';

  EntityNodesNotifier(this._elasticsearchService, this._logstashService) : super([]) {
    _loadFromElasticsearch();
  }

  /// Load all nodes from Elasticsearch
  Future<void> _loadFromElasticsearch() async {
    try {
      final result = await _elasticsearchService.search(
        _nodesIndex,
        size: 10000,
      );

      if (result.documents.isNotEmpty) {
        final nodes = result.documents
            .map((doc) => EntityNode.fromJson(doc.data))
            .toList();
        state = nodes;
      }
    } catch (e) {
      // If index doesn't exist or error occurs, start with empty state
      state = [];
    }
  }

  Future<void> addNode(EntityNode node) async {
    state = [...state, node];

    // Persist to Elasticsearch
    await _elasticsearchService.indexDocument(
      _nodesIndex,
      node.toJson(),
      documentId: node.id,
    );

    // Log to Logstash
    await _logstashService.sendEvent(
      investigationId: node.attributes['investigationId']?.toString() ?? 'unknown',
      phase: 'analysis',
      eventType: 'node_created',
      data: node.toJson(),
    );
  }

  Future<void> updateNode(EntityNode updatedNode) async {
    state = [
      for (final node in state)
        if (node.id == updatedNode.id) updatedNode else node,
    ];

    // Update in Elasticsearch
    await _elasticsearchService.indexDocument(
      _nodesIndex,
      updatedNode.toJson(),
      documentId: updatedNode.id,
    );

    // Log to Logstash
    await _logstashService.sendEvent(
      investigationId: updatedNode.attributes['investigationId']?.toString() ?? 'unknown',
      phase: 'analysis',
      eventType: 'node_updated',
      data: updatedNode.toJson(),
    );
  }

  Future<void> removeNode(String nodeId) async {
    final node = getNodeById(nodeId);
    state = state.where((node) => node.id != nodeId).toList();

    // Delete from Elasticsearch
    await _elasticsearchService.deleteDocument(_nodesIndex, nodeId);

    // Log to Logstash
    if (node != null) {
      await _logstashService.sendEvent(
        investigationId: node.attributes['investigationId']?.toString() ?? 'unknown',
        phase: 'analysis',
        eventType: 'node_deleted',
        data: {'nodeId': nodeId, 'nodeLabel': node.label},
      );
    }
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
  final ElasticsearchService _elasticsearchService;
  final LogstashService _logstashService;
  static const String _relationshipsIndex = 'osint-relationships';

  RelationshipsNotifier(this._elasticsearchService, this._logstashService) : super([]) {
    _loadFromElasticsearch();
  }

  /// Load all relationships from Elasticsearch
  Future<void> _loadFromElasticsearch() async {
    try {
      final result = await _elasticsearchService.search(
        _relationshipsIndex,
        size: 10000,
      );

      if (result.documents.isNotEmpty) {
        final relationships = result.documents
            .map((doc) => Relationship.fromJson(doc.data))
            .toList();
        state = relationships;
      }
    } catch (e) {
      // If index doesn't exist or error occurs, start with empty state
      state = [];
    }
  }

  Future<void> addRelationship(Relationship relationship) async {
    state = [...state, relationship];

    // Persist to Elasticsearch
    await _elasticsearchService.indexDocument(
      _relationshipsIndex,
      relationship.toJson(),
      documentId: relationship.id,
    );

    // Log to Logstash
    await _logstashService.sendEvent(
      investigationId: relationship.attributes['investigationId']?.toString() ?? 'unknown',
      phase: 'analysis',
      eventType: 'relationship_created',
      data: relationship.toJson(),
    );
  }

  Future<void> updateRelationship(Relationship updatedRelationship) async {
    state = [
      for (final rel in state)
        if (rel.id == updatedRelationship.id) updatedRelationship else rel,
    ];

    // Update in Elasticsearch
    await _elasticsearchService.indexDocument(
      _relationshipsIndex,
      updatedRelationship.toJson(),
      documentId: updatedRelationship.id,
    );

    // Log to Logstash
    await _logstashService.sendEvent(
      investigationId: updatedRelationship.attributes['investigationId']?.toString() ?? 'unknown',
      phase: 'analysis',
      eventType: 'relationship_updated',
      data: updatedRelationship.toJson(),
    );
  }

  Future<void> removeRelationship(String relationshipId) async {
    final relationship = getRelationshipById(relationshipId);
    state = state.where((rel) => rel.id != relationshipId).toList();

    // Delete from Elasticsearch
    await _elasticsearchService.deleteDocument(_relationshipsIndex, relationshipId);

    // Log to Logstash
    if (relationship != null) {
      await _logstashService.sendEvent(
        investigationId: relationship.attributes['investigationId']?.toString() ?? 'unknown',
        phase: 'analysis',
        eventType: 'relationship_deleted',
        data: {'relationshipId': relationshipId, 'type': relationship.type.name},
      );
    }
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
  return EntityNodesNotifier(
    ElasticsearchService(),
    LogstashService(),
  );
});

/// Provider for relationships
final relationshipsProvider =
    StateNotifierProvider<RelationshipsNotifier, List<Relationship>>((ref) {
  return RelationshipsNotifier(
    ElasticsearchService(),
    LogstashService(),
  );
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
