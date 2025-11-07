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
    debugPrint('🔄 Inicializando EntitiesProvider para investigación: $investigationId');
    try {
      final exists = await _esService.indexExists(_indexName);
      debugPrint('🔍 Verificando índice $_indexName: ${exists ? "existe" : "no existe"}');
      if (!exists) {
        await _esService.createIndex(_indexName);
        debugPrint('✅ Índice $_indexName creado');
      }
      await loadEntities();
    } catch (e, stackTrace) {
      debugPrint('❌ Error al inicializar entities provider: $e');
      debugPrint('Stack trace: $stackTrace');
      state = [];
    }
  }

  Future<void> loadEntities() async {
    debugPrint('🔄 Cargando entidades para investigación: $investigationId');
    try {
      final result = await _esService.search(
        _indexName,
        filters: {
          'match': {'investigationId': investigationId}
        },
        size: 10000,
      );

      debugPrint('📊 Documentos encontrados: ${result.documents.length}');

      final entities = <EntityNode>[];
      for (final doc in result.documents) {
        try {
          final entity = EntityNode.fromJson(doc.data);
          entities.add(entity);
          debugPrint('  ✓ Entidad cargada: ${entity.label} (${entity.id})');
        } catch (e) {
          debugPrint('  ❌ Error al parsear entidad ${doc.id}: $e');
        }
      }

      state = entities;
      debugPrint('✅ Cargadas ${entities.length} entidades desde Elasticsearch');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar entidades: $e');
      debugPrint('Stack trace: $stackTrace');
      state = [];
    }
  }

  Future<void> addEntity(EntityNode entity) async {
    debugPrint('➕ Agregando entidad: ${entity.label} (${entity.id}) a investigación $investigationId');
    state = [...state, entity];

    try {
      final docData = {
        ...entity.toJson(),
        'investigationId': investigationId,
      };
      debugPrint('📝 Datos a guardar: ${docData.keys.join(", ")}');

      await _esService.indexDocument(
        _indexName,
        docData,
        documentId: entity.id,
      );

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'entity_created',
        data: entity.toJson(),
      );

      debugPrint('✅ Entidad ${entity.id} guardada en Elasticsearch');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al guardar entidad: $e');
      debugPrint('Stack trace: $stackTrace');
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
    debugPrint('🔄 Inicializando RelationshipsProvider para investigación: $investigationId');
    try {
      final exists = await _esService.indexExists(_indexName);
      debugPrint('🔍 Verificando índice $_indexName: ${exists ? "existe" : "no existe"}');
      if (!exists) {
        await _esService.createIndex(_indexName);
        debugPrint('✅ Índice $_indexName creado');
      }
      await loadRelationships();
    } catch (e, stackTrace) {
      debugPrint('❌ Error al inicializar relationships provider: $e');
      debugPrint('Stack trace: $stackTrace');
      state = [];
    }
  }

  Future<void> loadRelationships() async {
    debugPrint('🔄 Cargando relaciones para investigación: $investigationId');
    try {
      final result = await _esService.search(
        _indexName,
        filters: {
          'match': {'investigationId': investigationId}
        },
        size: 10000,
      );

      debugPrint('📊 Documentos encontrados: ${result.documents.length}');

      final relationships = <Relationship>[];
      for (final doc in result.documents) {
        try {
          final relationship = Relationship.fromJson(doc.data);
          relationships.add(relationship);
          debugPrint('  ✓ Relación cargada: ${relationship.type.displayName} (${relationship.id})');
        } catch (e) {
          debugPrint('  ❌ Error al parsear relación ${doc.id}: $e');
        }
      }

      state = relationships;
      debugPrint('✅ Cargadas ${relationships.length} relaciones desde Elasticsearch');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar relaciones: $e');
      debugPrint('Stack trace: $stackTrace');
      state = [];
    }
  }

  Future<void> addRelationship(Relationship relationship) async {
    debugPrint('➕ Agregando relación: ${relationship.type.displayName} (${relationship.id}) a investigación $investigationId');
    state = [...state, relationship];

    try {
      final docData = {
        ...relationship.toJson(),
        'investigationId': investigationId,
      };
      debugPrint('📝 Datos a guardar: ${docData.keys.join(", ")}');

      await _esService.indexDocument(
        _indexName,
        docData,
        documentId: relationship.id,
      );

      await _logstashService.sendEvent(
        investigationId: investigationId,
        phase: 'processing',
        eventType: 'relationship_created',
        data: relationship.toJson(),
      );

      debugPrint('✅ Relación ${relationship.id} guardada en Elasticsearch');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al guardar relación: $e');
      debugPrint('Stack trace: $stackTrace');
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
