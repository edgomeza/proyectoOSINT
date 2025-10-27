import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

enum ServiceStatus {
  running('En ejecución', Colors.green, Icons.check_circle),
  stopped('Detenido', Colors.red, Icons.cancel),
  error('Error', Colors.orange, Icons.error),
  unknown('Desconocido', Colors.grey, Icons.help);

  final String displayName;
  final Color color;
  final IconData icon;

  const ServiceStatus(this.displayName, this.color, this.icon);
}

class ServiceInfo {
  final String name;
  final String displayName;
  final ServiceStatus status;
  final String? version;
  final String? port;
  final String? url;

  const ServiceInfo({
    required this.name,
    required this.displayName,
    required this.status,
    this.version,
    this.port,
    this.url,
  });
}

class ServiceStatusCard extends StatelessWidget {
  final ServiceInfo service;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onOpenUrl;

  const ServiceStatusCard({
    super.key,
    required this.service,
    this.onStart,
    this.onStop,
    this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: service.status.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: service.status.color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: service.status.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    service.status.icon,
                    color: service.status.color,
                    size: 24,
                  ),
                ],
              ),
              if (service.version != null || service.port != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (service.version != null)
                      _buildInfoChip(
                        icon: Icons.info_outline,
                        label: 'v${service.version}',
                      ),
                    if (service.port != null)
                      _buildInfoChip(
                        icon: Icons.settings_ethernet,
                        label: 'Puerto ${service.port}',
                      ),
                  ],
                ),
              ],
              if (service.url != null ||
                  onStart != null ||
                  onStop != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (service.url != null && onOpenUrl != null)
                      _buildActionButton(
                        icon: Icons.open_in_new,
                        label: 'Abrir',
                        color: Colors.blue,
                        onTap: onOpenUrl!,
                      ),
                    if (service.status == ServiceStatus.stopped && onStart != null)
                      _buildActionButton(
                        icon: Icons.play_arrow,
                        label: 'Iniciar',
                        color: Colors.green,
                        onTap: onStart!,
                      ),
                    if (service.status == ServiceStatus.running && onStop != null)
                      _buildActionButton(
                        icon: Icons.stop,
                        label: 'Detener',
                        color: Colors.red,
                        onTap: onStop!,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
