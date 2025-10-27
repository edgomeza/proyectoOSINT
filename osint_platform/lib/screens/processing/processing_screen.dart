import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/navigation_drawer.dart';

class ProcessingScreen extends StatelessWidget {
  final String investigationId;

  const ProcessingScreen({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al inicio',
        ),
        title: const Text('Procesamiento'),
      ),
      drawer: const AppNavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 80,
              color: Colors.purple.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pantalla de Procesamiento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Próximamente: Sistema de priorización y revisión de datos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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
    );
  }
}
