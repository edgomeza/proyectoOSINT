import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:osint_platform/models/investigation_phase.dart';
import '../../providers/investigations_provider.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/common/elk_services_indicator.dart';
import '../../models/investigation.dart';
import '../../models/investigation_status.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigations = ref.watch(investigationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: FadeInLeft(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plataforma OSINT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Investigaciones',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          const ELKServicesIndicator(),
          const SizedBox(width: 12),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: investigations.isEmpty
          ? _buildEmptyState(context, ref)
          : _buildInvestigationsGrid(context, ref, investigations),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateInvestigationDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Investigación'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No hay investigaciones',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu primera investigación para comenzar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateInvestigationDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Crear Investigación'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestigationsGrid(
    BuildContext context,
    WidgetRef ref,
    List<Investigation> investigations,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200
            ? 4
            : MediaQuery.of(context).size.width > 800
                ? 3
                : MediaQuery.of(context).size.width > 600
                    ? 2
                    : 1,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: investigations.length,
      itemBuilder: (context, index) {
        final investigation = investigations[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          child: _buildInvestigationCard(context, ref, investigation),
        );
      },
    );
  }

  Widget _buildInvestigationCard(
    BuildContext context,
    WidgetRef ref,
    Investigation investigation,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Activar la investigación antes de navegar
          ref.read(investigationsProvider.notifier).setActiveInvestigation(investigation.id);
          // Navegar a la fase actual
          final route = '/investigation/${investigation.id}/${investigation.currentPhase.routeName}';
          context.go(route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con indicador de estado
              Row(
                children: [
                  // Indicador de estado circular
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(investigation.status),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor(investigation.status)
                              .withValues(alpha:0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      investigation.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Descripción
              Text(
                investigation.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Fase actual
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  investigation.currentPhase.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: investigation.completeness,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 4),
              // Fecha y porcentaje
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(investigation.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    '${(investigation.completeness * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(InvestigationStatus status) {
    switch (status) {
      case InvestigationStatus.active:
        return Colors.green;
      case InvestigationStatus.inactive:
        return Colors.grey;
      case InvestigationStatus.closed:
        return Colors.red;
    }
  }

  void _showCreateInvestigationDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Investigación'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Fraude Corporativo XYZ',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Breve descripción del caso',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                final newInvestigation = Investigation(
                  name: nameController.text,
                  description: descriptionController.text,
                  status: InvestigationStatus.active,
                  isActive: true,
                  id: UniqueKey().toString(),
                  currentPhase: InvestigationPhase.planning,
                  createdAt: DateTime.now(), 
                  completeness: 0.0,
                );

                ref.read(investigationsProvider.notifier).addInvestigation(newInvestigation);

                Navigator.of(context).pop();

                context.go('/investigation/${newInvestigation.id}/planning');
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}