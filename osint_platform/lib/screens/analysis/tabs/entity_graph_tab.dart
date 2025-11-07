import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/entity_node.dart';
import '../../../models/relationship.dart';
import '../../../providers/entities_provider.dart';

class EntityGraphTab extends ConsumerStatefulWidget {
  final String investigationId;

  const EntityGraphTab({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<EntityGraphTab> createState() => _EntityGraphTabState();
}

class _EntityGraphTabState extends ConsumerState<EntityGraphTab> {
  final Graph graph = Graph()..isTree = false;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  // Using FruchtermanReingold algorithm as requested
  late FruchtermanReingoldAlgorithm algorithm;

  final TransformationController _transformationController = TransformationController();

  // Filters
  Set<EntityNodeType> _selectedTypes = {};
  bool _showLabels = true;
  double _nodeSize = 60.0;

  // Track if graph needs rebuild
  String _lastEntityHash = '';
  String _lastRelationshipHash = '';

  // Timer for graph layout animation
  Timer? _layoutTimer;

  @override
  void initState() {
    super.initState();

    // Initialize Fruchterman-Reingold algorithm
    algorithm = FruchtermanReingoldAlgorithm(
      FruchtermanReingoldConfiguration(
        iterations: 500,
        repulsionRate: 0.15,
        attractionRate: 0.25,
      ),
    );
  }

  @override
  void dispose() {
    _layoutTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entities = ref.watch(entitiesProvider(widget.investigationId));
    final relationships = ref.watch(relationshipsProvider(widget.investigationId));

    // Initialize selected types if empty
    if (_selectedTypes.isEmpty && entities.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedTypes = entities.map((e) => e.type).toSet();
        });
      });
    }

    // Filter entities by selected types
    final filteredEntities = entities.where((e) => _selectedTypes.contains(e.type)).toList();

    // Rebuild graph if data changed (outside of layout)
    final entityHash = filteredEntities.map((e) => e.id).join(',');
    final relationshipHash = relationships.map((r) => r.id).join(',');

    if (_lastEntityHash != entityHash || _lastRelationshipHash != relationshipHash) {
      _lastEntityHash = entityHash;
      _lastRelationshipHash = relationshipHash;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && filteredEntities.isNotEmpty) {
          _buildGraph(filteredEntities, relationships);
          setState(() {});
        }
      });
    }

    return Column(
      children: [
        // Header with controls
        FadeInDown(
          child: _buildHeader(context, entities, relationships),
        ),
        const SizedBox(height: 16),

        // Filters
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: _buildFilters(context, entities),
        ),
        const SizedBox(height: 16),

        // Graph view
        Expanded(
          child: filteredEntities.isEmpty
              ? _buildEmptyState(context)
              : FadeIn(
                  child: _buildGraphView(context, filteredEntities, relationships),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<EntityNode> entities, List<Relationship> relationships) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hub, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grafo de Entidades',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visualización interactiva de entidades y sus relaciones',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            _buildStatChip(
              context,
              Icons.account_tree_outlined,
              '${entities.length}',
              'Nodos',
              Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildStatChip(
              context,
              Icons.link,
              '${relationships.length}',
              'Enlaces',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, List<EntityNode> entities) {
    final availableTypes = entities.map((e) => e.type).toSet().toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  'Filtros',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                // Controls inline
                Tooltip(
                  message: 'Mostrar etiquetas',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.label, size: 14, color: Colors.grey[600]),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _showLabels,
                          onChanged: (value) {
                            setState(() => _showLabels = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${_nodeSize.toInt()}', style: TextStyle(fontSize: 11)),
                SizedBox(
                  width: 80,
                  child: Slider(
                    value: _nodeSize,
                    min: 40,
                    max: 100,
                    divisions: 6,
                    onChanged: (value) {
                      setState(() => _nodeSize = value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Reiniciar vista',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    _transformationController.value = Matrix4.identity();
                  },
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: availableTypes.map((type) {
                final isSelected = _selectedTypes.contains(type);
                final color = _getColorForType(type);

                return FilterChip(
                  label: Text(type.displayName, style: TextStyle(fontSize: 11)),
                  selected: isSelected,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTypes.add(type);
                      } else {
                        _selectedTypes.remove(type);
                      }
                    });
                  },
                  avatar: Icon(
                    _getIconForType(type),
                    size: 14,
                    color: isSelected ? Colors.white : color,
                  ),
                  selectedColor: color,
                  checkmarkColor: Colors.white,
                  backgroundColor: color.withAlpha(25),
                  side: BorderSide(color: color.withAlpha(100)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphView(BuildContext context, List<EntityNode> entities, List<Relationship> relationships) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ensure we have valid constraints
            if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }

            return Stack(
              children: [
                // Background
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[50]!,
                        Colors.grey[100]!,
                      ],
                    ),
                  ),
                ),
                // Graph
                if (graph.nodeCount() > 0)
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.1,
                      maxScale: 3.0,
                      constrained: false,
                      child: GraphView(
                        graph: graph,
                        algorithm: algorithm,
                        paint: Paint()
                          ..color = Colors.grey[400]!
                          ..strokeWidth = 2
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          try {
                            final nodeId = node.key?.value;
                            if (nodeId == null) {
                              return const SizedBox.shrink();
                            }

                            final entity = entities.firstWhere(
                              (e) => e.id == nodeId,
                              orElse: () => EntityNode(
                                label: 'Unknown',
                                type: EntityNodeType.other,
                              ),
                            );
                            return _buildNodeWidget(context, entity);
                          } catch (e) {
                            debugPrint('Error building node: $e');
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                // Legend
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildLegend(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, EntityNode entity) {
    final color = _getColorForType(entity.type);
    final icon = _getIconForType(entity.type);

    return GestureDetector(
      onTap: () => _showEntityDetails(context, entity),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: _nodeSize + (_showLabels ? 40 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _nodeSize,
                height: _nodeSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withAlpha(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: _nodeSize * 0.5,
                ),
              ),
              if (_showLabels) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    entity.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Leyenda',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._selectedTypes.map((type) {
              final color = _getColorForType(type);
              final icon = _getIconForType(type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hub,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay entidades para visualizar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea entidades en la fase de Procesamiento para verlas aquí',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _buildGraph(List<EntityNode> entities, List<Relationship> relationships) {
    // Cancel any existing animation timer
    _layoutTimer?.cancel();

    // Recreate the graph to clear it
    graph.nodes.clear();
    graph.edges.clear();

    // Create nodes
    final nodeMap = <String, Node>{};
    for (final entity in entities) {
      final node = Node.Id(entity.id);
      graph.addNode(node);
      nodeMap[entity.id] = node;
    }

    // Create edges
    for (final relationship in relationships) {
      final sourceNode = nodeMap[relationship.sourceNodeId];
      final targetNode = nodeMap[relationship.targetNodeId];

      if (sourceNode != null && targetNode != null) {
        // Check if both nodes are in filtered entities
        final hasSource = entities.any((e) => e.id == relationship.sourceNodeId);
        final hasTarget = entities.any((e) => e.id == relationship.targetNodeId);

        if (hasSource && hasTarget) {
          graph.addEdge(
            sourceNode,
            targetNode,
            paint: Paint()
              ..color = Colors.grey[400]!
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke,
          );
        }
      }
    }

    // Start animation timer to show the force-directed layout calculation
    // The algorithm runs over multiple iterations, and we need to rebuild
    // to show the nodes moving to their calculated positions
    int frameCount = 0;
    const maxFrames = 100; // Animate for ~3 seconds at 30fps

    _layoutTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      frameCount++;
      if (frameCount >= maxFrames) {
        timer.cancel();
      }

      // Force rebuild to show updated node positions
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showEntityDetails(BuildContext context, EntityNode entity) {
    showDialog(
      context: context,
      builder: (context) => FadeIn(
        duration: const Duration(milliseconds: 200),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getColorForType(entity.type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(entity.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.label,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      entity.type.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entity.description != null) ...[
                  Text(
                    'Descripción',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(entity.description!),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailChip(
                        'Confianza',
                        '${(entity.confidence * 100).toInt()}%',
                        Icons.verified,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailChip(
                        'Riesgo',
                        entity.riskLevel.displayName,
                        Icons.warning,
                        _getRiskColor(entity.riskLevel),
                      ),
                    ),
                  ],
                ),
                if (entity.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Etiquetas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entity.tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(EntityNodeType type) {
    switch (type) {
      case EntityNodeType.person:
        return Colors.blue;
      case EntityNodeType.company:
        return Colors.purple;
      case EntityNodeType.organization:
        return Colors.orange;
      case EntityNodeType.socialNetwork:
        return Colors.pink;
      case EntityNodeType.location:
        return Colors.green;
      case EntityNodeType.document:
        return Colors.brown;
      case EntityNodeType.event:
        return Colors.amber;
      case EntityNodeType.email:
        return Colors.red;
      case EntityNodeType.phone:
        return Colors.teal;
      case EntityNodeType.website:
        return Colors.indigo;
      case EntityNodeType.ipAddress:
        return Colors.cyan;
      case EntityNodeType.cryptocurrency:
        return Colors.yellow[700]!;
      case EntityNodeType.vehicle:
        return Colors.blueGrey;
      case EntityNodeType.property:
        return Colors.lightGreen;
      case EntityNodeType.other:
        return Colors.grey;
    }
  }

  IconData _getIconForType(EntityNodeType type) {
    switch (type) {
      case EntityNodeType.person:
        return Icons.person;
      case EntityNodeType.company:
        return Icons.business;
      case EntityNodeType.organization:
        return Icons.groups;
      case EntityNodeType.socialNetwork:
        return Icons.share;
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
      case EntityNodeType.cryptocurrency:
        return Icons.currency_bitcoin;
      case EntityNodeType.vehicle:
        return Icons.directions_car;
      case EntityNodeType.property:
        return Icons.home;
      case EntityNodeType.other:
        return Icons.category;
    }
  }

  Color _getRiskColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.critical:
        return Colors.red;
      case RiskLevel.high:
        return Colors.orange;
      case RiskLevel.medium:
        return Colors.yellow[700]!;
      case RiskLevel.low:
        return Colors.blue;
      case RiskLevel.none:
        return Colors.green;
      case RiskLevel.unknown:
        return Colors.grey;
    }
  }
}
