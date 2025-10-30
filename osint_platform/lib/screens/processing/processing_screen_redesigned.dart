import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
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
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });
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
          child: FadeIn(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Investigación no encontrada',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Ir al inicio'),
                ),
              ],
            ),
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
          FadeIn(
            delay: const Duration(milliseconds: 300),
            child: IconButton(
              icon: const Icon(Icons.help_outline, size: 22),
              onPressed: () => _showHelpDialog(context),
              tooltip: 'Ayuda',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabChip(0, Icons.storage_outlined, 'Datos', Colors.blue),
                        const SizedBox(width: 8),
                        _buildTabChip(1, Icons.content_copy_outlined, 'Deduplicación', Colors.purple),
                        const SizedBox(width: 8),
                        _buildTabChip(2, Icons.psychology_outlined, 'NER', Colors.teal),
                        const SizedBox(width: 8),
                        _buildTabChip(3, Icons.link_outlined, 'Linking', Colors.orange),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: widget.investigationId,
        currentPhase: InvestigationPhase.processing,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDataTab(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FadeIn(
              child: DeduplicationWidget(
                investigationId: widget.investigationId,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FadeIn(
              child: NERExtractionWidget(
                investigationId: widget.investigationId,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FadeIn(
              child: EntityLinkingWidget(
                investigationId: widget.investigationId,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, IconData icon, String label, Color color) {
    final isSelected = _currentTab == index;

    return FadeIn(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: index * 100),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _tabController.animateTo(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [color, color.withAlpha(180)],
                    )
                  : null,
              color: isSelected ? null : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storage_outlined,
                  size: 64,
                  color: Colors.blue.shade600,
                ),
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
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Funcionalidad en desarrollo - Próximamente'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.blue[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Agregar Datos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
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
                    colors: [
                      Colors.purple.shade400,
                      Colors.purple.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Ayuda - Procesamiento'),
            ],
          ),
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
                Text('• Datos: Visualiza todos los formularios recopilados'),
                SizedBox(height: 8),
                Text('• Deduplicación: Encuentra y combina registros duplicados'),
                SizedBox(height: 8),
                Text('• NER: Extrae entidades del texto usando IA'),
                SizedBox(height: 8),
                Text('• Linking: Convierte formularios en entidades y crea relaciones'),
                SizedBox(height: 16),
                Text(
                  'Nota: La extracción NER requiere el backend de Python (ver ner_backend/README.md)',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      ),
    );
  }
}
