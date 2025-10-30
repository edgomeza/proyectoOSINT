import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/docker_service.dart';
import '../services/elasticsearch_service.dart';

/// Modelo para el estado de un servicio individual
class ServiceStatus {
  final String name;
  final ServiceState state;
  final String? error;

  ServiceStatus({
    required this.name,
    required this.state,
    this.error,
  });

  ServiceStatus copyWith({
    String? name,
    ServiceState? state,
    String? error,
  }) {
    return ServiceStatus(
      name: name ?? this.name,
      state: state ?? this.state,
      error: error ?? this.error,
    );
  }
}

/// Estados posibles de un servicio
enum ServiceState {
  stopped,
  starting,
  running,
  error,
}

/// Modelo para el estado completo de la pila ELK
class ELKStackState {
  final ServiceStatus elasticsearch;
  final ServiceStatus logstash;
  final ServiceStatus kibana;
  final bool isInitializing;
  final String? globalError;

  ELKStackState({
    required this.elasticsearch,
    required this.logstash,
    required this.kibana,
    this.isInitializing = false,
    this.globalError,
  });

  ELKStackState copyWith({
    ServiceStatus? elasticsearch,
    ServiceStatus? logstash,
    ServiceStatus? kibana,
    bool? isInitializing,
    String? globalError,
  }) {
    return ELKStackState(
      elasticsearch: elasticsearch ?? this.elasticsearch,
      logstash: logstash ?? this.logstash,
      kibana: kibana ?? this.kibana,
      isInitializing: isInitializing ?? this.isInitializing,
      globalError: globalError ?? this.globalError,
    );
  }

  factory ELKStackState.initial() {
    return ELKStackState(
      elasticsearch: ServiceStatus(name: 'elasticsearch', state: ServiceState.stopped),
      logstash: ServiceStatus(name: 'logstash', state: ServiceState.stopped),
      kibana: ServiceStatus(name: 'kibana', state: ServiceState.stopped),
      isInitializing: true,
    );
  }

  bool get allServicesRunning =>
      elasticsearch.state == ServiceState.running &&
      logstash.state == ServiceState.running &&
      kibana.state == ServiceState.running;

  bool get anyServiceStarting =>
      elasticsearch.state == ServiceState.starting ||
      logstash.state == ServiceState.starting ||
      kibana.state == ServiceState.starting;

  bool get anyServiceError =>
      elasticsearch.state == ServiceState.error ||
      logstash.state == ServiceState.error ||
      kibana.state == ServiceState.error;
}

/// Notifier para gestionar el estado de la pila ELK
class ELKStackNotifier extends StateNotifier<ELKStackState> {
  final DockerService _dockerService = DockerService();
  final ElasticsearchService _elasticsearchService = ElasticsearchService();
  StreamSubscription<Map<String, DockerServiceInfo>>? _statusSubscription;
  Timer? _healthCheckTimer;

  ELKStackNotifier() : super(ELKStackState.initial());

