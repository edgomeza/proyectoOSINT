import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entity_node.dart';
import '../models/relationship.dart';
import '../services/elasticsearch_service.dart';
import '../services/logstash_service.dart';

// Provider para entidades por investigación
final entitiesProvider = StateNotifierProvider.family<EntitiesNotifier, List<EntityNode>, String>(
  (ref, investigationId) => EntitiesNotifier(investigationId),
);

// Provider para relaciones por investigación
final relationshipsProvider = StateNotifierProvider.family<RelationshipsNotifier, List<Relationship>, String>(
  (ref, investigationId) => RelationshipsNotifier(investigationId),
);

// Notifier para gestionar entidades
class EntitiesNotifier extends StateNotifier<List<EntityNode>> {
  final String investigationId;
  final ElasticsearchService _esService = ElasticsearchService();
  final LogstashService _logstashService = LogstashService();
  final String _indexName = 'osint-entities';

  EntitiesNotifier(this.investigationId) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final exists = await _esService.indexExists(_indexName);
      if (!exists) {
        await _esService.createIndex(_indexName);
        debugPrint('✅ Índice $_indexName creado');
      }
      await loadEntities();
    } catch (e) {
      debugPrint('❌ Error al inicializar entities provider: $e');
      state = [];
    }
  }

  Future<void> loadEntities() async {
    try {
      final result = await _esService.search(
        _indexName,
        query: {
          'match': {'investigationId': investigationId}
        },
        size: 10000,
      );

      final entities = <EntityNode>[];
      for (final doc in result.documents) {
        try {
          final entity = EntityNode.fromJson(doc.data);
          entities.add(entity);
        } catch (e) {
          debugPrint('Error al parsear entidad ${doc.id}: $e');
        }
      }

      state = entities;
      debugPrint('✅ Cargadas ${entities.length} entidades desde Elasticsearch');
    } catch (e) {
      debugPrint('❌ Error al cargar entidades: $e');
      state = [];
    }
  }

  Future<void> addEntity(EntityNode entity) async {
    state = [...state, entity];

    try {
      await _esService.indexDocument(
        _indexName,
        {
          ...entity.toJson(),
          'investigationId': investigationId,
        },
        documentId: entity.id,
      );

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'entity_created',
        data: entity.toJson(),
      );

      debugPrint('✅ Entidad ${entity.id} guardada');
    } catch (e) {
      debugPrint('❌ Error al guardar entidad: $e');
    }
  }

  Future<void> updateEntity(EntityNode entity) async {
    state = [
      for (final e in state)
        if (e.id == entity.id) entity else e
    ];

    try {
      await _esService.updateDocument(
        _indexName,
        entity.id,
        {
          ...entity.toJson(),
          'investigationId': investigationId,
        },
      );

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'entity_updated',
        data: entity.toJson(),
      );

      debugPrint('✅ Entidad ${entity.id} actualizada');
    } catch (e) {
      debugPrint('❌ Error al actualizar entidad: $e');
    }
  }

  Future<void> deleteEntity(String entityId) async {
    state = state.where((e) => e.id != entityId).toList();

    try {
      await _esService.deleteDocument(_indexName, entityId);

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'entity_deleted',
        data: {'entityId': entityId},
      );

      debugPrint('✅ Entidad $entityId eliminada');
    } catch (e) {
      debugPrint('❌ Error al eliminar entidad: $e');
    }
  }
}

// Notifier para gestionar relaciones
class RelationshipsNotifier extends StateNotifier<List<Relationship>> {
  final String investigationId;
  final ElasticsearchService _esService = ElasticsearchService();
  final LogstashService _logstashService = LogstashService();
  final String _indexName = 'osint-relationships';

  RelationshipsNotifier(this.investigationId) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final exists = await _esService.indexExists(_indexName);
      if (!exists) {
        await _esService.createIndex(_indexName);
        debugPrint('✅ Índice $_indexName creado');
      }
      await loadRelationships();
    } catch (e) {
      debugPrint('❌ Error al inicializar relationships provider: $e');
      state = [];
    }
  }

  Future<void> loadRelationships() async {
    try {
      final result = await _esService.search(
        _indexName,
        query: {
          'match': {'investigationId': investigationId}
        },
        size: 10000,
      );

      final relationships = <Relationship>[];
      for (final doc in result.documents) {
        try {
          final relationship = Relationship.fromJson(doc.data);
          relationships.add(relationship);
        } catch (e) {
          debugPrint('Error al parsear relación ${doc.id}: $e');
        }
      }

      state = relationships;
      debugPrint('✅ Cargadas ${relationships.length} relaciones desde Elasticsearch');
    } catch (e) {
      debugPrint('❌ Error al cargar relaciones: $e');
      state = [];
    }
  }

  Future<void> addRelationship(Relationship relationship) async {
    state = [...state, relationship];

    try {
      await _esService.indexDocument(
        _indexName,
        {
          ...relationship.toJson(),
          'investigationId': investigationId,
        },
        documentId: relationship.id,
      );

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'relationship_created',
        data: relationship.toJson(),
      );

      debugPrint('✅ Relación ${relationship.id} guardada');
    } catch (e) {
      debugPrint('❌ Error al guardar relación: $e');
    }
  }

  Future<void> updateRelationship(Relationship relationship) async {
    state = [
      for (final r in state)
        if (r.id == relationship.id) relationship else r
    ];

    try {
      await _esService.updateDocument(
        _indexName,
        relationship.id,
        {
          ...relationship.toJson(),
          'investigationId': investigationId,
        },
      );

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'relationship_updated',
        data: relationship.toJson(),
      );

      debugPrint('✅ Relación ${relationship.id} actualizada');
    } catch (e) {
      debugPrint('❌ Error al actualizar relación: $e');
    }
  }

  Future<void> deleteRelationship(String relationshipId) async {
    state = state.where((r) => r.id != relationshipId).toList();

    try {
      await _esService.deleteDocument(_indexName, relationshipId);

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'relationship_deleted',
        data: {'relationshipId': relationshipId},
      );

      debugPrint('✅ Relación $relationshipId eliminada');
    } catch (e) {
      debugPrint('❌ Error al eliminar relación: $e');
    }
  }
}
