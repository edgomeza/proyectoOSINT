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
  late FruchtermanReingoldAlgorithm algorithm;
  late TransformationController _transformationController;

  // Node positions (drag functionality removed)
  final Map<String, Offset> _nodePositions = {};

  // Node selection for creating relationships
  EntityNode? _selectedSourceNode;
  EntityNode? _selectedTargetNode;
  bool _isCreatingRelationship = false;

  // Filters
  Set<EntityNodeType> selectedTypes = {};
  Set<RiskLevel> selectedRiskLevels = {};
  double minConfidence = 0.0;
  bool showLabels = true;

  @override
  void initState() {
    super.initState();
    // Use FruchtermanReingold algorithm - force-directed layout for better graph visualization
    final config = FruchtermanReingoldConfiguration();
    // Conservative iteration count to prevent graphview internal bugs
    // Reduced from 5000 to 3000 due to known graphview stability issues with F-R
    // Lower iterations = more stable execution, still sufficient for good layout
    config.iterations = 3000;
    algorithm = FruchtermanReingoldAlgorithm(config);

    // Initialize transformation controller with centered view
    _transformationController = TransformationController();
    // Apply translation to center the graph, then scale down for full view
    // Translation moves viewport to show the graph centered instead of top-left corner
    _transformationController.value = Matrix4.identity()
      ..translate(200.0, 200.0)  // Center the viewport on the graph area
      ..scale(0.3, 0.3, 1.0);     // Scale down to show full graph
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
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
          child: Stack(
            children: [
              filteredNodes.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Ensure we have valid constraints before building GraphView
                        if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return InteractiveViewer(
                          transformationController: _transformationController,
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(100),
                          minScale: 0.01,
                          maxScale: 5.6,
                          child: GraphView(
                            // Dynamic key forces complete rebuild when data changes
                            // Prevents Riverpod async update conflicts during F-R iterations
                            // If null check errors persist, consider:
                            // 1. BuchheimWalkerAlgorithm (more stable, hierarchical)
                            // 2. SugiyamaAlgorithm (directed graphs)
                            // 3. Updating graphview library version
                            key: ValueKey('graph_${filteredNodes.length}_${filteredRelationships.length}'),
                            graph: graph,
                            algorithm: algorithm,
                            paint: Paint()
                              ..color = Theme.of(context).colorScheme.primary
                              ..strokeWidth = 2
                              ..style = PaintingStyle.stroke,
                            builder: (Node node) {
                              // Extract EntityNode from ValueKey attached during graph construction
                              // Using ValueKey with explicit String ID prevents null check errors
                              final entityNode = (node.key as ValueKey?)?.value;

                              // Verify that the value exists and is of the correct type
                              if (entityNode == null || entityNode is! EntityNode) {
                                return const SizedBox.shrink();
                              }

                              // Now entityNode is guaranteed to be an EntityNode
                              return _buildNodeWidget(context, entityNode, node);
                            },
                          ),
                        );
                      },
                    ),
              // Floating action button for relationship creation
              if (filteredNodes.isNotEmpty)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildRelationshipControls(context),
                ),
            ],
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
              label: 'Filtro de Tipo',
              onTap: () => _showTypeFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Risk Filter
            _buildFilterChip(
              context,
              icon: Icons.warning_amber,
              label: 'Filtro de Riesgo',
              onTap: () => _showRiskFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Confidence Filter
            _buildFilterChip(
              context,
              icon: Icons.percent,
              label: 'Confianza: ${(minConfidence * 100).toInt()}%',
              onTap: () => _showConfidenceDialog(context),
            ),
            const SizedBox(width: 8),

            // Toggle Labels
            _buildFilterChip(
              context,
              icon: showLabels ? Icons.label : Icons.label_off,
              label: 'Etiquetas',
              onTap: () => setState(() => showLabels = !showLabels),
            ),
            const SizedBox(width: 8),

            // Reset Filters
            _buildFilterChip(
              context,
              icon: Icons.refresh,
              label: 'Reiniciar',
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

  Widget _buildNodeWidget(BuildContext context, EntityNode entityNode, Node graphNode) {
    final color = _getNodeColor(entityNode.type, entityNode.riskLevel);
    final isSelected = _selectedSourceNode?.id == entityNode.id ||
                      _selectedTargetNode?.id == entityNode.id;
    final isSource = _selectedSourceNode?.id == entityNode.id;

    final nodeContent = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha:0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? (isSource ? Colors.green : Colors.blue)
              : (entityNode.riskLevel == RiskLevel.critical ||
                      entityNode.riskLevel == RiskLevel.high
                  ? Colors.red
                  : Colors.white24),
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? (isSource ? Colors.green : Colors.blue).withValues(alpha: 0.5)
                : color.withValues(alpha: 0.3),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getNodeIcon(entityNode.type),
            color: Colors.white,
            size: 24,
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: Text(
                entityNode.label,
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
          if (entityNode.confidence < 1.0 && showLabels) ...[
            const SizedBox(height: 2),
            Text(
              '${(entityNode.confidence * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );

    // Removed drag functionality, only keeping tap
    return GestureDetector(
      onTap: () {
        if (_isCreatingRelationship) {
          _handleNodeSelectionForRelationship(entityNode);
        } else {
          widget.onNodeTap?.call(entityNode);
        }
      },
      child: nodeContent,
    );
  }

  void _handleNodeSelectionForRelationship(EntityNode node) {
    setState(() {
      if (_selectedSourceNode == null) {
        // Select as source
        _selectedSourceNode = node;
      } else if (_selectedSourceNode!.id == node.id) {
        // Deselect source
        _selectedSourceNode = null;
        _selectedTargetNode = null;
      } else if (_selectedTargetNode == null) {
        // Select as target and show dialog
        _selectedTargetNode = node;
        _showCreateRelationshipDialog();
      } else {
        // Reset and select as new source
        _selectedSourceNode = node;
        _selectedTargetNode = null;
      }
    });
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
            'No hay entidades para mostrar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega entidades desde la pantalla de Recopilación',
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

    // Don't build graph if there are no nodes to prevent algorithm errors
    if (nodes.isEmpty) {
      return;
    }

    // Create node map
    final nodeMap = <String, Node>{};

    for (int i = 0; i < nodes.length; i++) {
      final entityNode = nodes[i];
      // Use explicit String ID instead of entire EntityNode object for stability
      // This prevents null check errors in graphview's internal algorithm
      final node = Node.Id(entityNode.id);
      // Attach the complete EntityNode via ValueKey for access in builder
      node.key = ValueKey(entityNode);
      nodeMap[entityNode.id] = node;

      // Initialize node size for FruchtermanReingold collision detection of SQUARE nodes
      // Real widget size: ~108px wide x ~90px tall
      // Nodes are SQUARES not points - need large repulsion margin for visual separation
      // Using 300x300 (3x real size) ensures strong repulsion forces between nodes
      // CRITICAL: Larger size = stronger repulsion = less overlap for square widgets
      node.size = const Size(300, 300);

      // Load saved position from entity node if available, otherwise distribute with offset
      if (entityNode.x != null && entityNode.y != null) {
        final savedPosition = Offset(entityNode.x!, entityNode.y!);
        _nodePositions[entityNode.id] = savedPosition;
        node.position = savedPosition;
      } else {
        // Distribute nodes in a wide grid pattern with large offset from origin
        // Large offset prevents layout from clustering near (0,0) in top-left corner
        final gridSize = (nodes.length / 2).ceil();
        final row = i ~/ gridSize;
        final col = i % gridSize;
        final spacing = 800.0; // Large spacing between nodes in grid
        const double initialOffset = 1000.0; // Offset from origin to prevent corner clustering
        node.position = Offset(
          col * spacing + initialOffset,
          row * spacing + initialOffset,
        );
      }

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
        title: const Text('Filtrar por Tipo'),
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
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _showRiskFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Riesgo'),
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
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
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
        title: const Text('Confianza Mínima'),
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
            child: const Text('Aplicar'),
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

  Widget _buildRelationshipControls(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isCreatingRelationship && _selectedSourceNode != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Relación',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Origen: ${_selectedSourceNode!.label}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (_selectedTargetNode != null)
                  Text(
                    'Destino: ${_selectedTargetNode!.label}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                else
                  const Text(
                    'Seleccione nodo destino',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _isCreatingRelationship = !_isCreatingRelationship;
              if (!_isCreatingRelationship) {
                _selectedSourceNode = null;
                _selectedTargetNode = null;
              }
            });
          },
          icon: Icon(_isCreatingRelationship ? Icons.close : Icons.link_outlined),
          label: Text(_isCreatingRelationship ? 'Cancelar' : 'Nueva Relación'),
          backgroundColor: _isCreatingRelationship
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  void _showCreateRelationshipDialog() {
    if (_selectedSourceNode == null || _selectedTargetNode == null) return;

    RelationshipType selectedType = RelationshipType.associated;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear Nueva Relación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Desde: ${_selectedSourceNode!.label}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hacia: ${_selectedTargetNode!.label}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RelationshipType>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Relación',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedType,
                items: RelationshipType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _selectedSourceNode = null;
                  _selectedTargetNode = null;
                });
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _createRelationship(selectedType);
                Navigator.pop(dialogContext);
              },
              icon: const Icon(Icons.link),
              label: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _createRelationship(RelationshipType type) {
    if (_selectedSourceNode == null || _selectedTargetNode == null) return;

    final relationship = Relationship(
      sourceNodeId: _selectedSourceNode!.id,
      targetNodeId: _selectedTargetNode!.id,
      type: type,
      confidence: 1.0,
      attributes: {
        'investigationId': widget.investigationId,
        'createdManually': true,
        'createdFrom': 'graph',
      },
    );

    ref.read(relationshipsProvider.notifier).addRelationship(relationship);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Relación creada: ${_selectedSourceNode!.label} → ${_selectedTargetNode!.label}',
        ),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _selectedSourceNode = null;
      _selectedTargetNode = null;
      _isCreatingRelationship = false;
    });
  }
}
