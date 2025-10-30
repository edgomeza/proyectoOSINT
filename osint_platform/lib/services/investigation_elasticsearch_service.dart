import 'elasticsearch_service.dart';
import '../models/investigation.dart';
import '../models/data_form.dart';
import '../models/data_form_status.dart';

/// Servicio de alto nivel para gestionar investigaciones en Elasticsearch
class InvestigationElasticsearchService {
  static final InvestigationElasticsearchService _instance =
      InvestigationElasticsearchService._internal();
  factory InvestigationElasticsearchService() => _instance;
  InvestigationElasticsearchService._internal();

  final _elasticsearchService = ElasticsearchService();

  /// Obtiene el nombre del índice para una investigación
  String _getIndexName(String investigationId) {
    return 'osint-investigation-${investigationId.toLowerCase()}';
  }

  /// Inicializa el índice para una investigación
  Future<bool> initializeInvestigationIndex(Investigation investigation) async {
    final indexName = _getIndexName(investigation.id);

    // Definir el mapping para el índice
    final mappings = {
      'properties': {
        'id': {'type': 'keyword'},
        'investigationId': {'type': 'keyword'},
        'category': {'type': 'keyword'},
        'status': {'type': 'keyword'},
        'fields': {
          'type': 'object',
          'enabled': true,
        },
        'tags': {'type': 'keyword'},
        'notes': {'type': 'text'},
        'priority': {'type': 'integer'},
        'confidence': {'type': 'float'},
        'completeness': {'type': 'float'},
        'smartPriority': {'type': 'integer'},
        'createdAt': {'type': 'date'},
        'updatedAt': {'type': 'date'},
      },
    };

    return await _elasticsearchService.createIndex(indexName, mappings: mappings);
  }

  /// Indexa un DataForm en Elasticsearch
  Future<String?> indexDataForm(String investigationId, DataForm dataForm) async {
    final indexName = _getIndexName(investigationId);

    // Crear el índice si no existe
    final indexExists = await _elasticsearchService.indexExists(indexName);
    if (!indexExists) {
      await _elasticsearchService.createIndex(indexName);
    }

    // Convertir DataForm a documento Elasticsearch
    final document = {
      'id': dataForm.id,
      'investigationId': dataForm.investigationId,
      'category': dataForm.category.name,
      'status': dataForm.status.name,
      'fields': dataForm.fields,
      'tags': dataForm.tags,
      'notes': dataForm.notes,
      'priority': dataForm.priority,
      'confidence': dataForm.confidence,
      'completeness': dataForm.completeness,
      'smartPriority': dataForm.smartPriority,
      'createdAt': dataForm.createdAt.toIso8601String(),
      'updatedAt': dataForm.updatedAt.toIso8601String(),
    };

    return await _elasticsearchService.indexDocument(
      indexName,
      document,
      documentId: dataForm.id,
    );
  }

  /// Indexa múltiples DataForms en lote
  Future<bool> bulkIndexDataForms(
    String investigationId,
    List<DataForm> dataForms,
  ) async {
    final indexName = _getIndexName(investigationId);

    // Crear el índice si no existe
    final indexExists = await _elasticsearchService.indexExists(indexName);
    if (!indexExists) {
      await _elasticsearchService.createIndex(indexName);
    }

    final documents = dataForms.map((dataForm) {
      return {
        'id': dataForm.id,
        'investigationId': dataForm.investigationId,
        'category': dataForm.category.name,
        'status': dataForm.status.name,
        'fields': dataForm.fields,
        'tags': dataForm.tags,
        'notes': dataForm.notes,
        'priority': dataForm.priority,
        'confidence': dataForm.confidence,
        'completeness': dataForm.completeness,
        'smartPriority': dataForm.smartPriority,
        'createdAt': dataForm.createdAt.toIso8601String(),
        'updatedAt': dataForm.updatedAt.toIso8601String(),
      };
    }).toList();

    return await _elasticsearchService.bulkIndexDocuments(indexName, documents);
  }

