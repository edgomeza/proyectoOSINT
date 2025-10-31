import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investigation.dart';
import '../models/investigation_phase.dart';
import '../services/elasticsearch_service.dart';
import '../services/logstash_service.dart';

// Notifier para gestionar la lista de investigaciones
class InvestigationsNotifier extends StateNotifier<List<Investigation>> {
  final ElasticsearchService _esService = ElasticsearchService();
  final LogstashService _logstashService = LogstashService();
  static const String _indexName = 'osint-investigations';

  InvestigationsNotifier() : super([]) {
    _initialize();
  }

  // Inicializa el índice y carga las investigaciones desde Elasticsearch
  Future<void> _initialize() async {
    try {
      // Crear el índice si no existe
      final exists = await _esService.indexExists(_indexName);
      if (!exists) {
        await _esService.createIndex(_indexName);
        debugPrint('✅ Índice $_indexName creado');
      }

      // Cargar investigaciones existentes
      await _loadFromElasticsearch();
    } catch (e) {
      debugPrint('❌ Error al inicializar investigations provider: $e');
      state = [];
    }
  }

  // Carga las investigaciones desde Elasticsearch
  Future<void> _loadFromElasticsearch() async {
    try {
      final result = await _esService.search(
        _indexName,
        size: 10000,
      );

      final investigations = <Investigation>[];
      for (final doc in result.documents) {
        try {
          final investigation = Investigation.fromJson(doc.data);
          investigations.add(investigation);
        } catch (e) {
          debugPrint('Error al parsear investigación ${doc.id}: $e');
        }
      }

      state = investigations;
      debugPrint('✅ Cargadas ${investigations.length} investigaciones desde Elasticsearch');
    } catch (e) {
      debugPrint('❌ Error al cargar investigaciones desde Elasticsearch: $e');
      state = [];
    }
  }

  // Método público para recargar datos desde Elasticsearch
  Future<void> reloadFromElasticsearch() async {
    await _loadFromElasticsearch();
  }

  // Agregar nueva investigación
  Future<void> addInvestigation(Investigation investigation) async {
    // Actualizar estado local primero (optimistic update)
    state = [...state, investigation];

    try {
      // Guardar en Elasticsearch
      await _esService.indexDocument(
        _indexName,
        investigation.toJson(),
        documentId: investigation.id,
      );

      // Enviar evento a Logstash
      await _logstashService.sendEvent(
        investigationId: investigation.id,
        phase: 'management',
        eventType: 'investigation_created',
        data: investigation.toJson(),
      );

      debugPrint('✅ Investigación ${investigation.id} guardada en Elasticsearch');
    } catch (e) {
      debugPrint('❌ Error al guardar investigación en Elasticsearch: $e');
    }
  }

  // Actualizar investigación existente
  Future<void> updateInvestigation(String id, Investigation updatedInvestigation) async {
    // Guardar el estado anterior para el log
    final oldInvestigation = state.firstWhere(
      (inv) => inv.id == id,
      orElse: () => updatedInvestigation,
    );

    // Actualizar estado local
    state = [
      for (final investigation in state)
        if (investigation.id == id) updatedInvestigation else investigation,
    ];

    try {
      // Actualizar en Elasticsearch
      await _esService.indexDocument(
        _indexName,
        updatedInvestigation.toJson(),
        documentId: id,
      );

      // Enviar evento de edición a Logstash
      await _logstashService.sendEditEvent(
        investigationId: id,
        phase: 'management',
        itemType: 'investigation',
        itemId: id,
        oldData: oldInvestigation.toJson(),
        newData: updatedInvestigation.toJson(),
      );

      debugPrint('✅ Investigación $id actualizada en Elasticsearch');
    } catch (e) {
      debugPrint('❌ Error al actualizar investigación en Elasticsearch: $e');
    }
  }

