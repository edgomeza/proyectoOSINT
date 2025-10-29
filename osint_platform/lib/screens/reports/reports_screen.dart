import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Investigación no encontrada'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      );
    }

    return AppLayoutWrapper(
      appBar: ModernAppBar(
        title: 'Informes',
        subtitle: investigation.name,
        leading: const PhaseNavigationButtons(),
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: investigationId,
        currentPhase: InvestigationPhase.reports,
      ),
      child: ReportsTab(investigationId: investigationId),
    );
  }
}
