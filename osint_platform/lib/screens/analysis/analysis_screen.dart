import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/navigation_drawer.dart';

class AnalysisScreen extends StatelessWidget {
  final String investigationId;

  const AnalysisScreen({
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
        title: const Text('Análisis'),
      ),
      drawer: const AppNavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.green.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pantalla de Análisis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Próximamente: Integración con Kibana y visualizaciones',
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
