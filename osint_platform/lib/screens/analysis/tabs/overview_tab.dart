import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/investigations_provider.dart';
import '../../../providers/timeline_provider.dart';
import '../../../providers/geo_location_provider.dart';
import '../../../models/entity_node.dart';
import '../../../models/timeline_event.dart';

class OverviewTab extends ConsumerWidget {
  final String investigationId;

  const OverviewTab({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigation = ref.watch(
      investigationByIdProvider(investigationId),
    );
    final graphStats = ref.watch(graphStatsProvider);
    final timelineStats = ref.watch(timelineStatsProvider);
    final geoStats = ref.watch(geoStatsProvider);
    final highRiskNodes = ref.watch(highRiskNodesProvider);
    final highPriorityEvents = ref.watch(highPriorityEventsProvider);

    if (investigation == null) {
      return const Center(child: Text('Investigación no encontrada'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Investigation Summary Card
          _buildSummaryCard(context, investigation),
          const SizedBox(height: 16),

          // Statistics Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Entidades',
                  value: graphStats.totalNodes.toString(),
                  icon: Icons.hub,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Relaciones',
                  value: graphStats.totalRelationships.toString(),
                  icon: Icons.link,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Eventos de Línea de Tiempo',
                  value: timelineStats.totalEvents.toString(),
                  icon: Icons.timeline,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Ubicaciones',
                  value: geoStats.totalLocations.toString(),
                  icon: Icons.place,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Charts Section
          Text(
            'Análisis de Distribución',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Entity Type Distribution
          if (graphStats.nodesByType.isNotEmpty) ...[
            _buildChartCard(
              context,
              title: 'Entidades por Tipo',
              child: SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: _buildEntityTypeSections(
                      context,
                      graphStats.nodesByType,
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Event Priority Distribution
          if (timelineStats.eventsByPriority.isNotEmpty) ...[
            _buildChartCard(
              context,
              title: 'Eventos por Prioridad',
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: _buildEventPriorityBars(
                      timelineStats.eventsByPriority,
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const labels = ['Critical', 'High', 'Medium', 'Low'];
                            if (value.toInt() < labels.length) {
                              return Text(
                                labels[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Alerts Section
          if (highRiskNodes.isNotEmpty || highPriorityEvents.isNotEmpty) ...[
            Text(
              'Alertas y Elementos de Alta Prioridad',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            if (highRiskNodes.isNotEmpty) ...[
              _buildAlertCard(
                context,
                title: 'Entidades de Alto Riesgo',
                count: highRiskNodes.length,
                icon: Icons.warning,
                color: Colors.red,
                items: highRiskNodes.take(5).map((node) => node.label).toList(),
              ),
              const SizedBox(height: 12),
            ],

            if (highPriorityEvents.isNotEmpty) ...[
              _buildAlertCard(
                context,
                title: 'Eventos de Alta Prioridad',
                count: highPriorityEvents.length,
                icon: Icons.flag,
                color: Colors.orange,
                items: highPriorityEvents.take(5).map((e) => e.title).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, investigation) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investigation.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Created ${dateFormat.format(investigation.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    investigation.status.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(investigation.description),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: investigation.completeness,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Text(
              'Completeness: ${(investigation.completeness * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Card(
      color: color.withValues(alpha:0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
            if (count > items.length)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'And ${count - items.length} more...',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildEntityTypeSections(
    BuildContext context,
    Map<EntityNodeType, int> data,
  ) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.cyan,
      Colors.pink,
      Colors.amber,
    ];

    int index = 0;
    return data.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildEventPriorityBars(
    Map<dynamic, int> data,
  ) {
    // Order: Critical, High, Medium, Low
    final priorityOrder = [
      EventPriority.critical,
      EventPriority.high,
      EventPriority.medium,
      EventPriority.low
    ];
    final colors = [Colors.red, Colors.orange, Colors.blue, Colors.green];

    return List.generate(4, (index) {
      final priority = priorityOrder[index];
      final count = data.entries
          .firstWhere(
            (e) => e.key == priority,
            orElse: () => MapEntry(priority, 0),
          )
          .value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: colors[index],
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
