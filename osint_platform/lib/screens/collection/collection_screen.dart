import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/common/navigation_drawer.dart';
import '../../widgets/common/category_selector.dart';
import '../../widgets/common/dynamic_field_input.dart';
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
    setState(() {
      _selectedCategory = category;
      _currentFields.clear();

      // Dispose de todos los controladores antiguos antes de limpiar
      for (var controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();

      // Cargar campos predeterminados
      final defaultFields = CategoryFieldsGenerator.getDefaultFields(category);
      _currentFields.addAll(defaultFields);

      // Crear controladores
      for (var i = 0; i < _currentFields.length; i++) {
        _controllers['field_$i'] = TextEditingController();
      }
    });
  }

  void _addCustomField() {
    if (_currentFields.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 10 campos permitidos para evitar sobrecarga cognitiva'),
          backgroundColor: Colors.orange,
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
    setState(() {
      // Remover el campo
      _currentFields.removeAt(index);

      // Guardar los textos de los controladores antes de limpiarlos
      final savedTexts = <int, String>{};
      for (var i = 0; i < _controllers.length; i++) {
        final controller = _controllers['field_$i'];
        if (controller != null && controller.text.isNotEmpty) {
          savedTexts[i] = controller.text;
        }
      }

      // Disponer de todos los controladores
      for (var controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();

      // Crear nuevos controladores con los valores preservados
      for (var i = 0; i < _currentFields.length; i++) {
        final newController = TextEditingController();

        // Si había un valor en el controlador anterior, preservarlo
        final oldIndex = i >= index ? i + 1 : i;
        if (savedTexts.containsKey(oldIndex)) {
          newController.text = savedTexts[oldIndex]!;
        }

        _controllers['field_$i'] = newController;
      }
    });
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Recopilar datos del formulario
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
          const SnackBar(
            content: Text('Por favor completa al menos un campo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Crear nuevo formulario
      final newForm = DataForm(
        investigationId: widget.investigationId,
        category: _selectedCategory!,
        fields: fields,
        status: DataFormStatus.draft,
      );

      // Guardar en provider
      ref.read(dataFormsProvider.notifier).addDataForm(newForm);

      // Limpiar formulario
      _resetForm();

      // Cambiar a tab de guardados
      _tabController.animateTo(1);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formulario guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCategory = null;
      _currentFields.clear();
      for (var controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(investigationByIdProvider(widget.investigationId));
    final savedForms = ref.watch(dataFormsByInvestigationProvider(widget.investigationId));

    if (investigation == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
            tooltip: 'Volver al inicio',
          ),
          title: const Text('Recopilación'),
        ),
        body: const Center(
          child: Text('Investigación no encontrada'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al inicio',
        ),
        title: const Text('Recopilación'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: 'Crear Nuevo'),
            Tab(icon: Icon(Icons.list), text: 'Guardados'),
          ],
        ),
      ),
      drawer: const AppNavigationDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateNewTab(),
          _buildSavedFormsTab(savedForms),
        ],
      ),
    );
  }

  Widget _buildCreateNewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.collections_bookmark_outlined,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recopilación de Datos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Organiza la información de tu investigación',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            if (_selectedCategory != null) ...[
              const SizedBox(height: 32),
              FadeInLeft(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Campos del formulario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addCustomField,
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text('Agregar campo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentFields.length,
                itemBuilder: (context, index) {
                  final field = _currentFields[index];
                  final controller = _controllers['field_$index'];
                  final isCustom = field['custom'] == true;

                  // Si el controlador no existe, no renderizar este campo
                  if (controller == null) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    key: ValueKey('field_$index'),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DynamicFieldInput(
                      label: field['label'],
                      hint: field['hint'],
                      controller: controller,
                      isRequired: field['required'] ?? false,
                      icon: field['icon'],
                      onRemove: isCustom ? () => _removeField(index) : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              FadeInUp(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reiniciar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _saveForm,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Formulario'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_selectedCategory == null) ...[
              const SizedBox(height: 40),
              FadeIn(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selecciona una categoría para comenzar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
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
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay formularios guardados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea tu primer formulario en la pestaña "Crear Nuevo"',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DataFormCard(
            form: form,
            onDelete: () {
              ref.read(dataFormsProvider.notifier).removeDataForm(form.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Formulario eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            onSendToProcessing: () {
              ref.read(dataFormsProvider.notifier).sendToProcessing([form.id]);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Formulario enviado a procesamiento'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
