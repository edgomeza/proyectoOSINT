import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entity_node.dart';
import '../models/relationship.dart';
import 'graph_provider.dart';

/// Helper function to convert Color to int without deprecated value property
int _colorToInt(Color color) {
  return (color.a * 255).round() << 24 |
      (color.r * 255).round() << 16 |
      (color.g * 255).round() << 8 |
      (color.b * 255).round();
}

/// Canvas Node Model - Maps diagram components to EntityNodes
class CanvasNode {
  final String id;
  final String componentId; // ID del componente en diagram_editor
  final String entityNodeId; // ID del EntityNode en el grafo
  final String nodeType; // Tipo del nodo como string
  final String label;
  final Color color;
  final Offset position;
  final Size size;

  CanvasNode({
    required this.id,
    required this.componentId,
    required this.entityNodeId,
    required this.nodeType,
    required this.label,
    required this.color,
    required this.position,
    required this.size,
  });

  CanvasNode copyWith({
    String? label,
    Color? color,
    Offset? position,
    Size? size,
  }) {
    return CanvasNode(
      id: id,
      componentId: componentId,
      entityNodeId: entityNodeId,
      nodeType: nodeType,
      label: label ?? this.label,
      color: color ?? this.color,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'componentId': componentId,
      'entityNodeId': entityNodeId,
      'nodeType': nodeType,
      'label': label,
      'color': _colorToInt(color),
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': {'width': size.width, 'height': size.height},
    };
  }

  factory CanvasNode.fromJson(Map<String, dynamic> json) {
    return CanvasNode(
      id: json['id'],
      componentId: json['componentId'],
      entityNodeId: json['entityNodeId'],
      nodeType: json['nodeType'],
      label: json['label'],
      color: Color(json['color']),
      position: Offset(
        json['position']['dx'],
        json['position']['dy'],
      ),
      size: Size(
        json['size']['width'],
        json['size']['height'],
      ),
    );
  }
}

/// Canvas Connection Model - Represents links between nodes
class CanvasConnection {
  final String id;
  final String linkId; // ID del link en diagram_editor
  final String relationshipId; // ID del Relationship en el grafo
  final String sourceNodeId;
  final String targetNodeId;
  final String? label;

  CanvasConnection({
    required this.id,
    required this.linkId,
    required this.relationshipId,
    required this.sourceNodeId,
    required this.targetNodeId,
    this.label,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linkId': linkId,
      'relationshipId': relationshipId,
      'sourceNodeId': sourceNodeId,
      'targetNodeId': targetNodeId,
      'label': label,
    };
  }

  factory CanvasConnection.fromJson(Map<String, dynamic> json) {
    return CanvasConnection(
      id: json['id'],
      linkId: json['linkId'],
      relationshipId: json['relationshipId'],
      sourceNodeId: json['sourceNodeId'],
      targetNodeId: json['targetNodeId'],
      label: json['label'],
    );
  }
}

/// Canvas State
class CanvasState {
  final String? investigationId;
  final Map<String, CanvasNode> nodes;
  final Map<String, CanvasConnection> connections;
  final String? selectedNodeId;
  final String? linkingFromNodeId; // For connection mode
  final bool isModified;

  CanvasState({
    this.investigationId,
    this.nodes = const {},
    this.connections = const {},
    this.selectedNodeId,
    this.linkingFromNodeId,
    this.isModified = false,
  });

