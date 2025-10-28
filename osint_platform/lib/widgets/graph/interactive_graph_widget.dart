import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import '../../models/entity_node.dart';
import '../../models/relationship.dart';
import '../../providers/graph_provider.dart';

class InteractiveGraphWidget extends ConsumerStatefulWidget {
  final String investigationId;
  final Function(EntityNode)? onNodeTap;
  final Function(Relationship)? onEdgeTap;
  final bool showFilters;

  const InteractiveGraphWidget({
    super.key,
    required this.investigationId,
    this.onNodeTap,
    this.onEdgeTap,
    this.showFilters = true,
  });

  @override
  ConsumerState<InteractiveGraphWidget> createState() =>
      _InteractiveGraphWidgetState();
}

class _InteractiveGraphWidgetState
    extends ConsumerState<InteractiveGraphWidget> {
  final Graph graph = Graph()..isTree = false;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  // Filters
  Set<EntityNodeType> selectedTypes = {};
  Set<RiskLevel> selectedRiskLevels = {};
  double minConfidence = 0.0;
  bool showLabels = true;

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodesByInvestigationProvider(widget.investigationId));
    final relationships =
        ref.watch(relationshipsByInvestigationProvider(widget.investigationId));

    // Apply filters
    final filteredNodes = _filterNodes(nodes);
    final filteredRelationships = _filterRelationships(relationships, filteredNodes);

    // Build graph
    _buildGraph(filteredNodes, filteredRelationships);

    return Column(
      children: [
        if (widget.showFilters) _buildFilterBar(context),
        Expanded(
          child: filteredNodes.isEmpty
              ? _buildEmptyState()
              : InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.01,
                  maxScale: 5.6,
                  child: GraphView(
                    graph: graph,
                    algorithm: BuchheimWalkerAlgorithm(
                      builder,
                      TreeEdgeRenderer(builder),
                    ),
                    paint: Paint()
                      ..color = Theme.of(context).colorScheme.primary
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      final entityNode = node.key!.value as EntityNode;
                      return _buildNodeWidget(context, entityNode);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Type Filter
            _buildFilterChip(
              context,
              icon: Icons.filter_list,
              label: 'Type Filter',
              onTap: () => _showTypeFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Risk Filter
            _buildFilterChip(
              context,
              icon: Icons.warning_amber,
              label: 'Risk Filter',
              onTap: () => _showRiskFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Confidence Filter
            _buildFilterChip(
              context,
              icon: Icons.percent,
              label: 'Confidence: ${(minConfidence * 100).toInt()}%',
              onTap: () => _showConfidenceDialog(context),
            ),
            const SizedBox(width: 8),

            // Toggle Labels
            _buildFilterChip(
              context,
              icon: showLabels ? Icons.label : Icons.label_off,
              label: 'Labels',
              onTap: () => setState(() => showLabels = !showLabels),
            ),
            const SizedBox(width: 8),

            // Reset Filters
            _buildFilterChip(
              context,
              icon: Icons.refresh,
              label: 'Reset',
              onTap: _resetFilters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, EntityNode node) {
    final color = _getNodeColor(node.type, node.riskLevel);

    return InkWell(
      onTap: () => widget.onNodeTap?.call(node),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha:0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: node.riskLevel == RiskLevel.critical ||
                    node.riskLevel == RiskLevel.high
                ? Colors.red
                : Colors.white24,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getNodeIcon(node.type),
              color: Colors.white,
              size: 24,
            ),
            if (showLabels) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: Text(
                  node.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (node.confidence < 1.0 && showLabels) ...[
              const SizedBox(height: 2),
              Text(
                '${(node.confidence * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hub_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No entities to display',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add entities from the Collection screen',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  void _buildGraph(List<EntityNode> nodes, List<Relationship> relationships) {
    graph.nodes.clear();
    graph.edges.clear();

    // Create node map
    final nodeMap = <String, Node>{};
    for (final entityNode in nodes) {
      final node = Node.Id(entityNode);
      nodeMap[entityNode.id] = node;
      graph.addNode(node);
    }

    // Add edges
    for (final relationship in relationships) {
      final sourceNode = nodeMap[relationship.sourceNodeId];
      final targetNode = nodeMap[relationship.targetNodeId];

      if (sourceNode != null && targetNode != null) {
        graph.addEdge(
          sourceNode,
          targetNode,
          paint: Paint()
            ..color = _getEdgeColor(relationship.type)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  List<EntityNode> _filterNodes(List<EntityNode> nodes) {
    return nodes.where((node) {
      if (selectedTypes.isNotEmpty && !selectedTypes.contains(node.type)) {
        return false;
      }
      if (selectedRiskLevels.isNotEmpty &&
          !selectedRiskLevels.contains(node.riskLevel)) {
        return false;
      }
      if (node.confidence < minConfidence) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Relationship> _filterRelationships(
    List<Relationship> relationships,
    List<EntityNode> filteredNodes,
  ) {
    final nodeIds = filteredNodes.map((n) => n.id).toSet();
    return relationships.where((rel) {
      return nodeIds.contains(rel.sourceNodeId) &&
          nodeIds.contains(rel.targetNodeId) &&
          rel.confidence >= minConfidence;
    }).toList();
  }

  Color _getNodeColor(EntityNodeType type, RiskLevel risk) {
    if (risk == RiskLevel.critical) return Colors.red.shade900;
    if (risk == RiskLevel.high) return Colors.red.shade700;

    switch (type) {
      case EntityNodeType.person:
        return Colors.blue.shade600;
      case EntityNodeType.company:
        return Colors.purple.shade600;
      case EntityNodeType.organization:
        return Colors.deepPurple.shade600;
      case EntityNodeType.location:
        return Colors.green.shade600;
      case EntityNodeType.document:
        return Colors.indigo.shade600;
      case EntityNodeType.event:
        return Colors.teal.shade600;
      case EntityNodeType.email:
        return Colors.orange.shade600;
      case EntityNodeType.phone:
        return Colors.cyan.shade600;
      case EntityNodeType.website:
        return Colors.lime.shade700;
      case EntityNodeType.ipAddress:
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getNodeIcon(EntityNodeType type) {
    switch (type) {
      case EntityNodeType.person:
        return Icons.person;
      case EntityNodeType.company:
        return Icons.business;
      case EntityNodeType.organization:
        return Icons.corporate_fare;
      case EntityNodeType.location:
        return Icons.location_on;
      case EntityNodeType.document:
        return Icons.description;
      case EntityNodeType.event:
        return Icons.event;
      case EntityNodeType.email:
        return Icons.email;
      case EntityNodeType.phone:
        return Icons.phone;
      case EntityNodeType.website:
        return Icons.language;
      case EntityNodeType.ipAddress:
        return Icons.router;
      default:
        return Icons.help_outline;
    }
  }

  Color _getEdgeColor(RelationshipType type) {
    switch (type) {
      case RelationshipType.familyRelation:
        return Colors.pink.shade300;
      case RelationshipType.businessPartner:
        return Colors.green.shade300;
      case RelationshipType.employee:
        return Colors.blue.shade300;
      case RelationshipType.owns:
        return Colors.amber.shade400;
      case RelationshipType.communicated:
        return Colors.cyan.shade300;
      case RelationshipType.transacted:
        return Colors.orange.shade400;
      case RelationshipType.suspected:
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  void _showTypeFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: EntityNodeType.values.map((type) {
                return CheckboxListTile(
                  title: Text(type.displayName),
                  value: selectedTypes.contains(type),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        selectedTypes.add(type);
                      } else {
                        selectedTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => selectedTypes.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showRiskFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Risk'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: RiskLevel.values.map((risk) {
              return CheckboxListTile(
                title: Text(risk.displayName),
                value: selectedRiskLevels.contains(risk),
                onChanged: (value) {
                  setDialogState(() {
                    if (value == true) {
                      selectedRiskLevels.add(risk);
                    } else {
                      selectedRiskLevels.remove(risk);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => selectedRiskLevels.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showConfidenceDialog(BuildContext context) {
    double tempConfidence = minConfidence;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minimum Confidence'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(tempConfidence * 100).toInt()}%'),
              Slider(
                value: tempConfidence,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setDialogState(() => tempConfidence = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => minConfidence = tempConfidence);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedTypes.clear();
      selectedRiskLevels.clear();
      minConfidence = 0.0;
    });
  }
}
