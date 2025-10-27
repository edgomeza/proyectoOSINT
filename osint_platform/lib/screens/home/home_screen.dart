import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../providers/investigations_provider.dart';
import '../../providers/view_mode_provider.dart';
import '../../widgets/cards/investigation_card.dart';
import '../../widgets/common/view_mode_toggle.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../models/investigation.dart';
import '../../models/investigation_phase.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigations = ref.watch(investigationsProvider);
    final viewMode = ref.watch(viewModeProvider);
    final activeInvestigation = ref.watch(activeInvestigationProvider);

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
                    'Centro de Control',
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
          const ThemeToggleButton(),
          IconButton(
            onPressed: () {
              // TODO: Implementar notificaciones
            },
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: Implementar refresh
            await Future.delayed(const Duration(seconds: 1));
          },
          child: viewMode == ViewMode.simple
              ? _buildSimpleView(context, ref, investigations, activeInvestigation)
              : _buildDetailedView(context, ref, investigations),
        ),
      ),
      floatingActionButton: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateInvestigationDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Investigación'),
        ),
      ),
    );
  }

  Widget _buildSimpleView(
    BuildContext context,
    WidgetRef ref,
    List<Investigation> investigations,
    Investigation? activeInvestigation,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FadeInDown(
                        child: Text(
                          'Vista Simplificada',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    const ViewModeToggle(),
                  ],
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Enfocado en lo esencial para mantener tu productividad',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (activeInvestigation != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  FadeInLeft(
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Investigación Activa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  InvestigationCard(
                    investigation: activeInvestigation,
                    isCompact: false,
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActions(context, activeInvestigation),
              ],
            ),
          ),
        ),
        if (investigations.length > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FadeInLeft(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Otras Investigaciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(viewModeProvider.notifier).state = ViewMode.detailed;
                      },
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (investigations.length > 1)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final otherInvestigations = investigations
                      .where((inv) => !inv.isActive)
                      .take(3)
                      .toList();
                  if (index >= otherInvestigations.length) return null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InvestigationCard(
                      investigation: otherInvestigations[index],
                      isCompact: true,
                      onTap: () {
                        ref.read(investigationsProvider.notifier)
                            .setActiveInvestigation(otherInvestigations[index].id);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildDetailedView(
    BuildContext context,
    WidgetRef ref,
    List<Investigation> investigations,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FadeInDown(
                        child: Text(
                          'Vista Detallada',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    const ViewModeToggle(),
                  ],
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Control completo de todas tus investigaciones',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStatsCards(context, investigations),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FadeInLeft(
              child: const Text(
                'Todas las Investigaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        if (investigations.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: FadeIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay investigaciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primera investigación para comenzar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= investigations.length) return null;
                  return InvestigationCard(
                    investigation: investigations[index],
                    isCompact: false,
                  );
                },
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Investigation? activeInvestigation) {
    if (activeInvestigation == null) {
      return FadeInUp(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No hay investigación activa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona una investigación para ver las acciones disponibles',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final actions = [
      {
        'icon': Icons.lightbulb_outline,
        'label': 'Planificación',
        'color': Colors.blue,
        'route': '/investigation/${activeInvestigation.id}/planning',
      },
      {
        'icon': Icons.collections_bookmark_outlined,
        'label': 'Recopilación',
        'color': Colors.orange,
        'route': '/investigation/${activeInvestigation.id}/collection',
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Procesamiento',
        'color': Colors.purple,
        'route': '/investigation/${activeInvestigation.id}/processing',
      },
    ];

    return Row(
      children: actions.map((action) {
        final index = actions.indexOf(action);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < actions.length - 1 ? 8 : 0,
            ),
            child: FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              child: Card(
                child: InkWell(
                  onTap: () => context.go(action['route'] as String),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withValues(alpha:0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          action['label'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsCards(BuildContext context, List<Investigation> investigations) {
    final stats = [
      {
        'label': 'Total',
        'value': investigations.length.toString(),
        'icon': Icons.folder_outlined,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'label': 'En Progreso',
        'value': investigations
            .where((inv) => inv.currentPhase != InvestigationPhase.reports)
            .length
            .toString(),
        'icon': Icons.trending_up,
        'color': Colors.orange,
      },
      {
        'label': 'Completadas',
        'value': investigations
            .where((inv) => inv.currentPhase == InvestigationPhase.reports)
            .length
            .toString(),
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
    ];

    return FadeInUp(
      child: Row(
        children: stats.map((stat) {
          final index = stats.indexOf(stat);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < stats.length - 1 ? 12 : 0,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCreateInvestigationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Investigación'),
        content: const Text(
          'La funcionalidad de crear investigaciones estará disponible en la pantalla de planificación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
