import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/elk_stack_provider.dart';

class ELKServicesIndicator extends ConsumerWidget {
  const ELKServicesIndicator({super.key});

  Color _getStateColor(ServiceState state) {
    switch (state) {
      case ServiceState.stopped:
        return Colors.red;
      case ServiceState.starting:
        return Colors.orange;
      case ServiceState.running:
        return Colors.green;
      case ServiceState.error:
        return Colors.red.shade900;
    }
  }

  String _getStateText(ServiceState state) {
    switch (state) {
      case ServiceState.stopped:
        return 'Detenido';
      case ServiceState.starting:
        return 'Iniciando...';
      case ServiceState.running:
        return 'En ejecución';
      case ServiceState.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elkState = ref.watch(elkStackProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ELK:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          _buildServiceDot('ES', elkState.elasticsearch.state, elkState.elasticsearch.error),
          const SizedBox(width: 6),
          _buildServiceDot('LS', elkState.logstash.state, elkState.logstash.error),
          const SizedBox(width: 6),
          _buildServiceDot('KB', elkState.kibana.state, elkState.kibana.error),
        ],
      ),
    );
  }

  Widget _buildServiceDot(String label, ServiceState state, String? error) {
    final tooltipMessage = error != null
        ? '$label: ${_getStateText(state)} - $error'
        : '$label: ${_getStateText(state)}';

    return Tooltip(
      message: tooltipMessage,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStateColor(state),
              shape: BoxShape.circle,
              boxShadow: state == ServiceState.running
                  ? [
                      BoxShadow(
                        color: _getStateColor(state).withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
