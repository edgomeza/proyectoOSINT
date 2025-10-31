import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodesByInvestigationProvider(widget.investigationId));
    final relationships =
        ref.watch(relationshipsByInvestigationProvider(widget.investigationId));

    // Apply filters
    final filteredNodes = _filterNodes(nodes);
    final filteredRelationships = _filterRelationships(relationships, filteredNodes);

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
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(100),
                          minScale: 0.01,
                          maxScale: 5.6,
                          child: SizedBox(
                            width: constraints.maxWidth * 2,
                            height: constraints.maxHeight * 2,
                            child: _buildCustomGraphLayout(
                              context,
                              filteredNodes,
                              filteredRelationships,
                              constraints.maxWidth * 2,
                              constraints.maxHeight * 2,
                            ),
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

  Widget _buildCustomGraphLayout(
    BuildContext context,
    List<EntityNode> nodes,
    List<Relationship> relationships,
    double width,
    double height,
  ) {
    // Calculate circular layout positions
    final center = Offset(width / 2, height / 2);
    final radius = (width < height ? width : height) * 0.35;

    // Create node position map if not already saved
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (!_nodePositions.containsKey(node.id)) {
        // Position nodes in a circle
        final angle = (i * 2 * 3.14159) / nodes.length;
        _nodePositions[node.id] = Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        );
      }
    }

    return CustomPaint(
      painter: GraphEdgesPainter(
        nodes: nodes,
        relationships: relationships,
        nodePositions: _nodePositions,
        getEdgeColor: _getEdgeColor,
      ),
      child: Stack(
        children: nodes.map((node) {
          final position = _nodePositions[node.id] ?? center;
          return Positioned(
            left: position.dx - 50,
            top: position.dy - 50,
            child: _buildNodeWidget(context, node),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, EntityNode entityNode) {
    final color = _getNodeColor(entityNode.type, entityNode.riskLevel);
    final isSelected = _selectedSourceNode?.id == entityNode.id ||
                      _selectedTargetNode?.id == entityNode.id;
    final isSource = _selectedSourceNode?.id == entityNode.id;

    final nodeContent = Container(
      width: 100,
      height: 100,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getNodeIcon(entityNode.type),
            color: Colors.white,
            size: 24,
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            Expanded(
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

// Custom painter for drawing edges between nodes
class GraphEdgesPainter extends CustomPainter {
  final List<EntityNode> nodes;
  final List<Relationship> relationships;
  final Map<String, Offset> nodePositions;
  final Color Function(RelationshipType) getEdgeColor;

  GraphEdgesPainter({
    required this.nodes,
    required this.relationships,
    required this.nodePositions,
    required this.getEdgeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final relationship in relationships) {
      final sourcePos = nodePositions[relationship.sourceNodeId];
      final targetPos = nodePositions[relationship.targetNodeId];

      if (sourcePos != null && targetPos != null) {
        final paint = Paint()
          ..color = getEdgeColor(relationship.type)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawLine(sourcePos, targetPos, paint);

        // Draw arrow at the end
        _drawArrow(canvas, sourcePos, targetPos, paint);
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 10.0;
    final direction = (end - start);
    final length = direction.distance;

    if (length == 0) return;

    final unitDirection = direction / length;
    final arrowTip = end - unitDirection * 50; // Offset from node center

    final perpendicular = Offset(-unitDirection.dy, unitDirection.dx);
    final arrowPoint1 = arrowTip - unitDirection * arrowSize + perpendicular * arrowSize * 0.5;
    final arrowPoint2 = arrowTip - unitDirection * arrowSize - perpendicular * arrowSize * 0.5;

    final path = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant GraphEdgesPainter oldDelegate) {
    return relationships != oldDelegate.relationships ||
        nodePositions != oldDelegate.nodePositions;
  }
}
