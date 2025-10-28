import 'package:dio/dio.dart';
import '../models/entity_node.dart';

/// Service for Named Entity Recognition using Python backend
class NERService {
  final Dio _dio;
  final String baseUrl;

  NERService({
    String? baseUrl,
  })  : baseUrl = baseUrl ?? 'http://localhost:5000',
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));

  /// Extract entities from text
  Future<NERResult> extractEntities(String text) async {
    try {
      final response = await _dio.post(
        '$baseUrl/ner/extract',
        data: {'text': text},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return NERResult.fromJson(data);
      } else {
        throw Exception('NER extraction failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('NER service timeout - check if Python backend is running');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to NER service at $baseUrl');
      } else {
        throw Exception('NER service error: ${e.message}');
      }
    } catch (e) {
      throw Exception('NER extraction error: $e');
    }
  }

  /// Check if NER service is available
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('$baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get supported entity types
  Future<List<String>> getSupportedTypes() async {
    try {
      final response = await _dio.get('$baseUrl/ner/types');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['types'] as List).cast<String>();
      } else {
        return _getDefaultTypes();
      }
    } catch (e) {
      return _getDefaultTypes();
    }
  }

  /// Convert NER entities to EntityNodes
  List<EntityNode> convertToEntityNodes(
    NERResult result, {
    required String investigationId,
  }) {
    final nodes = <EntityNode>[];

    for (final entity in result.entities) {
      final nodeType = _mapNERTypeToEntityType(entity.label);

      nodes.add(EntityNode(
        label: entity.text,
        type: nodeType,
        confidence: entity.confidence,
        description: 'Extracted from text via NER',
        tags: ['ner', entity.label.toLowerCase()],
        attributes: {
          'investigationId': investigationId,
          'source': 'ner',
          'originalLabel': entity.label,
          'startChar': entity.start,
          'endChar': entity.end,
        },
      ));
    }

    return nodes;
  }

  EntityNodeType _mapNERTypeToEntityType(String nerLabel) {
    switch (nerLabel.toUpperCase()) {
      case 'PERSON':
      case 'PER':
        return EntityNodeType.person;

      case 'ORG':
      case 'ORGANIZATION':
      case 'COMPANY':
        return EntityNodeType.company;

      case 'GPE':
      case 'LOC':
      case 'LOCATION':
        return EntityNodeType.location;

      case 'DATE':
      case 'TIME':
      case 'EVENT':
        return EntityNodeType.event;

      case 'EMAIL':
        return EntityNodeType.email;

      case 'PHONE':
      case 'PHONE_NUMBER':
        return EntityNodeType.phone;

      case 'URL':
      case 'WEBSITE':
        return EntityNodeType.website;

      case 'IP':
      case 'IP_ADDRESS':
        return EntityNodeType.ipAddress;

      default:
        return EntityNodeType.other;
    }
  }

  List<String> _getDefaultTypes() {
    return [
      'PERSON',
      'ORG',
      'GPE',
      'LOC',
      'DATE',
      'EMAIL',
      'PHONE',
      'URL',
    ];
  }
}

/// Result from NER extraction
class NERResult {
  final String text;
  final List<ExtractedEntity> entities;
  final Map<String, int> entityCounts;
  final String model;

  NERResult({
    required this.text,
    required this.entities,
    required this.entityCounts,
    required this.model,
  });

  factory NERResult.fromJson(Map<String, dynamic> json) {
    final entitiesList = (json['entities'] as List?)
            ?.map((e) => ExtractedEntity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final counts = (json['entity_counts'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as int)) ??
        {};

    return NERResult(
      text: json['text'] as String? ?? '',
      entities: entitiesList,
      entityCounts: counts,
      model: json['model'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'entities': entities.map((e) => e.toJson()).toList(),
      'entity_counts': entityCounts,
      'model': model,
    };
  }
}

/// An extracted entity from NER
class ExtractedEntity {
  final String text;
  final String label;
  final int start;
  final int end;
  final double confidence;

  ExtractedEntity({
    required this.text,
    required this.label,
    required this.start,
    required this.end,
    required this.confidence,
  });

  factory ExtractedEntity.fromJson(Map<String, dynamic> json) {
    return ExtractedEntity(
      text: json['text'] as String,
      label: json['label'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'label': label,
      'start': start,
      'end': end,
      'confidence': confidence,
    };
  }
}
