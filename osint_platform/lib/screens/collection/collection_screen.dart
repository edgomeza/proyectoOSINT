import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../widgets/common/category_selector.dart';
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';
import '../../widgets/common/phase_navigation_buttons.dart';
import '../../models/investigation_phase.dart';
import '../../widgets/common/dynamic_field_input.dart';
import '../../widgets/common/grouped_fields_widget.dart';
import '../../widgets/cards/data_form_card.dart';
import '../../providers/data_forms_provider.dart';
import '../../providers/investigations_provider.dart';
import '../../models/data_form.dart';
import '../../models/data_form_status.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const CollectionScreen({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  DataFormCategory? _selectedCategory;
  final List<Map<String, dynamic>> _currentFields = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCategorySelected(DataFormCategory category) {
    final oldControllers = Map<String, TextEditingController>.from(_controllers);

    setState(() {
      _selectedCategory = category;
      _currentFields.clear();
      _controllers.clear();

      final defaultFields = CategoryFieldsGenerator.getDefaultFields(category);
      _currentFields.addAll(defaultFields);

      for (var i = 0; i < _currentFields.length; i++) {
        _controllers['field_$i'] = TextEditingController();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var controller in oldControllers.values) {
        controller.dispose();
      }
    });
  }

  void _addCustomField() {
    if (_currentFields.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Máximo 10 campos permitidos'),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() {
      final index = _currentFields.length;
      _currentFields.add({
        'label': 'Campo personalizado ${index + 1}',
        'hint': 'Introduce el valor',
        'icon': Icons.add_circle_outline,
        'required': false,
        'custom': true,
      });
      _controllers['field_$index'] = TextEditingController();
    });
  }

  void _removeField(int index) {
    final savedTexts = <int, String>{};
    for (var i = 0; i < _controllers.length; i++) {
      final controller = _controllers['field_$i'];
      if (controller != null && controller.text.isNotEmpty) {
        savedTexts[i] = controller.text;
      }
    }
    final oldControllers = Map<String, TextEditingController>.from(_controllers);

    setState(() {
      _currentFields.removeAt(index);
      _controllers.clear();

      for (var i = 0; i < _currentFields.length; i++) {
        final newController = TextEditingController();
        final oldIndex = i >= index ? i + 1 : i;
        if (savedTexts.containsKey(oldIndex)) {
          newController.text = savedTexts[oldIndex]!;
        }
        _controllers['field_$i'] = newController;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var controller in oldControllers.values) {
        controller.dispose();
      }
    });
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      final fields = <String, dynamic>{};
      for (var i = 0; i < _currentFields.length; i++) {
        final controller = _controllers['field_$i'];
        final label = _currentFields[i]['label'] as String;
        if (controller != null && controller.text.isNotEmpty) {
          fields[label] = controller.text;
        }
      }

      if (fields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor completa al menos un campo'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      final newForm = DataForm(
        investigationId: widget.investigationId,
        category: _selectedCategory!,
        fields: fields,
        status: DataFormStatus.draft,
      );

      ref.read(dataFormsProvider.notifier).addDataForm(newForm);
      _resetForm();
      _tabController.animateTo(1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Formulario guardado exitosamente'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _resetForm() {
    final oldControllers = Map<String, TextEditingController>.from(_controllers);

    setState(() {
      _selectedCategory = null;
      _currentFields.clear();
      _controllers.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var controller in oldControllers.values) {
        controller.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(investigationByIdProvider(widget.investigationId));
    final savedForms = ref.watch(dataFormsByInvestigationProvider(widget.investigationId));

    if (investigation == null) {
      return AppLayoutWrapper(
        appBar: ModernAppBar(
          title: 'Recopilación',
          leading: const PhaseNavigationButtons(),
        ),
        child: const Center(
          child: Text('Investigación no encontrada'),
        ),
      );
    }

    List<DataFormCategory>? availableCategories;
    if (investigation.investigationTypes.isNotEmpty) {
      final categoriesSet = <DataFormCategory>{};
      for (var type in investigation.investigationTypes) {
        categoriesSet.addAll(type.relevantCategories);
      }
      availableCategories = categoriesSet.toList();
    }

    return AppLayoutWrapper(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const PhaseNavigationButtons(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recopilación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              investigation.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_outlined), text: 'Crear'),
            Tab(icon: Icon(Icons.folder_outlined), text: 'Guardados'),
          ],
        ),
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: widget.investigationId,
        currentPhase: InvestigationPhase.collection,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateNewTab(availableCategories),
          _buildSavedFormsTab(savedForms),
        ],
      ),
    );
  }

  Widget _buildCreateNewTab(List<DataFormCategory>? availableCategories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
              availableCategories: availableCategories,
            ),
            if (_selectedCategory != null) ...[
              const SizedBox(height: 40),
              FadeIn(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Campos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addCustomField,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Agregar campo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GroupedFieldsWidget(
                category: _selectedCategory!,
                controllers: _controllers,
                fields: _currentFields,
                onRemoveField: _removeField,
              ),
              const SizedBox(height: 32),
              FadeInUp(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reiniciar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saveForm,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_selectedCategory == null) ...[
              const SizedBox(height: 80),
              FadeIn(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selecciona una categoría para comenzar',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSavedFormsTab(List<DataForm> forms) {
    if (forms.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay formularios guardados',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea tu primer formulario en la pestaña "Crear"',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: forms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final form = forms[index];
        return FadeIn(
          delay: Duration(milliseconds: index * 50),
          child: DataFormCard(
            form: form,
            onTap: () => _showFormDetailsDialog(form),
            onEdit: () => _showEditFormDialog(form),
            onDelete: () {
              ref.read(dataFormsProvider.notifier).removeDataForm(form.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Formulario eliminado'),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            onSendToProcessing: () {
              ref.read(dataFormsProvider.notifier).sendToProcessing([form.id]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Formulario enviado a procesamiento'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFormDetailsDialog(DataForm form) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(form.category.displayName),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detalles del formulario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...form.fields.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.value?.toString() ?? '(vacío)',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showEditFormDialog(DataForm form) {
    final editControllers = <String, TextEditingController>{};

    for (var entry in form.fields.entries) {
      editControllers[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${form.category.displayName}'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: form.fields.entries.map((entry) {
                final controller = editControllers[entry.key]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (var controller in editControllers.values) {
                controller.dispose();
              }
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedFields = <String, dynamic>{};
              for (var entry in editControllers.entries) {
                updatedFields[entry.key] = entry.value.text;
              }

              final updatedForm = DataForm(
                id: form.id,
                investigationId: form.investigationId,
                category: form.category,
                fields: updatedFields,
                status: form.status,
                createdAt: form.createdAt,
                confidence: form.confidence,
                notes: form.notes,
                tags: form.tags,
              );

              ref.read(dataFormsProvider.notifier).update(updatedForm);

              for (var controller in editControllers.values) {
                controller.dispose();
              }

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Formulario actualizado exitosamente'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
