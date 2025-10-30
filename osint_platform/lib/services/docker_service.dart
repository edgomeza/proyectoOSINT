import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:process_run/shell.dart';

enum DockerServiceStatus {
  stopped,
  starting,
  running,
  error,
}

class DockerServiceInfo {
  final String name;
  final DockerServiceStatus status;
  final String? error;

  DockerServiceInfo({
    required this.name,
    required this.status,
    this.error,
  });
}

class DockerService {
  static final DockerService _instance = DockerService._internal();
  factory DockerService() => _instance;
  DockerService._internal();

  String? _projectPath;
  Timer? _healthCheckTimer;

  final StreamController<Map<String, DockerServiceInfo>> _statusController =
      StreamController<Map<String, DockerServiceInfo>>.broadcast();

  Stream<Map<String, DockerServiceInfo>> get statusStream => _statusController.stream;

  Map<String, DockerServiceInfo> _currentStatus = {
    'elasticsearch': DockerServiceInfo(name: 'elasticsearch', status: DockerServiceStatus.stopped),
    'logstash': DockerServiceInfo(name: 'logstash', status: DockerServiceStatus.stopped),
    'kibana': DockerServiceInfo(name: 'kibana', status: DockerServiceStatus.stopped),
  };

  /// Inicializa el servicio Docker con la ruta del proyecto
  void initialize(String projectPath) {
    _projectPath = projectPath;
  }

