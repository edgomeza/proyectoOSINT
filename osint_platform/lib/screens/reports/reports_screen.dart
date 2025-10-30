import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';
import '../../models/investigation_phase.dart';
import '../../providers/investigations_provider.dart';
import '../analysis/tabs/reports_tab.dart';
import '../../widgets/common/phase_navigation_buttons.dart';

class ReportsScreen extends ConsumerWidget {
  final String investigationId;

  const ReportsScreen({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigation = ref.watch(investigationByIdProvider(investigationId));

    if (investigation == null) {
      return AppLayoutWrapper(
        appBar: ModernAppBar(
          title: 'Informes',
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
              'Informes',
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
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: investigationId,
        currentPhase: InvestigationPhase.reports,
      ),
      child: FadeIn(
        child: ReportsTab(investigationId: investigationId),
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
                      Colors.red.shade400,
                      Colors.red.shade600,
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
              const Text('Ayuda - Informes'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'La fase de informes te permite crear y exportar reportes profesionales:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                Text('• Genera informes automáticos con toda la información recopilada'),
                SizedBox(height: 8),
                Text('• Personaliza las secciones que deseas incluir'),
                SizedBox(height: 8),
                Text('• Exporta en múltiples formatos (PDF, Word, HTML)'),
                SizedBox(height: 8),
                Text('• Incluye gráficos, timelines y mapas'),
                SizedBox(height: 16),
                Text(
                  'Consejo: Revisa y verifica toda la información antes de exportar el informe final.',
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
