import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

enum DashboardType {
  timeline('Timeline', Icons.timeline, 'Línea temporal de eventos'),
  network('Network', Icons.hub, 'Grafo de relaciones'),
  heatmap('Heatmap', Icons.map, 'Mapa de calor geográfico'),
  statistics('Statistics', Icons.bar_chart, 'Estadísticas generales'),
  sentiment('Sentiment', Icons.mood, 'Análisis de sentimiento'),
  activity('Activity', Icons.local_activity_outlined, 'Actividad temporal');

  final String displayName;
  final IconData icon;
  final String description;

  const DashboardType(this.displayName, this.icon, this.description);
}

class DashboardCard extends StatelessWidget {
  final DashboardType type;
  final int dataPoints;
  final DateTime lastUpdated;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const DashboardCard({
    super.key,
    required this.type,
    required this.dataPoints,
    required this.lastUpdated,
    this.onTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha:0.8),
                            colorScheme.secondary.withValues(alpha:0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        type.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (onRefresh != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: onRefresh,
                        tooltip: 'Actualizar',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type.icon,
                          size: 48,
                          color: colorScheme.primary.withValues(alpha:0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vista previa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(
                      icon: Icons.dataset,
                      label: '$dataPoints puntos',
                      color: colorScheme.primary,
                    ),
                    _buildInfoChip(
                      icon: Icons.update,
                      label: _formatTimeAgo(lastUpdated),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}