  /// Verifica si Docker está disponible en el sistema
  Future<bool> isDockerAvailable() async {
    try {
      final result = await Process.run('docker', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si docker-compose está disponible en el sistema
  Future<bool> isDockerComposeAvailable() async {
    try {
      // Intentar primero con 'docker compose' (versión v2)
      final result = await Process.run('docker', ['compose', 'version']);
      if (result.exitCode == 0) return true;

      // Si falla, intentar con 'docker-compose' (versión v1)
      final resultV1 = await Process.run('docker-compose', ['--version']);
      return resultV1.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Inicia todos los servicios de la pila ELK
  Future<bool> startServices() async {
    if (_projectPath == null) {
      throw Exception('Docker service not initialized. Call initialize() first.');
    }

    try {
      // Verificar disponibilidad de Docker
      if (!await isDockerAvailable()) {
        _updateStatus('elasticsearch', DockerServiceStatus.error, 'Docker no está disponible');
        _updateStatus('logstash', DockerServiceStatus.error, 'Docker no está disponible');
        _updateStatus('kibana', DockerServiceStatus.error, 'Docker no está disponible');
        return false;
      }

      if (!await isDockerComposeAvailable()) {
        _updateStatus('elasticsearch', DockerServiceStatus.error, 'Docker Compose no está disponible');
        _updateStatus('logstash', DockerServiceStatus.error, 'Docker Compose no está disponible');
        _updateStatus('kibana', DockerServiceStatus.error, 'Docker Compose no está disponible');
        return false;
      }

      // Actualizar estado a "starting"
      _updateStatus('elasticsearch', DockerServiceStatus.starting);
      _updateStatus('logstash', DockerServiceStatus.starting);
      _updateStatus('kibana', DockerServiceStatus.starting);

      final shell = Shell(workingDirectory: _projectPath);

      // Verificar si los contenedores existen
      final containersExist = await _checkContainersExist();

      if (containersExist) {
        // Los contenedores existen, solo iniciarlos
        try {
          // Intentar con docker compose (v2)
          await shell.run('docker compose start');
        } catch (e) {
          // Si falla, intentar con docker-compose (v1)
          await shell.run('docker-compose start');
        }
      } else {
        // Los contenedores no existen, crearlos e iniciarlos
        try {
          // Intentar con docker compose (v2)
          await shell.run('docker compose up -d --remove-orphans');
        } catch (e) {
          // Si falla, intentar con docker-compose (v1)
          await shell.run('docker-compose up -d --remove-orphans');
        }
      }

      // Iniciar monitoreo de salud de los servicios
      _startHealthCheck();

      return true;
    } catch (e) {
      _updateStatus('elasticsearch', DockerServiceStatus.error, e.toString());
      _updateStatus('logstash', DockerServiceStatus.error, e.toString());
      _updateStatus('kibana', DockerServiceStatus.error, e.toString());
      return false;
    }
  }

  /// Verifica si los contenedores existen (creados pero posiblemente detenidos)
  Future<bool> _checkContainersExist() async {
    try {
      final result = await Process.run(
        'docker',
        ['ps', '-a', '--filter', 'name=osint_elasticsearch', '--format', '{{.Names}}'],
      );

      final output = result.stdout.toString().trim();
      return output.contains('osint_elasticsearch');
    } catch (e) {
      return false;
    }
  }

  /// Detiene todos los servicios de la pila ELK (sin eliminar contenedores)
  Future<bool> stopServices() async {
    if (_projectPath == null) {
      throw Exception('Docker service not initialized. Call initialize() first.');
    }

    try {
      // Detener monitoreo de salud
      _stopHealthCheck();

      // Ejecutar docker-compose stop (detiene sin eliminar contenedores)
      final shell = Shell(workingDirectory: _projectPath);

      try {
        // Intentar con docker compose (v2)
        await shell.run('docker compose stop');
      } catch (e) {
        // Si falla, intentar con docker-compose (v1)
        await shell.run('docker-compose stop');
      }

      // Actualizar estado a "stopped"
      _updateStatus('elasticsearch', DockerServiceStatus.stopped);
      _updateStatus('logstash', DockerServiceStatus.stopped);
      _updateStatus('kibana', DockerServiceStatus.stopped);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Detiene y elimina todos los contenedores de la pila ELK
  Future<bool> removeServices() async {
    if (_projectPath == null) {
      throw Exception('Docker service not initialized. Call initialize() first.');
    }

    try {
      // Detener monitoreo de salud
      _stopHealthCheck();

      // Ejecutar docker-compose down
      final shell = Shell(workingDirectory: _projectPath);

      try {
        // Intentar con docker compose (v2)
        await shell.run('docker compose down -v');
      } catch (e) {
        // Si falla, intentar con docker-compose (v1)
        await shell.run('docker-compose down -v');
      }

      // Actualizar estado a "stopped"
      _updateStatus('elasticsearch', DockerServiceStatus.stopped);
      _updateStatus('logstash', DockerServiceStatus.stopped);
      _updateStatus('kibana', DockerServiceStatus.stopped);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el estado de todos los contenedores
  Future<Map<String, DockerServiceInfo>> getServicesStatus() async {
    if (_projectPath == null) {
      throw Exception('Docker service not initialized. Call initialize() first.');
    }

    try {
      final shell = Shell(workingDirectory: _projectPath);
      List<ProcessResult> results;

      try {
        // Intentar con docker compose (v2)
        results = await shell.run('docker compose ps --format json');
      } catch (e) {
        // Si falla, intentar con docker-compose (v1)
        results = await shell.run('docker-compose ps --format json');
      }

      final output = results.first.stdout.toString();

      if (output.isEmpty) {
        // No hay contenedores en ejecución
        return {
          'elasticsearch': DockerServiceInfo(name: 'elasticsearch', status: DockerServiceStatus.stopped),
          'logstash': DockerServiceInfo(name: 'logstash', status: DockerServiceStatus.stopped),
          'kibana': DockerServiceInfo(name: 'kibana', status: DockerServiceStatus.stopped),
        };
      }

      // Parsear la salida JSON
      final status = <String, DockerServiceInfo>{};

      // El output puede ser una línea por contenedor
      final lines = output.trim().split('\n');

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        try {
          final json = jsonDecode(line);
          final name = (json['Service'] as String).toLowerCase();
          final state = (json['State'] as String).toLowerCase();

          DockerServiceStatus serviceStatus;
          if (state.contains('running')) {
            // Verificar health si existe
            final health = json['Health'] as String?;
            if (health != null && health.contains('starting')) {
              serviceStatus = DockerServiceStatus.starting;
            } else {
              serviceStatus = DockerServiceStatus.running;
            }
          } else if (state.contains('starting')) {
            serviceStatus = DockerServiceStatus.starting;
          } else {
            serviceStatus = DockerServiceStatus.stopped;
          }

          status[name] = DockerServiceInfo(
            name: name,
            status: serviceStatus,
          );
        } catch (e) {
          // Si falla el parseo de una línea, continuar con la siguiente
          continue;
        }
      }

      // Asegurar que todos los servicios estén en el mapa
      for (final service in ['elasticsearch', 'logstash', 'kibana']) {
        status.putIfAbsent(
          service,
          () => DockerServiceInfo(name: service, status: DockerServiceStatus.stopped),
        );
      }

      _currentStatus = status;
      _statusController.add(status);

      return status;
    } catch (e) {
      // En caso de error, retornar estado actual
      return _currentStatus;
    }
  }

  /// Verifica el estado de salud de un servicio específico
  Future<bool> isServiceHealthy(String serviceName) async {
    try {
      final shell = Shell(workingDirectory: _projectPath);
      final containerName = 'osint_$serviceName';

      final results = await shell.run(
        'docker inspect --format="{{.State.Health.Status}}" $containerName'
      );

      final healthStatus = results.first.stdout.toString().trim();
      return healthStatus == 'healthy' || healthStatus == '""' || healthStatus.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Inicia el monitoreo periódico del estado de los servicios
  void _startHealthCheck() {
    _stopHealthCheck();

    _healthCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await getServicesStatus();
    });
  }

  /// Detiene el monitoreo periódico del estado de los servicios
  void _stopHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  /// Actualiza el estado de un servicio específico
  void _updateStatus(String serviceName, DockerServiceStatus status, [String? error]) {
    _currentStatus[serviceName] = DockerServiceInfo(
      name: serviceName,
      status: status,
      error: error,
    );
    _statusController.add(_currentStatus);
  }

  /// Obtiene el estado actual sin consultar Docker
  Map<String, DockerServiceInfo> getCurrentStatus() {
    return Map.from(_currentStatus);
  }

  /// Limpia los recursos del servicio
  void dispose() {
    _stopHealthCheck();
    _statusController.close();
  }
}