  // Eliminar investigación
  Future<void> removeInvestigation(String id) async {
    // Actualizar estado local
    state = state.where((investigation) => investigation.id != id).toList();

    try {
      // Eliminar de Elasticsearch
      await _esService.deleteDocument(_indexName, id);

      // Enviar evento de eliminación a Logstash
      await _logstashService.sendDeletionEvent(
        investigationId: id,
        phase: 'management',
        itemType: 'investigation',
        itemId: id,
      );

      debugPrint('✅ Investigación $id eliminada de Elasticsearch');
    } catch (e) {
      debugPrint('❌ Error al eliminar investigación de Elasticsearch: $e');
    }
  }

  // Cambiar fase de investigación
  Future<void> changePhase(String id, InvestigationPhase newPhase) async {
    final investigation = state.firstWhere(
      (inv) => inv.id == id,
      orElse: () => Investigation(name: 'Unknown', description: 'Unknown', id: id),
    );

    final updatedInvestigation = investigation.copyWith(currentPhase: newPhase);

    state = [
      for (final inv in state)
        if (inv.id == id) updatedInvestigation else inv,
    ];

    try {
      // Actualizar en Elasticsearch
      await _esService.updateDocument(_indexName, id, {'currentPhase': newPhase.name});

      // Enviar evento a Logstash
      await _logstashService.sendEvent(
        investigationId: id,
        phase: 'management',
        eventType: 'phase_changed',
        data: {
          'old_phase': investigation.currentPhase.name,
          'new_phase': newPhase.name,
        },
      );

      debugPrint('✅ Fase de investigación $id actualizada a ${newPhase.name}');
    } catch (e) {
      debugPrint('❌ Error al cambiar fase de investigación: $e');
    }
  }

  // Establecer investigación activa
  Future<void> setActiveInvestigation(String id) async {
    final previousActiveId = state
        .where((inv) => inv.isActive)
        .map((inv) => inv.id)
        .firstOrNull;

    state = [
      for (final investigation in state)
        investigation.copyWith(isActive: investigation.id == id),
    ];

    try {
      // Desactivar la investigación anterior si existe
      if (previousActiveId != null && previousActiveId != id) {
        await _esService.updateDocument(_indexName, previousActiveId, {'isActive': false});
      }

      // Activar la nueva investigación
      await _esService.updateDocument(_indexName, id, {'isActive': true});

      // Enviar evento a Logstash
      await _logstashService.sendEvent(
        investigationId: id,
        phase: 'management',
        eventType: 'investigation_activated',
        data: {
          'previous_active': previousActiveId,
          'new_active': id,
        },
      );

      debugPrint('✅ Investigación $id marcada como activa');
    } catch (e) {
      debugPrint('❌ Error al establecer investigación activa: $e');
    }
  }

  // Obtener investigación activa
  Investigation? get activeInvestigation {
    try {
      return state.firstWhere((investigation) => investigation.isActive);
    } catch (e) {
      return null;
    }
  }
}

// Provider de investigaciones
final investigationsProvider =
    StateNotifierProvider<InvestigationsNotifier, List<Investigation>>((ref) {
  return InvestigationsNotifier();
});

// Provider para investigación activa
final activeInvestigationProvider = Provider<Investigation?>((ref) {
  final investigations = ref.watch(investigationsProvider);
  try {
    return investigations.firstWhere((inv) => inv.isActive);
  } catch (e) {
    return null;
  }
});

// Provider para obtener una investigación específica por ID
final investigationByIdProvider = Provider.family<Investigation?, String>((ref, id) {
  final investigations = ref.watch(investigationsProvider);
  try {
    return investigations.firstWhere((inv) => inv.id == id);
  } catch (e) {
    return null;
  }
});

// Provider para contar investigaciones por fase
final investigationsByPhaseProvider = Provider.family<List<Investigation>, InvestigationPhase>((ref, phase) {
  final investigations = ref.watch(investigationsProvider);
  return investigations.where((inv) => inv.currentPhase == phase).toList();
});
