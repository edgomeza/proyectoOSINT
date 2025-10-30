import 'dart:convert';
import 'package:dio/dio.dart';

class ElasticsearchDocument {
  final String id;
  final Map<String, dynamic> data;

  ElasticsearchDocument({
    required this.id,
    required this.data,
  });

  factory ElasticsearchDocument.fromJson(Map<String, dynamic> json) {
    return ElasticsearchDocument(
      id: json['_id'] as String,
      data: json['_source'] as Map<String, dynamic>,
    );
  }
}

class ElasticsearchSearchResult {
  final int totalHits;
  final List<ElasticsearchDocument> documents;

  ElasticsearchSearchResult({
    required this.totalHits,
    required this.documents,
  });
}

class ElasticsearchService {
  static final ElasticsearchService _instance = ElasticsearchService._internal();
  factory ElasticsearchService() => _instance;
  ElasticsearchService._internal();

  late Dio _dio;
  String _host = 'localhost';
  int _port = 9200;
  bool _isInitialized = false;

  /// Inicializa el servicio Elasticsearch
  void initialize({
    String host = 'localhost',
    int port = 9200,
    String? username,
    String? password,
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

    // Si hay credenciales, agregar autenticación básica
    if (username != null && password != null) {
      final auth = base64Encode(utf8.encode('$username:$password'));
      options.headers['Authorization'] = 'Basic $auth';
    }

    _dio = Dio(options);
    _isInitialized = true;
  }

  /// Verifica si el servicio está inicializado
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('ElasticsearchService not initialized. Call initialize() first.');
    }
  }

  /// Verifica el estado de salud de Elasticsearch
  Future<bool> isHealthy() async {
    _checkInitialized();

    try {
      final response = await _dio.get('/_cluster/health');
      if (response.statusCode == 200) {
        final status = response.data['status'] as String;
        return status == 'green' || status == 'yellow';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información del cluster
  Future<Map<String, dynamic>?> getClusterInfo() async {
    _checkInitialized();

    try {
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crea un índice
  Future<bool> createIndex(String indexName, {Map<String, dynamic>? mappings}) async {
    _checkInitialized();

    try {
      final body = <String, dynamic>{};

      if (mappings != null) {
        body['mappings'] = mappings;
      }

      // Configuración predeterminada para índices OSINT
      body['settings'] = {
        'number_of_shards': 1,
        'number_of_replicas': 0,
        'index': {
          'max_result_window': 50000,
        },
      };

      final response = await _dio.put(
        '/$indexName',
        data: body,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        // El índice puede ya existir
        final errorData = e.response?.data;
        if (errorData is Map && errorData['error']?['type'] == 'resource_already_exists_exception') {
          return true;
        }
      }
      return false;
    }
  }

  /// Verifica si un índice existe
  Future<bool> indexExists(String indexName) async {
    _checkInitialized();

    try {
      final response = await _dio.head('/$indexName');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un índice
  Future<bool> deleteIndex(String indexName) async {
    _checkInitialized();

    try {
      final response = await _dio.delete('/$indexName');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Indexa un documento (crea o actualiza)
  Future<String?> indexDocument(
    String indexName,
    Map<String, dynamic> document, {
    String? documentId,
  }) async {
    _checkInitialized();

    try {
      Response response;

      if (documentId != null) {
        // PUT con ID específico
        response = await _dio.put(
          '/$indexName/_doc/$documentId',
          data: document,
        );
      } else {
        // POST sin ID (Elasticsearch genera uno)
        response = await _dio.post(
          '/$indexName/_doc',
          data: document,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['_id'] as String;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Indexa múltiples documentos en lote (bulk)
  Future<bool> bulkIndexDocuments(
    String indexName,
    List<Map<String, dynamic>> documents,
  ) async {
    _checkInitialized();

    if (documents.isEmpty) return true;

    try {
      // Construir el payload de bulk
      final bulkPayload = StringBuffer();

      for (final document in documents) {
        final action = {'index': {'_index': indexName}};
        bulkPayload.writeln(jsonEncode(action));
        bulkPayload.writeln(jsonEncode(document));
      }

      final response = await _dio.post(
        '/_bulk',
        data: bulkPayload.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/x-ndjson',
          },
        ),
      );

      if (response.statusCode == 200) {
        final errors = response.data['errors'] as bool;
        return !errors;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene un documento por ID
  Future<ElasticsearchDocument?> getDocument(String indexName, String documentId) async {
    _checkInitialized();

    try {
      final response = await _dio.get('/$indexName/_doc/$documentId');

      if (response.statusCode == 200) {
        return ElasticsearchDocument.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Actualiza un documento
  Future<bool> updateDocument(
    String indexName,
    String documentId,
    Map<String, dynamic> updates,
  ) async {
    _checkInitialized();

    try {
      final response = await _dio.post(
        '/$indexName/_update/$documentId',
        data: {
          'doc': updates,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un documento
  Future<bool> deleteDocument(String indexName, String documentId) async {
    _checkInitialized();

    try {
      final response = await _dio.delete('/$indexName/_doc/$documentId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Busca documentos con una query simple
  Future<ElasticsearchSearchResult> search(
    String indexName, {
    String? query,
    Map<String, dynamic>? filters,
    int from = 0,
    int size = 10,
    List<Map<String, dynamic>>? sort,
  }) async {
    _checkInitialized();

    try {
      final body = <String, dynamic>{
        'from': from,
        'size': size,
      };

      // Construir la query
      if (query != null && query.isNotEmpty) {
        body['query'] = {
          'multi_match': {
            'query': query,
            'fields': ['*'],
            'type': 'best_fields',
          },
        };
      } else if (filters != null && filters.isNotEmpty) {
        body['query'] = {
          'bool': {
            'must': filters.entries.map((entry) {
              return {
                'term': {entry.key: entry.value},
              };
            }).toList(),
          },
        };
      } else {
        body['query'] = {
          'match_all': {},
        };
      }

      // Agregar ordenamiento si existe
      if (sort != null && sort.isNotEmpty) {
        body['sort'] = sort;
      }

      final response = await _dio.post(
        '/$indexName/_search',
        data: body,
      );

      if (response.statusCode == 200) {
        final hits = response.data['hits']['hits'] as List;
        final totalHits = response.data['hits']['total']['value'] as int;

        final documents = hits.map((hit) {
          return ElasticsearchDocument.fromJson(hit as Map<String, dynamic>);
        }).toList();

        return ElasticsearchSearchResult(
          totalHits: totalHits,
          documents: documents,
        );
      }

      return ElasticsearchSearchResult(totalHits: 0, documents: []);
    } catch (e) {
      return ElasticsearchSearchResult(totalHits: 0, documents: []);
    }
  }

  /// Busca con una query DSL completa
  Future<ElasticsearchSearchResult> advancedSearch(
    String indexName,
    Map<String, dynamic> queryDsl,
  ) async {
    _checkInitialized();

    try {
      final response = await _dio.post(
        '/$indexName/_search',
        data: queryDsl,
      );

      if (response.statusCode == 200) {
        final hits = response.data['hits']['hits'] as List;
        final totalHits = response.data['hits']['total']['value'] as int;

        final documents = hits.map((hit) {
          return ElasticsearchDocument.fromJson(hit as Map<String, dynamic>);
        }).toList();

        return ElasticsearchSearchResult(
          totalHits: totalHits,
          documents: documents,
        );
      }

      return ElasticsearchSearchResult(totalHits: 0, documents: []);
    } catch (e) {
      return ElasticsearchSearchResult(totalHits: 0, documents: []);
    }
  }

  /// Cuenta documentos que coinciden con una query
  Future<int> count(String indexName, {Map<String, dynamic>? query}) async {
    _checkInitialized();

    try {
      final body = query != null ? {'query': query} : {};

      final response = await _dio.post(
        '/$indexName/_count',
        data: body,
      );

      if (response.statusCode == 200) {
        return response.data['count'] as int;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Realiza una agregación
  Future<Map<String, dynamic>?> aggregate(
    String indexName,
    Map<String, dynamic> aggregations, {
    Map<String, dynamic>? query,
  }) async {
    _checkInitialized();

    try {
      final body = <String, dynamic>{
        'size': 0,
        'aggs': aggregations,
      };

      if (query != null) {
        body['query'] = query;
      }

      final response = await _dio.post(
        '/$indexName/_search',
        data: body,
      );

      if (response.statusCode == 200) {
        return response.data['aggregations'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Refresca un índice (hace los documentos inmediatamente disponibles para búsqueda)
  Future<bool> refreshIndex(String indexName) async {
    _checkInitialized();

    try {
      final response = await _dio.post('/$indexName/_refresh');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene estadísticas de un índice
  Future<Map<String, dynamic>?> getIndexStats(String indexName) async {
    _checkInitialized();

    try {
      final response = await _dio.get('/$indexName/_stats');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
