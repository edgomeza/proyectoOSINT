import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';
import '../../widgets/common/phase_navigation_buttons.dart';
import '../../models/investigation_phase.dart';
import '../../providers/investigations_provider.dart';
import '../../widgets/processing/deduplication_widget.dart';
import '../../widgets/processing/entity_linking_widget.dart';
import '../../widgets/processing/ner_extraction_widget.dart';

class ProcessingScreenRedesigned extends ConsumerStatefulWidget {
  final String investigationId;

  const ProcessingScreenRedesigned({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<ProcessingScreenRedesigned> createState() =>
      _ProcessingScreenRedesignedState();
}

class _ProcessingScreenRedesignedState
    extends ConsumerState<ProcessingScreenRedesigned>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(
      investigationByIdProvider(widget.investigationId),
    );

    if (investigation == null) {
      return AppLayoutWrapper(
        appBar: ModernAppBar(
          title: 'Procesamiento',
          leading: const PhaseNavigationButtons(),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('Investigación no encontrada'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
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
              'Procesamiento',
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
            icon: const Icon(Icons.help_outline, size: 22),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Ayuda',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.storage_outlined), text: 'Datos'),
            Tab(icon: Icon(Icons.content_copy_outlined), text: 'Deduplicación'),
            Tab(icon: Icon(Icons.psychology_outlined), text: 'Extracción NER'),
            Tab(icon: Icon(Icons.link_outlined), text: 'Entity Linking'),
          ],
        ),
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: widget.investigationId,
        currentPhase: InvestigationPhase.processing,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          // Collected Data Tab
          _buildDataTab(),

          // Deduplication Tab
          Padding(
            padding: const EdgeInsets.all(24),
            child: DeduplicationWidget(
              investigationId: widget.investigationId,
            ),
          ),

          // NER Extraction Tab
          Padding(
            padding: const EdgeInsets.all(24),
            child: NERExtractionWidget(
              investigationId: widget.investigationId,
            ),
          ),

          // Entity Linking Tab
          Padding(
            padding: const EdgeInsets.all(24),
            child: EntityLinkingWidget(
              investigationId: widget.investigationId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Gestión de Datos Recopilados',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Aquí podrás ver, crear, editar y eliminar todos los datos\nrecopilados durante la fase de recopilación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Funcionalidad en desarrollo - Próximamente'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Datos'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Procesamiento'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'La fase de procesamiento te ayuda a organizar y analizar tus datos recopilados:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Text('• Deduplicación: Encuentra y combina registros duplicados'),
              SizedBox(height: 8),
              Text('• Extracción NER: Extrae entidades del texto usando IA'),
              SizedBox(height: 8),
              Text('• Entity Linking: Convierte formularios en entidades y crea relaciones'),
              SizedBox(height: 16),
              Text(
                'Nota: La extracción NER requiere que el backend de Python esté en ejecución (ver ner_backend/README.md)',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
