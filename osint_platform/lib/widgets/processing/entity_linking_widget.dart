import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:osint_platform/models/data_form_status.dart';
import '../../models/data_form.dart';
import '../../models/entity_node.dart';
import '../../models/relationship.dart';
import '../../providers/data_forms_provider.dart';
import '../../providers/graph_provider.dart';

class EntityLinkingWidget extends ConsumerStatefulWidget {
  final String investigationId;

  const EntityLinkingWidget({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<EntityLinkingWidget> createState() =>
      _EntityLinkingWidgetState();
}

class _EntityLinkingWidgetState extends ConsumerState<EntityLinkingWidget> {
  DataForm? _selectedForm;
  EntityNode? _sourceNode;
  EntityNode? _targetNode;
  RelationshipType _relationshipType = RelationshipType.associated;

  @override
  Widget build(BuildContext context) {
    final forms = ref.watch(dataFormsProvider)
        .where((f) => f.investigationId == widget.investigationId)
        .toList();

    final nodes = ref.watch(nodesByInvestigationProvider(widget.investigationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vinculación de Entidades',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Crear relaciones entre entidades',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Create Entity from Form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Convertir Formulario de Datos a Entidad',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DataForm>(
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Formulario',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedForm,
                  items: forms.map((form) {
                    final label = form.fields['name']?.toString() ??
                        'Form ${form.id.substring(0, 8)}';
                    return DropdownMenuItem(
                      value: form,
                      child: Text('$label (${form.category.displayName})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedForm = value);
                  },
                ),
                if (_selectedForm != null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _convertToEntity(context, _selectedForm!),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Crear Nodo de Entidad'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Create Relationship
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2. Crear Relación',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Source Node
                DropdownButtonFormField<EntityNode>(
                  decoration: const InputDecoration(
                    labelText: 'Entidad de Origen',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _sourceNode,
                  items: nodes.map((node) {
                    return DropdownMenuItem(
                      value: node,
                      child: Text('${node.label} (${node.type.displayName})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _sourceNode = value);
                  },
                ),
                const SizedBox(height: 8),

                // Relationship Type
                DropdownButtonFormField<RelationshipType>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Relación',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _relationshipType,
                  items: RelationshipType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _relationshipType = value!);
                  },
                ),
                const SizedBox(height: 8),

                // Target Node
                DropdownButtonFormField<EntityNode>(
                  decoration: const InputDecoration(
                    labelText: 'Entidad de Destino',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _targetNode,
                  items: nodes
                      .where((node) => node.id != _sourceNode?.id)
                      .map((node) {
                    return DropdownMenuItem(
                      value: node,
                      child: Text('${node.label} (${node.type.displayName})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _targetNode = value);
                  },
                ),
                const SizedBox(height: 8),

                if (_sourceNode != null && _targetNode != null)
                  ElevatedButton.icon(
                    onPressed: () => _createRelationship(context),
                    icon: const Icon(Icons.link),
                    label: const Text('Crear Relación'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Existing Entities
        Text(
          'Entidades Existentes (${nodes.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: nodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hub_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      const Text('No hay entidades aún'),
                      const SizedBox(height: 4),
                      Text(
                        'Convierte formularios de datos a entidades para comenzar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes[index];
                    return _buildEntityCard(context, node);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEntityCard(BuildContext context, EntityNode node) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNodeColor(node.type).withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNodeIcon(node.type),
            color: _getNodeColor(node.type),
          ),
        ),
        title: Text(node.label),
        subtitle: Text(
          '${node.type.displayName} • ${node.riskLevel.displayName} Risk',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (node.confidence < 1.0)
              Chip(
                label: Text('${(node.confidence * 100).toInt()}%'),
                backgroundColor: Colors.amber.withValues(alpha:0.2),
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteNode(context, node),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNodeColor(EntityNodeType type) {
    switch (type) {
      case EntityNodeType.person:
        return Colors.blue;
      case EntityNodeType.company:
        return Colors.purple;
      case EntityNodeType.location:
        return Colors.green;
      case EntityNodeType.document:
        return Colors.indigo;
      case EntityNodeType.event:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getNodeIcon(EntityNodeType type) {
    switch (type) {
      case EntityNodeType.person:
        return Icons.person;
      case EntityNodeType.company:
        return Icons.business;
      case EntityNodeType.location:
        return Icons.location_on;
      case EntityNodeType.document:
        return Icons.description;
      case EntityNodeType.event:
        return Icons.event;
      default:
        return Icons.help_outline;
    }
  }

  void _convertToEntity(BuildContext context, DataForm form) {
    final nameController = TextEditingController(
      text: form.fields['name']?.toString() ?? form.fields['nombre']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: form.notes ?? '',
    );
    EntityNodeType selectedType = _mapCategoryToEntityType(form.category);
    RiskLevel selectedRiskLevel = RiskLevel.medium;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear Entidad desde Formulario'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Entidad *',
                      hintText: 'Ingrese un nombre para esta entidad',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<EntityNodeType>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Entidad',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedType,
                    items: EntityNodeType.values.map((type) {
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
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RiskLevel>(
                    decoration: const InputDecoration(
                      labelText: 'Nivel de Riesgo',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedRiskLevel,
                    items: RiskLevel.values.map((risk) {
                      return DropdownMenuItem(
                        value: risk,
                        child: Text(risk.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRiskLevel = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción opcional',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Datos del Formulario (${form.fields.length} campos)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...form.fields.entries.take(3).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                  if (form.fields.length > 3)
                    Text(
                      '... y ${form.fields.length - 3} campos más',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                descriptionController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final entityName = nameController.text.trim();
                if (entityName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingrese un nombre de entidad'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final node = EntityNode(
                  label: entityName,
                  type: selectedType,
                  riskLevel: selectedRiskLevel,
                  confidence: form.confidence,
                  description: descriptionController.text.trim(),
                  tags: form.tags,
                  attributes: {
                    ...form.fields,
                    'investigationId': widget.investigationId,
                    'sourceFormId': form.id,
                  },
                );

                ref.read(entityNodesProvider.notifier).addNode(node);

                nameController.dispose();
                descriptionController.dispose();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Entidad "$entityName" creada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );

                setState(() => _selectedForm = null);
              },
              child: const Text('Crear Entidad'),
            ),
          ],
        ),
      ),
    );
  }

  EntityNodeType _mapCategoryToEntityType(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.personalData:
        return EntityNodeType.person;
      case DataFormCategory.corporateData:
        return EntityNodeType.company;
      case DataFormCategory.socialMediaData:
        return EntityNodeType.socialNetwork;
      case DataFormCategory.geographicData:
        return EntityNodeType.location;
      case DataFormCategory.multimediaData:
        return EntityNodeType.document;
      case DataFormCategory.temporalData:
        return EntityNodeType.event;
      case DataFormCategory.digitalData:
        return EntityNodeType.other;
      case DataFormCategory.financialData:
        return EntityNodeType.other;
      case DataFormCategory.technicalData:
        return EntityNodeType.other;
    }
  }

  void _createRelationship(BuildContext context) {
    if (_sourceNode == null || _targetNode == null) return;

    final relationship = Relationship(
      sourceNodeId: _sourceNode!.id,
      targetNodeId: _targetNode!.id,
      type: _relationshipType,
      confidence: 0.9,
      attributes: {
        'investigationId': widget.investigationId,
        'createdManually': true,
      },
    );

    ref.read(relationshipsProvider.notifier).addRelationship(relationship);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Relación creada: ${_sourceNode!.label} → ${_targetNode!.label}',
        ),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _sourceNode = null;
      _targetNode = null;
      _relationshipType = RelationshipType.associated;
    });
  }

  void _deleteNode(BuildContext context, EntityNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Entidad'),
        content: Text('¿Está seguro que desea eliminar "${node.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(entityNodesProvider.notifier).removeNode(node.id);
              ref.read(relationshipsProvider.notifier)
                  .removeRelationshipsForNode(node.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entidad eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
