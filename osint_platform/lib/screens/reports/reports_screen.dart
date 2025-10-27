import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/navigation_drawer.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../models/investigation_phase.dart';

class ReportsScreen extends ConsumerWidget {
  final String investigationId;

  const ReportsScreen({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al inicio',
        ),
        title: const Text('Informes'),
      ),
      drawer: const AppNavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'En Mantenimiento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta funcionalidad estará disponible próximamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: investigationId,
        currentPhase: InvestigationPhase.reports,
      ),
    );
  }
}
