import 'dart:collection';
import '../models/entity_node.dart';
import '../models/relationship.dart';

/// Service for performing graph analysis operations
class GraphAnalysisService {
  /// Find the shortest path between two nodes using Dijkstra's algorithm
  static List<EntityNode>? findShortestPath(
    EntityNode start,
    EntityNode end,
    List<EntityNode> allNodes,
    List<Relationship> allRelationships,
  ) {
    // Build adjacency map
    final adjacency = _buildAdjacencyMap(allNodes, allRelationships);

    // Dijkstra's algorithm
    final distances = <String, double>{};
    final previous = <String, EntityNode>{};
    final unvisited = <String>{};

    for (final node in allNodes) {
      distances[node.id] = double.infinity;
      unvisited.add(node.id);
    }
    distances[start.id] = 0;

    while (unvisited.isNotEmpty) {
      // Find node with minimum distance
      String? current;
      double minDistance = double.infinity;

      for (final nodeId in unvisited) {
        if (distances[nodeId]! < minDistance) {
          minDistance = distances[nodeId]!;
          current = nodeId;
        }
      }

      if (current == null || current == end.id) break;
      unvisited.remove(current);

      // Check neighbors
      final neighbors = adjacency[current] ?? {};
      for (final entry in neighbors.entries) {
        final neighbor = entry.key;
        final weight = entry.value;

        if (unvisited.contains(neighbor)) {
          final alt = distances[current]! + weight;
          if (alt < distances[neighbor]!) {
            distances[neighbor] = alt;
            previous[neighbor] = allNodes.firstWhere((n) => n.id == current);
          }
        }
      }
    }

    // Reconstruct path
    if (!previous.containsKey(end.id) && start.id != end.id) {
      return null; // No path found
    }

    final path = <EntityNode>[];
    EntityNode? current = end;

    while (current != null) {
      path.insert(0, current);
      if (current.id == start.id) break;
      current = previous[current.id];
    }

    return path.isEmpty || path.first.id != start.id ? null : path;
  }

