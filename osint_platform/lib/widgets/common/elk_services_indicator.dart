import 'package:flutter/material.dart';
import 'dart:async';

enum ServiceState {
  stopped,    // Rojo
  starting,   // Naranja
  running,    // Verde
}

class ELKServicesIndicator extends StatefulWidget {
  const ELKServicesIndicator({super.key});

  @override
  State<ELKServicesIndicator> createState() => _ELKServicesIndicatorState();
}

class _ELKServicesIndicatorState extends State<ELKServicesIndicator> {
  ServiceState _elasticsearchState = ServiceState.stopped;
  ServiceState _kibanaState = ServiceState.stopped;
  ServiceState _logstashState = ServiceState.stopped;

  @override
  void initState() {
    super.initState();
    _startServices();
  }

  Future<void> _startServices() async {
    // Simular inicio de servicios
    // En producción, esto ejecutaría docker-compose o comandos reales

    // Iniciar Elasticsearch
    setState(() {
      _elasticsearchState = ServiceState.starting;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _elasticsearchState = ServiceState.running;
        _logstashState = ServiceState.starting;
      });
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _logstashState = ServiceState.running;
        _kibanaState = ServiceState.starting;
      });
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _kibanaState = ServiceState.running;
      });
    }
  }

  Color _getStateColor(ServiceState state) {
    switch (state) {
      case ServiceState.stopped:
        return Colors.red;
      case ServiceState.starting:
        return Colors.orange;
      case ServiceState.running:
        return Colors.green;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          _buildServiceDot('ES', _elasticsearchState),
          const SizedBox(width: 6),
          _buildServiceDot('LS', _logstashState),
          const SizedBox(width: 6),
          _buildServiceDot('KB', _kibanaState),
        ],
      ),
    );
  }

  Widget _buildServiceDot(String label, ServiceState state) {
    return Tooltip(
      message: '$label: ${_getStateText(state)}',
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
                        color: _getStateColor(state).withValues(alpha:0.5),
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
