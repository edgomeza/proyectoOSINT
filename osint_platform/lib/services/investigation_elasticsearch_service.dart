import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'elasticsearch_service.dart';
import '../models/investigation.dart';
import '../models/data_form.dart';

/// Servicio de alto nivel para gestionar investigaciones en Elasticsearch
class InvestigationElasticsearchService {
  static final InvestigationElasticsearchService _instance =
      InvestigationElasticsearchService._internal();
  factory InvestigationElasticsearchService() => _instance;
  InvestigationElasticsearchService._internal();

  final _elasticsearchService = ElasticsearchService();
  final _uuid = const Uuid();

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
        'type': {'type': 'keyword'},
        'title': {
          'type': 'text',
          'fields': {
            'keyword': {'type': 'keyword'},
          },
        },
        'description': {'type': 'text'},
        'content': {'type': 'text'},
        'metadata': {
          'type': 'object',
          'enabled': true,
        },
        'entities': {
          'type': 'nested',
          'properties': {
            'text': {'type': 'keyword'},
            'type': {'type': 'keyword'},
            'confidence': {'type': 'float'},
          },
        },
        'tags': {'type': 'keyword'},
        'source': {'type': 'keyword'},
        'url': {'type': 'keyword'},
        'author': {'type': 'keyword'},
        'location': {
          'type': 'object',
          'properties': {
            'latitude': {'type': 'float'},
            'longitude': {'type': 'float'},
            'name': {'type': 'keyword'},
          },
        },
        'timestamp': {'type': 'date'},
        'collectedAt': {'type': 'date'},
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
      // Si la investigación no existe, crear índice genérico
      await _elasticsearchService.createIndex(indexName);
    }

    // Convertir DataForm a documento Elasticsearch
    final document = {
      'id': dataForm.id,
      'investigationId': investigationId,
      'category': dataForm.category,
      'type': 'data_form',
      'title': dataForm.title,
      'description': dataForm.description,
      'content': dataForm.content,
      'metadata': dataForm.metadata,
      'tags': dataForm.tags ?? [],
      'source': dataForm.source,
      'url': dataForm.url,
      'author': dataForm.author,
      'timestamp': dataForm.timestamp?.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Agregar entidades si existen
    if (dataForm.entities != null && dataForm.entities!.isNotEmpty) {
      document['entities'] = dataForm.entities!.map((entity) {
        return {
          'text': entity.text,
          'type': entity.type,
          'confidence': entity.confidence,
        };
      }).toList();
    }

    // Agregar ubicación si existe
    if (dataForm.location != null) {
      document['location'] = {
        'latitude': dataForm.location!.latitude,
        'longitude': dataForm.location!.longitude,
        'name': dataForm.location!.name,
      };
    }

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
      final document = {
        'id': dataForm.id,
        'investigationId': investigationId,
        'category': dataForm.category,
        'type': 'data_form',
        'title': dataForm.title,
        'description': dataForm.description,
        'content': dataForm.content,
        'metadata': dataForm.metadata,
        'tags': dataForm.tags ?? [],
        'source': dataForm.source,
        'url': dataForm.url,
        'author': dataForm.author,
        'timestamp': dataForm.timestamp?.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (dataForm.entities != null && dataForm.entities!.isNotEmpty) {
        document['entities'] = dataForm.entities!.map((entity) {
          return {
            'text': entity.text,
            'type': entity.type,
            'confidence': entity.confidence,
          };
        }).toList();
      }

      if (dataForm.location != null) {
        document['location'] = {
          'latitude': dataForm.location!.latitude,
          'longitude': dataForm.location!.longitude,
          'name': dataForm.location!.name,
        };
      }

      return document;
    }).toList();

    return await _elasticsearchService.bulkIndexDocuments(indexName, documents);
  }

  /// Busca datos en una investigación
  Future<List<DataForm>> searchInInvestigation(
    String investigationId, {
    String? query,
    String? category,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
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
        {'createdAt': 'desc'},
      ],
    };

    final mustClauses = queryDsl['query']['bool']['must'] as List;
    final filterClauses = queryDsl['query']['bool']['filter'] as List;

    // Agregar búsqueda de texto si existe
    if (query != null && query.isNotEmpty) {
      mustClauses.add({
        'multi_match': {
          'query': query,
          'fields': ['title^3', 'description^2', 'content', 'metadata.*'],
          'type': 'best_fields',
        },
      });
    }

    // Filtrar por categoría
    if (category != null) {
      filterClauses.add({
        'term': {'category': category},
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
          'timestamp': <String, dynamic>{},
        },
      };

      if (startDate != null) {
        rangeFilter['range']['timestamp']['gte'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        rangeFilter['range']['timestamp']['lte'] = endDate.toIso8601String();
      }

      filterClauses.add(rangeFilter);
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
        'byTag': {},
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

    final byCategory = <String, int>{};
    if (categoryAgg != null && categoryAgg['categories'] != null) {
      final buckets = categoryAgg['categories']['buckets'] as List;
      for (final bucket in buckets) {
        byCategory[bucket['key'] as String] = bucket['doc_count'] as int;
      }
    }

    final byTag = <String, int>{};
    if (tagAgg != null && tagAgg['tags'] != null) {
      final buckets = tagAgg['tags']['buckets'] as List;
      for (final bucket in buckets) {
        byTag[bucket['key'] as String] = bucket['doc_count'] as int;
      }
    }

    return {
      'total': total,
      'byCategory': byCategory,
      'byTag': byTag,
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
      category: doc['category'] as String,
      title: doc['title'] as String,
      description: doc['description'] as String?,
      content: doc['content'] as String?,
      metadata: doc['metadata'] as Map<String, dynamic>?,
      tags: (doc['tags'] as List?)?.cast<String>(),
      source: doc['source'] as String?,
      url: doc['url'] as String?,
      author: doc['author'] as String?,
      timestamp: doc['timestamp'] != null
          ? DateTime.parse(doc['timestamp'] as String)
          : null,
      entities: doc['entities'] != null
          ? (doc['entities'] as List).map((e) {
              return Entity(
                text: e['text'] as String,
                type: e['type'] as String,
                confidence: (e['confidence'] as num?)?.toDouble() ?? 0.0,
              );
            }).toList()
          : null,
      location: doc['location'] != null
          ? Location(
              latitude: (doc['location']['latitude'] as num).toDouble(),
              longitude: (doc['location']['longitude'] as num).toDouble(),
              name: doc['location']['name'] as String?,
            )
          : null,
    );
  }

  /// Refresca el índice de una investigación
  Future<bool> refreshInvestigationIndex(String investigationId) async {
    final indexName = _getIndexName(investigationId);
    return await _elasticsearchService.refreshIndex(indexName);
  }

  /// Busca entidades en una investigación
  Future<Map<String, List<String>>> getEntitiesByType(String investigationId) async {
    final indexName = _getIndexName(investigationId);

    // Verificar si el índice existe
    final indexExists = await _elasticsearchService.indexExists(indexName);
    if (!indexExists) {
      return {};
    }

    // Obtener agregación por tipo de entidad
    final result = await _elasticsearchService.aggregate(
      indexName,
      {
        'entity_types': {
          'nested': {
            'path': 'entities',
          },
          'aggs': {
            'types': {
              'terms': {
                'field': 'entities.type',
                'size': 50,
              },
              'aggs': {
                'top_entities': {
                  'terms': {
                    'field': 'entities.text',
                    'size': 100,
                  },
                },
              },
            },
          },
        },
      },
    );

    final entitiesByType = <String, List<String>>{};

    if (result != null && result['entity_types'] != null) {
      final typeBuckets = result['entity_types']['types']['buckets'] as List;

      for (final typeBucket in typeBuckets) {
        final type = typeBucket['key'] as String;
        final entities = <String>[];

        final entityBuckets = typeBucket['top_entities']['buckets'] as List;
        for (final entityBucket in entityBuckets) {
          entities.add(entityBucket['key'] as String);
        }

        entitiesByType[type] = entities;
      }
    }

    return entitiesByType;
  }
}
