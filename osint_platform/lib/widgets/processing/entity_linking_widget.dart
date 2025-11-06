import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/entity_node.dart';
import '../../models/relationship.dart';
import '../../models/data_form.dart';
import '../../models/data_form_status.dart';
import '../../providers/entities_provider.dart';
import '../../providers/data_forms_provider.dart';

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
  bool _showEntityForm = false;
  bool _showRelationshipForm = false;

  @override
  Widget build(BuildContext context) {
    final entities = ref.watch(entitiesProvider(widget.investigationId));
    final relationships = ref.watch(relationshipsProvider(widget.investigationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        FadeInDown(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.link, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
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
                        const SizedBox(height: 4),
                        Text(
                          'Crea entidades y establece relaciones entre ellas',
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
                    'Entidades',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.link,
                    '${relationships.length}',
                    'Relaciones',
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => setState(() => _showEntityForm = !_showEntityForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Entidad'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showImportFromFormsDialog(),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Importar de Formularios'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: entities.length >= 2
                      ? () => setState(() => _showRelationshipForm = !_showRelationshipForm)
                      : null,
                  icon: const Icon(Icons.link),
                  label: const Text('Nueva Relación'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Entity form
        if (_showEntityForm)
          FadeIn(
            child: _EntityForm(
              investigationId: widget.investigationId,
              onSaved: () => setState(() => _showEntityForm = false),
              onCancel: () => setState(() => _showEntityForm = false),
            ),
          ),

        // Relationship form
        if (_showRelationshipForm)
          FadeIn(
            child: _RelationshipForm(
              investigationId: widget.investigationId,
              entities: entities,
              onSaved: () => setState(() => _showRelationshipForm = false),
              onCancel: () => setState(() => _showRelationshipForm = false),
            ),
          ),

        const SizedBox(height: 16),

        // Lists
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entities list
              Expanded(
                child: _EntitiesList(
                  investigationId: widget.investigationId,
                  entities: entities,
                ),
              ),
              const SizedBox(width: 16),
              // Relationships list
              Expanded(
                child: _RelationshipsList(
                  investigationId: widget.investigationId,
                  entities: entities,
                  relationships: relationships,
                ),
              ),
            ],
          ),
        ),
      ],
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

  void _showImportFromFormsDialog() {
    final dataForms = ref.read(dataFormsProvider(widget.investigationId));

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
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.file_download,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Importar desde Formularios'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: dataForms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay formularios disponibles',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: dataForms.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final form = dataForms[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(form.category).withAlpha(50),
                          child: Icon(
                            _getCategoryIcon(form.category),
                            color: _getCategoryColor(form.category),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          form.category.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${form.fields.length} campos'),
                            if (form.notes != null && form.notes!.isNotEmpty)
                              Text(
                                form.notes!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _convertFormToEntity(form);
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Importar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _convertFormToEntity(DataForm form) {
    // Determine entity type from form category
    final EntityNodeType entityType = _mapCategoryToEntityType(form.category);

    // Extract label from form fields
    String label = _extractLabelFromForm(form);

    // Create entity
    final entity = EntityNode(
      label: label,
      type: entityType,
      description: form.notes,
      confidence: form.confidence,
      tags: form.tags,
      attributes: {
        ...form.fields,
        'sourceFormId': form.id,
        'category': form.category.name,
      },
      riskLevel: RiskLevel.unknown,
    );

    ref.read(entitiesProvider(widget.investigationId).notifier).addEntity(entity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entidad "$label" creada desde formulario'),
        backgroundColor: Colors.green,
      ),
    );
  }

  EntityNodeType _mapCategoryToEntityType(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.personalData:
        return EntityNodeType.person;
      case DataFormCategory.digitalData:
        return EntityNodeType.website;
      case DataFormCategory.geographicData:
        return EntityNodeType.location;
      case DataFormCategory.financialData:
        return EntityNodeType.cryptocurrency;
      case DataFormCategory.socialMediaData:
        return EntityNodeType.socialNetwork;
      case DataFormCategory.multimediaData:
        return EntityNodeType.document;
      case DataFormCategory.technicalData:
        return EntityNodeType.ipAddress;
      case DataFormCategory.corporateData:
        return EntityNodeType.company;
      case DataFormCategory.temporalData:
        return EntityNodeType.event;
    }
  }

  String _extractLabelFromForm(DataForm form) {
    // Try to find common name fields
    final fields = form.fields;

    // Check for common label fields
    if (fields['nombre'] != null) return fields['nombre'].toString();
    if (fields['name'] != null) return fields['name'].toString();
    if (fields['título'] != null) return fields['título'].toString();
    if (fields['title'] != null) return fields['title'].toString();
    if (fields['empresa'] != null) return fields['empresa'].toString();
    if (fields['company'] != null) return fields['company'].toString();
    if (fields['dominio'] != null) return fields['dominio'].toString();
    if (fields['domain'] != null) return fields['domain'].toString();
    if (fields['dirección'] != null) return fields['dirección'].toString();
    if (fields['address'] != null) return fields['address'].toString();
    if (fields['ubicación'] != null) return fields['ubicación'].toString();
    if (fields['location'] != null) return fields['location'].toString();

    // Use category as fallback
    return '${form.category.displayName} - ${form.id.substring(0, 8)}';
  }

  Color _getCategoryColor(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.personalData:
        return Colors.blue;
      case DataFormCategory.digitalData:
        return Colors.purple;
      case DataFormCategory.geographicData:
        return Colors.green;
      case DataFormCategory.temporalData:
        return Colors.orange;
      case DataFormCategory.financialData:
        return Colors.amber;
      case DataFormCategory.socialMediaData:
        return Colors.pink;
      case DataFormCategory.multimediaData:
        return Colors.red;
      case DataFormCategory.technicalData:
        return Colors.indigo;
      case DataFormCategory.corporateData:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.personalData:
        return Icons.person;
      case DataFormCategory.digitalData:
        return Icons.computer;
      case DataFormCategory.geographicData:
        return Icons.location_on;
      case DataFormCategory.temporalData:
        return Icons.access_time;
      case DataFormCategory.financialData:
        return Icons.attach_money;
      case DataFormCategory.socialMediaData:
        return Icons.share;
      case DataFormCategory.multimediaData:
        return Icons.perm_media;
      case DataFormCategory.technicalData:
        return Icons.settings;
      case DataFormCategory.corporateData:
        return Icons.business;
    }
  }
}

// Form for creating entities
class _EntityForm extends ConsumerStatefulWidget {
  final String investigationId;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const _EntityForm({
    required this.investigationId,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  ConsumerState<_EntityForm> createState() => __EntityFormState();
}

class __EntityFormState extends ConsumerState<_EntityForm> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  EntityNodeType _selectedType = EntityNodeType.person;
  RiskLevel _selectedRisk = RiskLevel.unknown;
  double _confidence = 0.8;

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Nueva Entidad',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<EntityNodeType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: EntityNodeType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<RiskLevel>(
                      initialValue: _selectedRisk,
                      decoration: const InputDecoration(
                        labelText: 'Nivel de Riesgo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning),
                      ),
                      items: RiskLevel.values.map((risk) {
                        return DropdownMenuItem(
                          value: risk,
                          child: Text(risk.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRisk = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confianza: ${(_confidence * 100).toInt()}%'),
                        Slider(
                          value: _confidence,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() => _confidence = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saveEntity,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntity() {
    if (_formKey.currentState?.validate() ?? false) {
      final entity = EntityNode(
        label: _labelController.text,
        type: _selectedType,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        confidence: _confidence,
        riskLevel: _selectedRisk,
      );

      ref.read(entitiesProvider(widget.investigationId).notifier).addEntity(entity);
      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entidad creada exitosamente')),
      );
    }
  }
}

// Form for creating relationships
class _RelationshipForm extends ConsumerStatefulWidget {
  final String investigationId;
  final List<EntityNode> entities;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const _RelationshipForm({
    required this.investigationId,
    required this.entities,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  ConsumerState<_RelationshipForm> createState() => __RelationshipFormState();
}

class __RelationshipFormState extends ConsumerState<_RelationshipForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  EntityNode? _sourceEntity;
  EntityNode? _targetEntity;
  RelationshipType _selectedType = RelationshipType.associated;
  double _confidence = 0.8;
  bool _isDirected = true;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    'Nueva Relación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<EntityNode>(
                      initialValue: _sourceEntity,
                      decoration: const InputDecoration(
                        labelText: 'Entidad Origen',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      items: widget.entities.map((entity) {
                        return DropdownMenuItem(
                          value: entity,
                          child: Text('${entity.label} (${entity.type.displayName})'),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione una entidad origen';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() => _sourceEntity = value);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      _isDirected ? Icons.arrow_forward : Icons.compare_arrows,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<EntityNode>(
                      initialValue: _targetEntity,
                      decoration: const InputDecoration(
                        labelText: 'Entidad Destino',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      items: widget.entities.map((entity) {
                        return DropdownMenuItem(
                          value: entity,
                          child: Text('${entity.label} (${entity.type.displayName})'),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione una entidad destino';
                        }
                        if (value.id == _sourceEntity?.id) {
                          return 'Debe ser diferente de origen';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() => _targetEntity = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<RelationshipType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Relación',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: RelationshipType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Relación Dirigida'),
                      subtitle: Text(_isDirected ? 'A → B' : 'A ↔ B'),
                      value: _isDirected,
                      onChanged: (value) {
                        setState(() => _isDirected = value ?? true);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confianza: ${(_confidence * 100).toInt()}%'),
                  Slider(
                    value: _confidence,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() => _confidence = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saveRelationship,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRelationship() {
    if (_formKey.currentState?.validate() ?? false) {
      final relationship = Relationship(
        sourceNodeId: _sourceEntity!.id,
        targetNodeId: _targetEntity!.id,
        type: _selectedType,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        confidence: _confidence,
        isDirected: _isDirected,
      );

      ref
          .read(relationshipsProvider(widget.investigationId).notifier)
          .addRelationship(relationship);
      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relación creada exitosamente')),
      );
    }
  }
}

// Entities list widget
class _EntitiesList extends ConsumerWidget {
  final String investigationId;
  final List<EntityNode> entities;

  const _EntitiesList({
    required this.investigationId,
    required this.entities,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.account_tree_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Entidades (${entities.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_tree_outlined,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No hay entidades',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: entities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final entity = entities[index];
                      return FadeInLeft(
                        delay: Duration(milliseconds: index * 50),
                        child: _EntityCard(
                          entity: entity,
                          onDelete: () {
                            ref
                                .read(entitiesProvider(investigationId).notifier)
                                .deleteEntity(entity.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Entity card widget
class _EntityCard extends StatelessWidget {
  final EntityNode entity;
  final VoidCallback onDelete;

  const _EntityCard({
    required this.entity,
    required this.onDelete,
  });

  Color _getColorForType(EntityNodeType type) {
    switch (type) {
      case EntityNodeType.person:
        return Colors.blue;
      case EntityNodeType.company:
        return Colors.purple;
      case EntityNodeType.organization:
        return Colors.orange;
      case EntityNodeType.location:
        return Colors.green;
      case EntityNodeType.email:
        return Colors.red;
      case EntityNodeType.phone:
        return Colors.teal;
      case EntityNodeType.website:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(entity.type);

    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(50),
          child: Icon(_getIconForType(entity.type), color: color, size: 20),
        ),
        title: Text(
          entity.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entity.type.displayName),
            if (entity.description != null) Text(entity.description!, maxLines: 1),
            Row(
              children: [
                Icon(Icons.warning, size: 12, color: _getRiskColor(entity.riskLevel)),
                const SizedBox(width: 4),
                Text(
                  entity.riskLevel.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getRiskColor(entity.riskLevel),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.verified, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${(entity.confidence * 100).toInt()}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar Entidad'),
                content: Text('¿Estás seguro de eliminar "${entity.label}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
          },
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getIconForType(EntityNodeType type) {
    switch (type) {
      case EntityNodeType.person:
        return Icons.person;
      case EntityNodeType.company:
        return Icons.business;
      case EntityNodeType.organization:
        return Icons.groups;
      case EntityNodeType.location:
        return Icons.location_on;
      case EntityNodeType.email:
        return Icons.email;
      case EntityNodeType.phone:
        return Icons.phone;
      case EntityNodeType.website:
        return Icons.language;
      default:
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

// Relationships list widget
class _RelationshipsList extends ConsumerWidget {
  final String investigationId;
  final List<EntityNode> entities;
  final List<Relationship> relationships;

  const _RelationshipsList({
    required this.investigationId,
    required this.entities,
    required this.relationships,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.link, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Relaciones (${relationships.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: relationships.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No hay relaciones',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: relationships.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final relationship = relationships[index];
                      final source = entities.firstWhere(
                        (e) => e.id == relationship.sourceNodeId,
                        orElse: () => EntityNode(
                          label: 'Desconocido',
                          type: EntityNodeType.other,
                        ),
                      );
                      final target = entities.firstWhere(
                        (e) => e.id == relationship.targetNodeId,
                        orElse: () => EntityNode(
                          label: 'Desconocido',
                          type: EntityNodeType.other,
                        ),
                      );

                      return FadeInRight(
                        delay: Duration(milliseconds: index * 50),
                        child: _RelationshipCard(
                          relationship: relationship,
                          source: source,
                          target: target,
                          onDelete: () {
                            ref
                                .read(relationshipsProvider(investigationId).notifier)
                                .deleteRelationship(relationship.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Relationship card widget
class _RelationshipCard extends StatelessWidget {
  final Relationship relationship;
  final EntityNode source;
  final EntityNode target;
  final VoidCallback onDelete;

  const _RelationshipCard({
    required this.relationship,
    required this.source,
    required this.target,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withAlpha(50),
          child: Icon(
            relationship.isDirected ? Icons.arrow_forward : Icons.compare_arrows,
            color: Colors.purple,
            size: 20,
          ),
        ),
        title: Text(
          relationship.type.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${source.label} ${relationship.isDirected ? '→' : '↔'} ${target.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (relationship.description != null)
              Text(relationship.description!, maxLines: 1),
            Row(
              children: [
                Icon(Icons.verified, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${(relationship.confidence * 100).toInt()}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar Relación'),
                content: const Text('¿Estás seguro de eliminar esta relación?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}