  CanvasState copyWith({
    String? investigationId,
    Map<String, CanvasNode>? nodes,
    Map<String, CanvasConnection>? connections,
    String? selectedNodeId,
    String? linkingFromNodeId,
    bool? isModified,
  }) {
    return CanvasState(
      investigationId: investigationId ?? this.investigationId,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      selectedNodeId: selectedNodeId,
      linkingFromNodeId: linkingFromNodeId,
      isModified: isModified ?? this.isModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investigationId': investigationId,
      'nodes': nodes.map((key, value) => MapEntry(key, value.toJson())),
      'connections': connections.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory CanvasState.fromJson(Map<String, dynamic> json) {
    return CanvasState(
      investigationId: json['investigationId'],
      nodes: (json['nodes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CanvasNode.fromJson(value)),
      ),
      connections: (json['connections'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CanvasConnection.fromJson(value)),
      ),
    );
  }
}

/// Canvas State Notifier
class CanvasNotifier extends StateNotifier<CanvasState> {
  final Ref ref;

  CanvasNotifier(this.ref) : super(CanvasState());

  /// Set investigation context
  void setInvestigation(String investigationId) {
    state = state.copyWith(investigationId: investigationId);
  }

  /// Add a node to the canvas
  String addNode({
    required String componentId,
    required String nodeType,
    required String label,
    required Color color,
    required Offset position,
    required Size size,
    EntityNodeType? entityType,
  }) {
    // Create EntityNode in graph
    final entityNode = EntityNode(
      label: label,
      type: entityType ?? _mapNodeTypeToEntityType(nodeType),
      x: position.dx,
      y: position.dy,
      attributes: {
        'investigationId': state.investigationId,
        'canvasType': nodeType,
        'color': _colorToInt(color),
      },
    );

    // Add to graph provider
    ref.read(entityNodesProvider.notifier).addNode(entityNode);

    // Create canvas node
    final canvasNode = CanvasNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      componentId: componentId,
      entityNodeId: entityNode.id,
      nodeType: nodeType,
      label: label,
      color: color,
      position: position,
      size: size,
    );

    // Add to canvas state
    final newNodes = Map<String, CanvasNode>.from(state.nodes);
    newNodes[canvasNode.id] = canvasNode;

    state = state.copyWith(nodes: newNodes, isModified: true);

    return canvasNode.id;
  }

  /// Update node
  void updateNode(String nodeId, {
    String? label,
    Color? color,
    Offset? position,
  }) {
    final node = state.nodes[nodeId];
    if (node == null) return;

    // Update canvas node
    final updatedNode = node.copyWith(
      label: label,
      color: color,
      position: position,
    );

    final newNodes = Map<String, CanvasNode>.from(state.nodes);
    newNodes[nodeId] = updatedNode;

    // Update entity node in graph
    final entityNode = ref.read(entityNodesProvider.notifier).getNodeById(node.entityNodeId);
    if (entityNode != null) {
      ref.read(entityNodesProvider.notifier).updateNode(
        entityNode.copyWith(
          label: label,
          x: position?.dx,
          y: position?.dy,
          attributes: {
            ...entityNode.attributes,
            if (color != null) 'color': _colorToInt(color),
          },
        ),
      );
    }

    state = state.copyWith(nodes: newNodes, isModified: true);
  }

  /// Remove node and its connections
  void removeNode(String nodeId) {
    final node = state.nodes[nodeId];
    if (node == null) return;

    // Remove from graph
    ref.read(entityNodesProvider.notifier).removeNode(node.entityNodeId);
    ref.read(relationshipsProvider.notifier).removeRelationshipsForNode(node.entityNodeId);

    // Remove connections from canvas
    final newConnections = Map<String, CanvasConnection>.from(state.connections);
    newConnections.removeWhere((key, conn) =>
        conn.sourceNodeId == nodeId || conn.targetNodeId == nodeId);

    // Remove node from canvas
    final newNodes = Map<String, CanvasNode>.from(state.nodes);
    newNodes.remove(nodeId);

    state = state.copyWith(
      nodes: newNodes,
      connections: newConnections,
      isModified: true,
    );
  }

  /// Add connection between nodes
  String? addConnection({
    required String linkId,
    required String sourceNodeId,
    required String targetNodeId,
    String? label,
    RelationshipType? relationshipType,
  }) {
    final sourceNode = state.nodes[sourceNodeId];
    final targetNode = state.nodes[targetNodeId];

    if (sourceNode == null || targetNode == null) return null;

    // Create relationship in graph
    final relationship = Relationship(
      sourceNodeId: sourceNode.entityNodeId,
      targetNodeId: targetNode.entityNodeId,
      type: relationshipType ?? RelationshipType.linked,
      label: label ?? 'connected',
      attributes: {
        'investigationId': state.investigationId,
      },
    );

    ref.read(relationshipsProvider.notifier).addRelationship(relationship);

    // Create canvas connection
    final connection = CanvasConnection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      linkId: linkId,
      relationshipId: relationship.id,
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      label: label,
    );

    final newConnections = Map<String, CanvasConnection>.from(state.connections);
    newConnections[connection.id] = connection;

    state = state.copyWith(connections: newConnections, isModified: true);

    return connection.id;
  }

  /// Remove connection
  void removeConnection(String connectionId) {
    final connection = state.connections[connectionId];
    if (connection == null) return;

    // Remove from graph
    ref.read(relationshipsProvider.notifier).removeRelationship(connection.relationshipId);

    // Remove from canvas
    final newConnections = Map<String, CanvasConnection>.from(state.connections);
    newConnections.remove(connectionId);

    state = state.copyWith(connections: newConnections, isModified: true);
  }

  /// Select node
  void selectNode(String? nodeId) {
    state = state.copyWith(selectedNodeId: nodeId);
  }

  /// Start linking mode
  void startLinking(String nodeId) {
    state = state.copyWith(linkingFromNodeId: nodeId);
  }

  /// Complete linking
  void completeLinking(String targetNodeId, String linkId) {
    if (state.linkingFromNodeId == null) return;

    addConnection(
      linkId: linkId,
      sourceNodeId: state.linkingFromNodeId!,
      targetNodeId: targetNodeId,
    );

    state = state.copyWith(linkingFromNodeId: null);
  }

  /// Cancel linking
  void cancelLinking() {
    state = state.copyWith(linkingFromNodeId: null);
  }

  /// Clear all canvas
  void clearCanvas() {
    // Remove all from graph
    for (final node in state.nodes.values) {
      ref.read(entityNodesProvider.notifier).removeNode(node.entityNodeId);
    }
    for (final conn in state.connections.values) {
      ref.read(relationshipsProvider.notifier).removeRelationship(conn.relationshipId);
    }

    state = CanvasState(investigationId: state.investigationId);
  }

  /// Load canvas from graph
  void loadFromGraph(String investigationId) {
    // Get nodes and relationships from graph
    final nodes = ref.read(nodesByInvestigationProvider(investigationId));
    final relationships = ref.read(relationshipsByInvestigationProvider(investigationId));

    final Map<String, CanvasNode> canvasNodes = {};
    final Map<String, CanvasConnection> canvasConnections = {};

    // Convert EntityNodes to CanvasNodes
    for (final node in nodes) {
      if (node.attributes['canvasType'] != null) {
        final canvasNode = CanvasNode(
          id: node.id,
          componentId: node.id, // Use same ID
          entityNodeId: node.id,
          nodeType: node.attributes['canvasType'],
          label: node.label,
          color: Color(node.attributes['color'] ?? _colorToInt(Colors.blue)),
          position: Offset(node.x ?? 0, node.y ?? 0),
          size: const Size(120, 60), // Default size
        );
        canvasNodes[canvasNode.id] = canvasNode;
      }
    }

    // Convert Relationships to CanvasConnections
    for (final rel in relationships) {
      final connection = CanvasConnection(
        id: rel.id,
        linkId: rel.id,
        relationshipId: rel.id,
        sourceNodeId: rel.sourceNodeId,
        targetNodeId: rel.targetNodeId,
        label: rel.label,
      );
      canvasConnections[connection.id] = connection;
    }

    state = CanvasState(
      investigationId: investigationId,
      nodes: canvasNodes,
      connections: canvasConnections,
    );
  }

  /// Mark as saved
  void markAsSaved() {
    state = state.copyWith(isModified: false);
  }

  /// Helper: Map nodeType string to EntityNodeType
  EntityNodeType _mapNodeTypeToEntityType(String nodeType) {
    switch (nodeType) {
      case 'rectangle':
        return EntityNodeType.other;
      case 'circle':
        return EntityNodeType.event;
      case 'diamond':
        return EntityNodeType.other;
      case 'text':
        return EntityNodeType.document;
      default:
        return EntityNodeType.other;
    }
  }

  /// Get node by component ID
  CanvasNode? getNodeByComponentId(String componentId) {
    try {
      return state.nodes.values.firstWhere(
        (node) => node.componentId == componentId,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Canvas Provider
final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier(ref);
});