  /// Inicializa los servicios ELK
  Future<void> initialize(String projectPath) async {
    state = state.copyWith(isInitializing: true);

    try {
      // Inicializar servicio Docker
      _dockerService.initialize(projectPath);

      // Verificar disponibilidad de Docker
      final dockerAvailable = await _dockerService.isDockerAvailable();
      if (!dockerAvailable) {
        state = state.copyWith(
          isInitializing: false,
          globalError: 'Docker no está disponible en el sistema',
          elasticsearch: ServiceStatus(name: 'elasticsearch', state: ServiceState.error),
          logstash: ServiceStatus(name: 'logstash', state: ServiceState.error),
          kibana: ServiceStatus(name: 'kibana', state: ServiceState.error),
        );
        return;
      }

      final composeAvailable = await _dockerService.isDockerComposeAvailable();
      if (!composeAvailable) {
        state = state.copyWith(
          isInitializing: false,
          globalError: 'Docker Compose no está disponible en el sistema',
          elasticsearch: ServiceStatus(name: 'elasticsearch', state: ServiceState.error),
          logstash: ServiceStatus(name: 'logstash', state: ServiceState.error),
          kibana: ServiceStatus(name: 'kibana', state: ServiceState.error),
        );
        return;
      }

      // Inicializar servicio de Elasticsearch
      _elasticsearchService.initialize(
        host: 'localhost',
        port: 9200,
      );

      // Suscribirse a los cambios de estado de Docker
      _statusSubscription = _dockerService.statusStream.listen((status) {
        _updateStateFromDocker(status);
      });

      // Iniciar los servicios
      await startServices();

      state = state.copyWith(isInitializing: false);
    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        globalError: 'Error al inicializar: ${e.toString()}',
      );
    }
  }

  /// Inicia los servicios de la pila ELK
  Future<bool> startServices() async {
    final success = await _dockerService.startServices();

    if (!success) {
      state = state.copyWith(
        elasticsearch: ServiceStatus(name: 'elasticsearch', state: ServiceState.error),
        logstash: ServiceStatus(name: 'logstash', state: ServiceState.error),
        kibana: ServiceStatus(name: 'kibana', state: ServiceState.error),
      );
      return false;
    }

    // Iniciar monitoreo de salud
    _startHealthMonitoring();

    return true;
  }

  /// Detiene los servicios de la pila ELK
  Future<bool> stopServices() async {
    _stopHealthMonitoring();

    final success = await _dockerService.stopServices();

    if (success) {
      state = state.copyWith(
        elasticsearch: ServiceStatus(name: 'elasticsearch', state: ServiceState.stopped),
        logstash: ServiceStatus(name: 'logstash', state: ServiceState.stopped),
        kibana: ServiceStatus(name: 'kibana', state: ServiceState.stopped),
      );
    }

    return success;
  }

  /// Actualiza el estado desde los datos de Docker
  void _updateStateFromDocker(Map<String, DockerServiceInfo> dockerStatus) {
    state = state.copyWith(
      elasticsearch: ServiceStatus(
        name: 'elasticsearch',
        state: _mapDockerStatusToServiceState(dockerStatus['elasticsearch']?.status),
        error: dockerStatus['elasticsearch']?.error,
      ),
      logstash: ServiceStatus(
        name: 'logstash',
        state: _mapDockerStatusToServiceState(dockerStatus['logstash']?.status),
        error: dockerStatus['logstash']?.error,
      ),
      kibana: ServiceStatus(
        name: 'kibana',
        state: _mapDockerStatusToServiceState(dockerStatus['kibana']?.status),
        error: dockerStatus['kibana']?.error,
      ),
    );
  }

  /// Mapea el estado de Docker al estado del servicio
  ServiceState _mapDockerStatusToServiceState(DockerServiceStatus? status) {
    if (status == null) return ServiceState.stopped;

    switch (status) {
      case DockerServiceStatus.stopped:
        return ServiceState.stopped;
      case DockerServiceStatus.starting:
        return ServiceState.starting;
      case DockerServiceStatus.running:
        return ServiceState.running;
      case DockerServiceStatus.error:
        return ServiceState.error;
    }
  }

  /// Inicia el monitoreo de salud de Elasticsearch
  void _startHealthMonitoring() {
    _stopHealthMonitoring();

    // Verificar cada 5 segundos
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // Solo verificar si Elasticsearch está reportado como running
      if (state.elasticsearch.state == ServiceState.running) {
        final isHealthy = await _elasticsearchService.isHealthy();

        if (!isHealthy && state.elasticsearch.state == ServiceState.running) {
          // Si no está saludable pero está running, marcar como starting
          state = state.copyWith(
            elasticsearch: state.elasticsearch.copyWith(
              state: ServiceState.starting,
            ),
          );
        } else if (isHealthy && state.elasticsearch.state != ServiceState.running) {
          // Si está saludable pero no está marcado como running, actualizar
          state = state.copyWith(
            elasticsearch: state.elasticsearch.copyWith(
              state: ServiceState.running,
            ),
          );
        }
      }
    });
  }

  /// Detiene el monitoreo de salud
  void _stopHealthMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  /// Obtiene el servicio de Elasticsearch
  ElasticsearchService get elasticsearchService => _elasticsearchService;

  /// Limpia los recursos
  @override
  void dispose() {
    _stopHealthMonitoring();
    _statusSubscription?.cancel();
    _dockerService.dispose();
    super.dispose();
  }
}

/// Provider principal para la pila ELK
final elkStackProvider = StateNotifierProvider<ELKStackNotifier, ELKStackState>((ref) {
  return ELKStackNotifier();
});

/// Provider para verificar si todos los servicios están en ejecución
final allServicesRunningProvider = Provider<bool>((ref) {
  final elkState = ref.watch(elkStackProvider);
  return elkState.allServicesRunning;
});

/// Provider para verificar si algún servicio está iniciando
final anyServiceStartingProvider = Provider<bool>((ref) {
  final elkState = ref.watch(elkStackProvider);
  return elkState.anyServiceStarting;
});

/// Provider para verificar si hay algún error
final hasErrorProvider = Provider<bool>((ref) {
  final elkState = ref.watch(elkStackProvider);
  return elkState.anyServiceError || elkState.globalError != null;
});

/// Provider de acceso al servicio de Elasticsearch
final elasticsearchServiceProvider = Provider<ElasticsearchService>((ref) {
  final notifier = ref.read(elkStackProvider.notifier);
  return notifier.elasticsearchService;
});
