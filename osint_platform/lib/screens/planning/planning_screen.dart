import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/investigations_provider.dart';
import '../../widgets/common/phase_badge.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';
import '../../widgets/common/phase_navigation_buttons.dart';
import '../../models/investigation_phase.dart';
import '../../models/investigation_type.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const PlanningScreen({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<InvestigationType> _selectedInvestigationTypes = [];
  final List<TextEditingController> _objectiveControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _questionControllers = [
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInvestigationData();
  }

  void _loadInvestigationData() {
    final investigation = ref.read(investigationByIdProvider(widget.investigationId));
    if (investigation != null) {
      _nameController.text = investigation.name;
      _descriptionController.text = investigation.description;

      _selectedInvestigationTypes.clear();
      _selectedInvestigationTypes.addAll(investigation.investigationTypes);

      _objectiveControllers.clear();
      for (var objective in investigation.objectives) {
        _objectiveControllers.add(TextEditingController(text: objective));
      }
      if (_objectiveControllers.isEmpty) {
        _objectiveControllers.add(TextEditingController());
      }

      _questionControllers.clear();
      for (var question in investigation.keyQuestions) {
        _questionControllers.add(TextEditingController(text: question));
      }
      if (_questionControllers.isEmpty) {
        _questionControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _objectiveControllers) {
      controller.dispose();
    }
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(investigationByIdProvider(widget.investigationId));

    if (investigation == null) {
      return AppLayoutWrapper(
        appBar: ModernAppBar(
          title: 'Planificación',
          leading: const PhaseNavigationButtons(),
        ),
        child: const Center(
          child: Text('Investigación no encontrada'),
        ),
      );
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
              'Planificación',
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
        actions: [
          IconButton(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save_outlined, size: 22),
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: widget.investigationId,
        currentPhase: InvestigationPhase.planning,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeIn(
                  child: _buildSection(
                    title: 'Información Básica',
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ej: Análisis de Red Social',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Describe el propósito de esta investigación',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: _buildSection(
                    title: 'Tipos de Investigación',
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Los formularios de recopilación se adaptarán según tu selección',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: InvestigationType.values.map((type) {
                          final isSelected = _selectedInvestigationTypes.contains(type);
                          return FilterChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInvestigationTypes.add(type);
                                } else {
                                  _selectedInvestigationTypes.remove(type);
                                }
                              });
                            },
                            showCheckmark: false,
                            selectedColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSection(
                    title: 'Objetivos',
                    subtitle: 'Máximo 5',
                    children: [
                      const SizedBox(height: 20),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _objectiveControllers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _objectiveControllers[index],
                                  style: const TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: 'Ej: Identificar fuentes de información',
                                    filled: true,
                                    fillColor: Theme.of(context).cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon: _objectiveControllers.length > 1
                                        ? IconButton(
                                            icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                                            onPressed: () {
                                              setState(() {
                                                _objectiveControllers.removeAt(index);
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_objectiveControllers.length < 5) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _objectiveControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Agregar objetivo'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: _buildSection(
                    title: 'Preguntas Clave',
                    subtitle: 'Máximo 5',
                    children: [
                      const SizedBox(height: 20),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questionControllers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _questionControllers[index],
                                  style: const TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: '¿Qué información necesitas descubrir?',
                                    filled: true,
                                    fillColor: Theme.of(context).cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon: _questionControllers.length > 1
                                        ? IconButton(
                                            icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                                            onPressed: () {
                                              setState(() {
                                                _questionControllers.removeAt(index);
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_questionControllers.length < 5) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _questionControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Agregar pregunta'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveChanges,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Guardar Planificación',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
        ...children,
      ],
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final investigation = ref.read(investigationByIdProvider(widget.investigationId));
      if (investigation != null) {
        final objectives = _objectiveControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        final questions = _questionControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        final updatedInvestigation = investigation.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          investigationTypes: _selectedInvestigationTypes,
          objectives: objectives,
          keyQuestions: questions,
        );

        ref.read(investigationsProvider.notifier).updateInvestigation(
              widget.investigationId,
              updatedInvestigation,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Planificación guardada exitosamente'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