  /// Find all nodes within N degrees of separation from a starting node
  static List<EntityNode> findNodesWithinDegrees(
    EntityNode start,
    int degrees,
    List<EntityNode> allNodes,
    List<Relationship> allRelationships,
  ) {
    final adjacency = _buildAdjacencyMap(allNodes, allRelationships);
    final visited = <String>{};
    final result = <EntityNode>[];
    final queue = Queue<({EntityNode node, int depth})>();

    queue.add((node: start, depth: 0));
    visited.add(start.id);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.depth <= degrees) {
        result.add(current.node);

        if (current.depth < degrees) {
          final neighbors = adjacency[current.node.id] ?? {};
          for (final neighborId in neighbors.keys) {
            if (!visited.contains(neighborId)) {
              visited.add(neighborId);
              final neighbor = allNodes.firstWhere((n) => n.id == neighborId);
              queue.add((node: neighbor, depth: current.depth + 1));
            }
          }
        }
      }
    }

    return result;
  }

  /// Find central nodes (nodes with highest degree centrality)
  static List<({EntityNode node, int connections})> findCentralNodes(
    List<EntityNode> allNodes,
    List<Relationship> allRelationships, {
    int topN = 10,
  }) {
    final connectionCounts = <String, int>{};

    for (final node in allNodes) {
      connectionCounts[node.id] = 0;
    }

    for (final relationship in allRelationships) {
      connectionCounts[relationship.sourceNodeId] =
          (connectionCounts[relationship.sourceNodeId] ?? 0) + 1;
      if (!relationship.isDirected) {
        connectionCounts[relationship.targetNodeId] =
            (connectionCounts[relationship.targetNodeId] ?? 0) + 1;
      }
    }

    final results = allNodes.map((node) {
      return (node: node, connections: connectionCounts[node.id] ?? 0);
    }).toList();

    results.sort((a, b) => b.connections.compareTo(a.connections));

    return results.take(topN).toList();
  }

  /// Find connected components (isolated subgraphs)
  static List<List<EntityNode>> findConnectedComponents(
    List<EntityNode> allNodes,
    List<Relationship> allRelationships,
  ) {
    final adjacency = _buildAdjacencyMap(allNodes, allRelationships);
    final visited = <String>{};
    final components = <List<EntityNode>>[];

    for (final node in allNodes) {
      if (!visited.contains(node.id)) {
        final component = <EntityNode>[];
        _dfs(node.id, adjacency, visited, component, allNodes);
        components.add(component);
      }
    }

    return components;
  }

  /// Search nodes by complex attributes
  static List<EntityNode> searchByAttributes(
    List<EntityNode> allNodes,
    Map<String, dynamic> searchCriteria,
  ) {
    return allNodes.where((node) {
      for (final entry in searchCriteria.entries) {
        final key = entry.key;
        final value = entry.value;

        // Check in main properties
        if (key == 'type' && node.type.name != value) {
          return false;
        }
        if (key == 'riskLevel' && node.riskLevel.name != value) {
          return false;
        }
        if (key == 'minConfidence' && node.confidence < (value as double)) {
          return false;
        }

        // Check in attributes
        if (node.attributes.containsKey(key)) {
          final nodeValue = node.attributes[key];
          if (value is String) {
            if (!nodeValue.toString().toLowerCase().contains(
                  value.toLowerCase(),
                )) {
              return false;
            }
          } else if (nodeValue != value) {
            return false;
          }
        }

        // Check in tags
        if (key == 'tag' && !node.tags.contains(value)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Find potential duplicate nodes based on similarity
  static List<({EntityNode node1, EntityNode node2, double similarity})>
      findPotentialDuplicates(
    List<EntityNode> allNodes, {
    double similarityThreshold = 0.7,
  }) {
    final duplicates =
        <({EntityNode node1, EntityNode node2, double similarity})>[];

    for (var i = 0; i < allNodes.length; i++) {
      for (var j = i + 1; j < allNodes.length; j++) {
        final node1 = allNodes[i];
        final node2 = allNodes[j];

        // Only compare nodes of the same type
        if (node1.type == node2.type) {
          final similarity = _calculateNodeSimilarity(node1, node2);
          if (similarity >= similarityThreshold) {
            duplicates.add((
              node1: node1,
              node2: node2,
              similarity: similarity
            ));
          }
        }
      }
    }

    duplicates.sort((a, b) => b.similarity.compareTo(a.similarity));
    return duplicates;
  }

  /// Find bridge nodes (nodes that if removed would disconnect the graph)
  static List<EntityNode> findBridgeNodes(
    List<EntityNode> allNodes,
    List<Relationship> allRelationships,
  ) {
    final bridges = <EntityNode>[];
    final originalComponents = findConnectedComponents(allNodes, allRelationships);

    for (final node in allNodes) {
      // Temporarily remove node and its relationships
      final tempNodes = allNodes.where((n) => n.id != node.id).toList();
      final tempRels = allRelationships
          .where((r) =>
              r.sourceNodeId != node.id && r.targetNodeId != node.id)
          .toList();

      final newComponents = findConnectedComponents(tempNodes, tempRels);

      // If removing the node increases the number of components, it's a bridge
      if (newComponents.length > originalComponents.length) {
        bridges.add(node);
      }
    }

    return bridges;
  }

  /// Calculate clustering coefficient for a node
  static double calculateClusteringCoefficient(
    EntityNode node,
    List<EntityNode> allNodes,
    List<Relationship> allRelationships,
  ) {
    final adjacency = _buildAdjacencyMap(allNodes, allRelationships);
    final neighbors = adjacency[node.id]?.keys.toList() ?? [];

    if (neighbors.length < 2) return 0.0;

    int connections = 0;
    final possibleConnections = neighbors.length * (neighbors.length - 1) ~/ 2;

    for (var i = 0; i < neighbors.length; i++) {
      for (var j = i + 1; j < neighbors.length; j++) {
        final neighbor1 = neighbors[i];
        final neighbor2 = neighbors[j];

        if (adjacency[neighbor1]?.containsKey(neighbor2) ?? false) {
          connections++;
        }
      }
    }

    return connections / possibleConnections;
  }

  // Helper methods

  static Map<String, Map<String, double>> _buildAdjacencyMap(
    List<EntityNode> nodes,
    List<Relationship> relationships,
  ) {
    final adjacency = <String, Map<String, double>>{};

    for (final node in nodes) {
      adjacency[node.id] = {};
    }

    for (final rel in relationships) {
      adjacency[rel.sourceNodeId]![rel.targetNodeId] = rel.weight;
      if (!rel.isDirected) {
        adjacency[rel.targetNodeId]![rel.sourceNodeId] = rel.weight;
      }
    }

    return adjacency;
  }

  static void _dfs(
    String nodeId,
    Map<String, Map<String, double>> adjacency,
    Set<String> visited,
    List<EntityNode> component,
    List<EntityNode> allNodes,
  ) {
    visited.add(nodeId);
    component.add(allNodes.firstWhere((n) => n.id == nodeId));

    for (final neighborId in adjacency[nodeId]?.keys ?? <String>[]) {
      if (!visited.contains(neighborId)) {
        _dfs(neighborId, adjacency, visited, component, allNodes);
      }
    }
  }

  static double _calculateNodeSimilarity(EntityNode node1, EntityNode node2) {
    double score = 0.0;
    int factors = 0;

    // Label similarity (Levenshtein-like)
    final labelSim = _stringSimilarity(
      node1.label.toLowerCase(),
      node2.label.toLowerCase(),
    );
    score += labelSim;
    factors++;

    // Description similarity
    if (node1.description != null && node2.description != null) {
      final descSim = _stringSimilarity(
        node1.description!.toLowerCase(),
        node2.description!.toLowerCase(),
      );
      score += descSim;
      factors++;
    }

    // Tag overlap
    if (node1.tags.isNotEmpty && node2.tags.isNotEmpty) {
      final commonTags = node1.tags.toSet().intersection(node2.tags.toSet());
      final totalTags = node1.tags.toSet().union(node2.tags.toSet());
      score += commonTags.length / totalTags.length;
      factors++;
    }

    // Attribute similarity
    final commonKeys =
        node1.attributes.keys.toSet().intersection(node2.attributes.keys.toSet());
    if (commonKeys.isNotEmpty) {
      int matchingAttrs = 0;
      for (final key in commonKeys) {
        if (node1.attributes[key] == node2.attributes[key]) {
          matchingAttrs++;
        }
      }
      score += matchingAttrs / commonKeys.length;
      factors++;
    }

    return factors > 0 ? score / factors : 0.0;
  }

  static double _stringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;

    if (longer.isEmpty) return 1.0;

    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  static int _levenshteinDistance(String s1, String s2) {
    final costs = List<int>.generate(s2.length + 1, (i) => i);

    for (var i = 1; i <= s1.length; i++) {
      var lastValue = i;
      for (var j = 1; j <= s2.length; j++) {
        final newValue = s1[i - 1] == s2[j - 1]
            ? costs[j - 1]
            : [costs[j - 1], lastValue, costs[j]].reduce((a, b) => a < b ? a : b) + 1;
        costs[j - 1] = lastValue;
        lastValue = newValue;
      }
      costs[s2.length] = lastValue;
    }

    return costs[s2.length];
  }
}
