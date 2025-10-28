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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entity Linking',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Create relationships between entities',
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
        const SizedBox(height: 16),

        // Create Entity from Form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Convert Data Form to Entity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DataForm>(
                  decoration: const InputDecoration(
                    labelText: 'Select Form',
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
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _convertToEntity(context, _selectedForm!),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Create Entity Node'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Create Relationship
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2. Create Relationship',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Source Node
                DropdownButtonFormField<EntityNode>(
                  decoration: const InputDecoration(
                    labelText: 'Source Entity',
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
                const SizedBox(height: 12),

                // Relationship Type
                DropdownButtonFormField<RelationshipType>(
                  decoration: const InputDecoration(
                    labelText: 'Relationship Type',
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
                const SizedBox(height: 12),

                // Target Node
                DropdownButtonFormField<EntityNode>(
                  decoration: const InputDecoration(
                    labelText: 'Target Entity',
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
                const SizedBox(height: 16),

                if (_sourceNode != null && _targetNode != null)
                  ElevatedButton.icon(
                    onPressed: () => _createRelationship(context),
                    icon: const Icon(Icons.link),
                    label: const Text('Create Relationship'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Existing Entities
        Text(
          'Existing Entities (${nodes.length})',
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
                      const SizedBox(height: 12),
                      const Text('No entities yet'),
                      const SizedBox(height: 4),
                      Text(
                        'Convert data forms to entities to get started',
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
          title: const Text('Create Entity from Form'),
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
                      labelText: 'Entity Name *',
                      hintText: 'Enter a name for this entity',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EntityNodeType>(
                    decoration: const InputDecoration(
                      labelText: 'Entity Type',
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RiskLevel>(
                    decoration: const InputDecoration(
                      labelText: 'Risk Level',
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Optional description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Form Data (${form.fields.length} fields)',
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
                      '... and ${form.fields.length - 3} more fields',
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final entityName = nameController.text.trim();
                if (entityName.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an entity name'),
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
                    content: Text('Entity "$entityName" created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );

                setState(() => _selectedForm = null);
              },
              child: const Text('Create Entity'),
            ),
          ],
        ),
      ),
    );
  }

  EntityNodeType _mapCategoryToEntityType(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.person:
        return EntityNodeType.person;
      case DataFormCategory.company:
        return EntityNodeType.company;
      case DataFormCategory.socialNetwork:
        return EntityNodeType.socialNetwork;
      case DataFormCategory.location:
        return EntityNodeType.location;
      case DataFormCategory.relationship:
        return EntityNodeType.other;
      case DataFormCategory.document:
        return EntityNodeType.document;
      case DataFormCategory.event:
        return EntityNodeType.event;
      case DataFormCategory.other:
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
          'Relationship created: ${_sourceNode!.label} → ${_targetNode!.label}',
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
        title: const Text('Delete Entity'),
        content: Text('Are you sure you want to delete "${node.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(entityNodesProvider.notifier).removeNode(node.id);
              ref.read(relationshipsProvider.notifier)
                  .removeRelationshipsForNode(node.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entity deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
