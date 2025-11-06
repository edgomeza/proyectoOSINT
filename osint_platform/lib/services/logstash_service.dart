import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// Servicio para enviar datos a Logstash
class LogstashService {
  static final LogstashService _instance = LogstashService._internal();
  factory LogstashService() => _instance;
  LogstashService._internal();

  late Dio _dio;
  String _host = 'localhost';
  int _port = 5000;
  bool _isInitialized = false;

  /// Inicializa el servicio Logstash
  void initialize({
    String host = 'localhost',
    int port = 5000,
  }) {
    _host = host;
    _port = port;

    final options = BaseOptions(
      baseUrl: 'http://$_host:$_port',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio = Dio(options);
    _isInitialized = true;
  }

  /// Verifica si el servicio está inicializado
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('LogstashService not initialized. Call initialize() first.');
    }
  }

  /// Envía un evento a Logstash
  Future<bool> sendEvent({
    required String investigationId,
    required String phase,
    required String eventType,
    required Map<String, dynamic> data,
    Map<String, dynamic>? metadata,
  }) async {
    _checkInitialized();

    try {
      final event = {
        'investigation_id': investigationId,
        'phase': phase,
        'event_type': eventType,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'data': data,
        if (metadata != null) 'metadata': metadata,
        'source_type': 'osint_platform',
      };

      final response = await _dio.post(
        '/',
        data: jsonEncode(event),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending event to Logstash: $e');
      return false;
    }
  }

  /// Envía un formulario de datos de recopilación
  Future<bool> sendDataForm({
    required String investigationId,
    required String formId,
    required String category,
    required String status,
    required Map<String, dynamic> fields,
    Map<String, dynamic>? additionalData,
  }) async {
    return sendEvent(
      investigationId: investigationId,
      phase: 'collection',
      eventType: 'data_form',
      data: {
        'form_id': formId,
        'category': category,
        'status': status,
        'fields': fields,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  /// Envía datos de procesamiento
  Future<bool> sendProcessingData({
    required String investigationId,
    required String processingType,
    required Map<String, dynamic> data,
  }) async {
    return sendEvent(
      investigationId: investigationId,
      phase: 'processing',
      eventType: processingType,
      data: data,
    );
  }

  /// Envía datos de análisis
  Future<bool> sendAnalysisData({
    required String investigationId,
    required String analysisType,
    required Map<String, dynamic> results,
  }) async {
    return sendEvent(
      investigationId: investigationId,
      phase: 'analysis',
      eventType: analysisType,
      data: results,
    );
  }

  /// Envía eventos de eliminación
  Future<bool> sendDeletionEvent({
    required String investigationId,
    required String phase,
    required String itemType,
    required String itemId,
    String? reason,
  }) async {
    return sendEvent(
      investigationId: investigationId,
      phase: phase,
      eventType: 'deletion',
      data: {
        'item_type': itemType,
        'item_id': itemId,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Envía eventos de edición
  Future<bool> sendEditEvent({
    required String investigationId,
    required String phase,
    required String itemType,
    required String itemId,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  }) async {
    return sendEvent(
      investigationId: investigationId,
      phase: phase,
      eventType: 'edit',
      data: {
        'item_type': itemType,
        'item_id': itemId,
        'old_data': oldData,
        'new_data': newData,
        'changed_fields': _getChangedFields(oldData, newData),
      },
    );
  }

  /// Compara dos mapas y devuelve las claves que han cambiado
  List<String> _getChangedFields(
    Map<String, dynamic> oldData,
    Map<String, dynamic> newData,
  ) {
    final changedFields = <String>[];

    for (final key in {...oldData.keys, ...newData.keys}) {
      final oldValue = oldData[key];
      final newValue = newData[key];

      if (oldValue != newValue) {
        changedFields.add(key);
      }
    }

    return changedFields;
  }

  /// Envía múltiples eventos en lote
  Future<bool> sendBatchEvents(List<Map<String, dynamic>> events) async {
    _checkInitialized();

    try {
      for (final event in events) {
        await _dio.post(
          '/',
          data: jsonEncode(event),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error sending batch events to Logstash: $e');
      return false;
    }
  }

  /// Verifica la conectividad con Logstash
  Future<bool> isHealthy() async {
    _checkInitialized();

    try {
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