  /// Busca datos en una investigación
  Future<List<DataForm>> searchInInvestigation(
    String investigationId, {
    String? query,
    DataFormCategory? category,
    DataFormStatus? status,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    double? minConfidence,
    int? minPriority,
    int from = 0,
    int size = 10,
  }) async {
    final indexName = _getIndexName(investigationId);

    // Verificar si el índice existe
    final indexExists = await _elasticsearchService.indexExists(indexName);
    if (!indexExists) {
      return [];
    }

    // Construir la query DSL
    final queryDsl = <String, dynamic>{
      'from': from,
      'size': size,
      'query': {
        'bool': {
          'must': <Map<String, dynamic>>[],
          'filter': <Map<String, dynamic>>[],
        },
      },
      'sort': [
        {'smartPriority': 'desc'},
        {'updatedAt': 'desc'},
      ],
    };

    final mustClauses = queryDsl['query']['bool']['must'] as List;
    final filterClauses = queryDsl['query']['bool']['filter'] as List;

    // Agregar búsqueda de texto si existe
    if (query != null && query.isNotEmpty) {
      mustClauses.add({
        'multi_match': {
          'query': query,
          'fields': ['fields.*', 'notes', 'tags'],
          'type': 'best_fields',
        },
      });
    }

    // Filtrar por categoría
    if (category != null) {
      filterClauses.add({
        'term': {'category': category.name},
      });
    }

    // Filtrar por estado
    if (status != null) {
      filterClauses.add({
        'term': {'status': status.name},
      });
    }

    // Filtrar por tags
    if (tags != null && tags.isNotEmpty) {
      filterClauses.add({
        'terms': {'tags': tags},
      });
    }

    // Filtrar por rango de fechas
    if (startDate != null || endDate != null) {
      final rangeFilter = <String, dynamic>{
        'range': {
          'updatedAt': <String, dynamic>{},
        },
      };

      if (startDate != null) {
        rangeFilter['range']['updatedAt']['gte'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        rangeFilter['range']['updatedAt']['lte'] = endDate.toIso8601String();
      }

      filterClauses.add(rangeFilter);
    }

    // Filtrar por confianza mínima
    if (minConfidence != null) {
      filterClauses.add({
        'range': {
          'confidence': {'gte': minConfidence},
        },
      });
    }

    // Filtrar por prioridad mínima
    if (minPriority != null) {
      filterClauses.add({
        'range': {
          'priority': {'gte': minPriority},
        },
      });
    }

    // Si no hay condiciones, buscar todo
    if (mustClauses.isEmpty && filterClauses.isEmpty) {
      queryDsl['query'] = {'match_all': {}};
    }

    final result = await _elasticsearchService.advancedSearch(indexName, queryDsl);

    // Convertir documentos a DataForms
    return result.documents.map((doc) {
      return _documentToDataForm(doc.data);
    }).toList();
  }

  /// Obtiene estadísticas de una investigación
  Future<Map<String, dynamic>> getInvestigationStats(String investigationId) async {
    final indexName = _getIndexName(investigationId);

    // Verificar si el índice existe
    final indexExists = await _elasticsearchService.indexExists(indexName);
    if (!indexExists) {
      return {
        'total': 0,
        'byCategory': {},
        'byStatus': {},
        'byTag': {},
        'avgConfidence': 0.0,
        'avgCompleteness': 0.0,
      };
    }

    // Obtener total de documentos
    final total = await _elasticsearchService.count(indexName);

    // Obtener agregación por categoría
    final categoryAgg = await _elasticsearchService.aggregate(
      indexName,
      {
        'categories': {
          'terms': {
            'field': 'category',
            'size': 50,
          },
        },
      },
    );

    // Obtener agregación por estado
    final statusAgg = await _elasticsearchService.aggregate(
      indexName,
      {
        'statuses': {
          'terms': {
            'field': 'status',
            'size': 50,
          },
        },
      },
    );

    // Obtener agregación por tags
    final tagAgg = await _elasticsearchService.aggregate(
      indexName,
      {
        'tags': {
          'terms': {
            'field': 'tags',
            'size': 100,
          },
        },
      },
    );

    // Obtener promedio de confianza y completitud
    final avgAgg = await _elasticsearchService.aggregate(
      indexName,
      {
        'avg_confidence': {
          'avg': {'field': 'confidence'},
        },
        'avg_completeness': {
          'avg': {'field': 'completeness'},
        },
      },
    );

    final byCategory = <String, int>{};
    if (categoryAgg != null && categoryAgg['categories'] != null) {
      final buckets = categoryAgg['categories']['buckets'] as List;
      for (final bucket in buckets) {
        byCategory[bucket['key'] as String] = bucket['doc_count'] as int;
      }
    }

    final byStatus = <String, int>{};
    if (statusAgg != null && statusAgg['statuses'] != null) {
      final buckets = statusAgg['statuses']['buckets'] as List;
      for (final bucket in buckets) {
        byStatus[bucket['key'] as String] = bucket['doc_count'] as int;
      }
    }

    final byTag = <String, int>{};
    if (tagAgg != null && tagAgg['tags'] != null) {
      final buckets = tagAgg['tags']['buckets'] as List;
      for (final bucket in buckets) {
        byTag[bucket['key'] as String] = bucket['doc_count'] as int;
      }
    }

    final avgConfidence = avgAgg?['avg_confidence']?['value'] as double? ?? 0.0;
    final avgCompleteness = avgAgg?['avg_completeness']?['value'] as double? ?? 0.0;

    return {
      'total': total,
      'byCategory': byCategory,
      'byStatus': byStatus,
      'byTag': byTag,
      'avgConfidence': avgConfidence,
      'avgCompleteness': avgCompleteness,
    };
  }

  /// Elimina todos los datos de una investigación
  Future<bool> deleteInvestigationData(String investigationId) async {
    final indexName = _getIndexName(investigationId);
    return await _elasticsearchService.deleteIndex(indexName);
  }

  /// Actualiza un DataForm en Elasticsearch
  Future<bool> updateDataForm(
    String investigationId,
    String dataFormId,
    Map<String, dynamic> updates,
  ) async {
    final indexName = _getIndexName(investigationId);

    // Agregar timestamp de actualización
    final updatesWithTimestamp = Map<String, dynamic>.from(updates);
    updatesWithTimestamp['updatedAt'] = DateTime.now().toIso8601String();

    return await _elasticsearchService.updateDocument(
      indexName,
      dataFormId,
      updatesWithTimestamp,
    );
  }

  /// Elimina un DataForm de Elasticsearch
  Future<bool> deleteDataForm(String investigationId, String dataFormId) async {
    final indexName = _getIndexName(investigationId);
    return await _elasticsearchService.deleteDocument(indexName, dataFormId);
  }

  /// Convierte un documento de Elasticsearch a DataForm
  DataForm _documentToDataForm(Map<String, dynamic> doc) {
    return DataForm(
      id: doc['id'] as String,
      investigationId: doc['investigationId'] as String,
      category: DataFormCategory.values.firstWhere(
        (cat) => cat.name == doc['category'],
        orElse: () => DataFormCategory.personalData,
      ),
      status: DataFormStatus.values.firstWhere(
        (stat) => stat.name == doc['status'],
        orElse: () => DataFormStatus.draft,
      ),
      fields: Map<String, dynamic>.from(doc['fields'] ?? {}),
      tags: List<String>.from(doc['tags'] ?? []),
      notes: doc['notes'] as String?,
      priority: doc['priority'] as int? ?? 0,
      confidence: (doc['confidence'] as num?)?.toDouble() ?? 0.5,
      createdAt: DateTime.parse(doc['createdAt'] as String),
      updatedAt: DateTime.parse(doc['updatedAt'] as String),
    );
  }

  /// Refresca el índice de una investigación
  Future<bool> refreshInvestigationIndex(String investigationId) async {
    final indexName = _getIndexName(investigationId);
    return await _elasticsearchService.refreshIndex(indexName);
  }

  /// Busca campos específicos en los DataForms
  Future<Map<String, List<dynamic>>> getFieldValues(
    String investigationId,
    List<String> fieldNames,
  ) async {
    final indexName = _getIndexName(investigationId);

    // Verificar si el índice existe
    final indexExists = await _elasticsearchService.indexExists(indexName);
    if (!indexExists) {
      return {};
    }

    final results = <String, List<dynamic>>{};

    for (final fieldName in fieldNames) {
      // Obtener agregación por campo
      final fieldAgg = await _elasticsearchService.aggregate(
        indexName,
        {
          'field_values': {
            'terms': {
              'field': 'fields.$fieldName.keyword',
              'size': 1000,
            },
          },
        },
      );

      final values = <dynamic>[];
      if (fieldAgg != null && fieldAgg['field_values'] != null) {
        final buckets = fieldAgg['field_values']['buckets'] as List;
        for (final bucket in buckets) {
          values.add(bucket['key']);
        }
      }

      results[fieldName] = values;
    }

    return results;
  }

  /// Busca DataForms por campo específico
  Future<List<DataForm>> searchByField(
    String investigationId,
    String fieldName,
    dynamic fieldValue, {
    int from = 0,
    int size = 10,
  }) async {
    final indexName = _getIndexName(investigationId);

    // Verificar si el índice existe
    final indexExists = await _elasticsearchService.indexExists(indexName);
    if (!indexExists) {
      return [];
    }

    final queryDsl = {
      'from': from,
      'size': size,
      'query': {
        'term': {
          'fields.$fieldName': fieldValue,
        },
      },
      'sort': [
        {'updatedAt': 'desc'},
      ],
    };

    final result = await _elasticsearchService.advancedSearch(indexName, queryDsl);

    return result.documents.map((doc) {
      return _documentToDataForm(doc.data);
    }).toList();
  }

  /// Obtiene los DataForms con mayor prioridad
  Future<List<DataForm>> getHighPriorityForms(
    String investigationId, {
    int limit = 10,
  }) async {
    return await searchInInvestigation(
      investigationId,
      size: limit,
    );
  }

  /// Obtiene DataForms por estado
  Future<List<DataForm>> getFormsByStatus(
    String investigationId,
    DataFormStatus status, {
    int from = 0,
    int size = 10,
  }) async {
    return await searchInInvestigation(
      investigationId,
      status: status,
      from: from,
      size: size,
    );
  }

  /// Obtiene DataForms por categoría
  Future<List<DataForm>> getFormsByCategory(
    String investigationId,
    DataFormCategory category, {
    int from = 0,
    int size = 10,
  }) async {
    return await searchInInvestigation(
      investigationId,
      category: category,
      from: from,
      size: size,
    );
  }
}
