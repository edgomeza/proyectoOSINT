import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../providers/investigations_provider.dart';
import '../../widgets/common/phase_badge.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';
import '../../widgets/common/phase_navigation_buttons.dart';
import '../../models/investigation_phase.dart';

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

      // Cargar objetivos
      _objectiveControllers.clear();
      for (var objective in investigation.objectives) {
        _objectiveControllers.add(TextEditingController(text: objective));
      }
      if (_objectiveControllers.isEmpty) {
        _objectiveControllers.add(TextEditingController());
      }

      // Cargar preguntas
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
      appBar: ModernAppBar(
        title: 'Planificación',
        subtitle: investigation.name,
        leading: const PhaseNavigationButtons(),
        actions: [
          IconButton(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save_outlined),
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
                          color: Colors.blue.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              investigation.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            PhaseBadge(
                              phase: investigation.currentPhase,
                              isCompact: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: _buildSection(
                    title: 'Información Básica',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Investigación',
                            hintText: 'Ej: Análisis de Red Social',
                            prefixIcon: Icon(Icons.edit_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            hintText: 'Describe brevemente el propósito de esta investigación',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          maxLines: 3,
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
                ),
                const SizedBox(height: 24),
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSection(
                    title: 'Objetivos (Máximo 5)',
                    icon: Icons.flag_outlined,
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _objectiveControllers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _objectiveControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Objetivo ${index + 1}',
                                        hintText: 'Ej: Identificar fuentes de información',
                                        prefixIcon: const Icon(Icons.check_circle_outline),
                                        suffixIcon: _objectiveControllers.length > 1
                                            ? IconButton(
                                                icon: const Icon(Icons.remove_circle_outline),
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
                              ),
                            );
                          },
                        ),
                        if (_objectiveControllers.length < 5)
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _objectiveControllers.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Objetivo'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInLeft(
                  delay: const Duration(milliseconds: 300),
                  child: _buildSection(
                    title: 'Preguntas Clave (Máximo 5)',
                    icon: Icons.help_outline,
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _questionControllers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _questionControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Pregunta ${index + 1}',
                                        hintText: '¿Qué información necesitas descubrir?',
                                        prefixIcon: const Icon(Icons.question_mark),
                                        suffixIcon: _questionControllers.length > 1
                                            ? IconButton(
                                                icon: const Icon(Icons.remove_circle_outline),
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
                              ),
                            );
                          },
                        ),
                        if (_questionControllers.length < 5)
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _questionControllers.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Pregunta'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Planificación'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final investigation = ref.read(investigationByIdProvider(widget.investigationId));
      if (investigation != null) {
        // Recopilar objetivos no vacíos
        final objectives = _objectiveControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        // Recopilar preguntas no vacías
        final questions = _questionControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        final updatedInvestigation = investigation.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          objectives: objectives,
          keyQuestions: questions,
        );

        ref.read(investigationsProvider.notifier).updateInvestigation(
              widget.investigationId,
              updatedInvestigation,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Planificación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
