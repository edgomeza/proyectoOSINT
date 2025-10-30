import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/data_form.dart';
import '../models/data_form_status.dart';
import '../services/elasticsearch_service.dart';
import '../services/logstash_service.dart';

// Notifier para gestionar formularios de datos
class DataFormsNotifier extends StateNotifier<List<DataForm>> {
  final ElasticsearchService _esService = ElasticsearchService();
  final LogstashService _logstashService = LogstashService();

  DataFormsNotifier() : super([]) {
    _initializeServices();
    _loadFromElasticsearch();
  }

  // Inicializar servicios
  void _initializeServices() {
    _esService.initialize(host: 'localhost', port: 9200);
    _logstashService.initialize(host: 'localhost', port: 5000);
  }

  // Cargar datos desde Elasticsearch
  Future<void> _loadFromElasticsearch() async {
    try {
      // Buscar todos los documentos del índice osint-data-forms
      final result = await _esService.search(
        'osint-data-forms',
        size: 10000, // Cargar hasta 10000 documentos
      );

      // Convertir documentos de Elasticsearch a objetos DataForm
      final forms = <DataForm>[];
      for (final doc in result.documents) {
        try {
          final form = DataForm.fromJson(doc.data);
          forms.add(form);
        } catch (e) {
          debugPrint('Error al parsear formulario ${doc.id}: $e');
        }
      }

      // Actualizar el estado con los datos cargados
      state = forms;
      debugPrint('✅ Cargados ${forms.length} formularios desde Elasticsearch');
    } catch (e) {
      debugPrint('❌ Error al cargar datos desde Elasticsearch: $e');
      // Si hay error, mantener el estado vacío
      state = [];
    }
  }

  // Recargar datos desde Elasticsearch
  Future<void> reloadFromElasticsearch() async {
    await _loadFromElasticsearch();
  }

  // Agregar nuevo formulario
  Future<void> addDataForm(DataForm form) async {
    // Agregar al estado local
    state = [...state, form];

    // Enviar a Elasticsearch
    try {
      await _esService.indexDocument(
        'osint-data-forms',
        form.toJson(),
        documentId: form.id,
      );

      // Enviar a Logstash para análisis
      await _logstashService.sendDataForm(
        investigationId: form.investigationId,
        formId: form.id,
        category: form.category.name,
        status: form.status.name,
        fields: form.fields,
        additionalData: {
          'confidence': form.confidence,
          'priority': form.priority,
          'tags': form.tags,
          'notes': form.notes,
        },
      );
    } catch (e) {
      debugPrint('Error al guardar formulario en Elasticsearch: $e');
    }
  }

  // Actualizar formulario existente
  Future<void> updateDataForm(String id, DataForm updatedForm) async {
    final oldForm = state.firstWhere((form) => form.id == id);

    // Actualizar estado local
    state = [
      for (final form in state)
        if (form.id == id) updatedForm else form,
    ];

    // Actualizar en Elasticsearch
    try {
      await _esService.updateDocument(
        'osint-data-forms',
        id,
        updatedForm.toJson(),
      );

      // Enviar evento de edición a Logstash
      await _logstashService.sendEditEvent(
        investigationId: updatedForm.investigationId,
        phase: 'collection',
        itemType: 'data_form',
        itemId: id,
        oldData: oldForm.toJson(),
        newData: updatedForm.toJson(),
      );
    } catch (e) {
      debugPrint('Error al actualizar formulario en Elasticsearch: $e');
    }
  }

  // Eliminar formulario
  Future<void> removeDataForm(String id) async {
    final form = state.firstWhere((form) => form.id == id);

    // Eliminar del estado local
    state = state.where((form) => form.id != id).toList();

    // Eliminar de Elasticsearch
    try {
      await _esService.deleteDocument('osint-data-forms', id);

      // Enviar evento de eliminación a Logstash
      await _logstashService.sendDeletionEvent(
        investigationId: form.investigationId,
        phase: 'collection',
        itemType: 'data_form',
        itemId: id,
      );
    } catch (e) {
      debugPrint('Error al eliminar formulario de Elasticsearch: $e');
    }
  }

  // Cambiar estado de formulario
  Future<void> changeStatus(String id, DataFormStatus newStatus) async {
    final updatedForm = state.firstWhere((form) => form.id == id).copyWith(status: newStatus);
    await updateDataForm(id, updatedForm);
  }

  // Enviar formularios a procesamiento
  Future<void> sendToProcessing(List<String> formIds) async {
    for (final formId in formIds) {
      final form = state.firstWhere((f) => f.id == formId);
      final updatedForm = form.copyWith(status: DataFormStatus.sent);
      await updateDataForm(formId, updatedForm);

      // Enviar evento especial de transferencia a procesamiento
      await _logstashService.sendEvent(
        investigationId: form.investigationId,
        phase: 'processing',
        eventType: 'data_received_from_collection',
        data: form.toJson(),
      );
    }
  }

  // Marcar formularios como revisados
  Future<void> markAsReviewed(List<String> formIds) async {
    for (final formId in formIds) {
      await changeStatus(formId, DataFormStatus.reviewed);
    }
  }

  // Método update (alias de updateDataForm)
  Future<void> update(DataForm updatedForm) async {
    await updateDataForm(updatedForm.id, updatedForm);
  }

  // Método remove (alias de removeDataForm)
  Future<void> remove(String id) async {
    await removeDataForm(id);
  }
}

// Provider de formularios de datos
final dataFormsProvider =
    StateNotifierProvider<DataFormsNotifier, List<DataForm>>((ref) {
  return DataFormsNotifier();
});

// Provider para obtener formularios por investigación
final dataFormsByInvestigationProvider = Provider.family<List<DataForm>, String>((ref, investigationId) {
  final forms = ref.watch(dataFormsProvider);
  return forms.where((form) => form.investigationId == investigationId).toList();
});

// Provider para obtener formularios por estado
final dataFormsByStatusProvider = Provider.family<List<DataForm>, DataFormStatus>((ref, status) {
  final forms = ref.watch(dataFormsProvider);
  return forms.where((form) => form.status == status).toList();
});

// Provider para obtener formularios priorizados
final prioritizedDataFormsProvider = Provider.family<List<DataForm>, String>((ref, investigationId) {
  final forms = ref.watch(dataFormsByInvestigationProvider(investigationId));
  final sortedForms = List<DataForm>.from(forms);
  sortedForms.sort((a, b) => b.smartPriority.compareTo(a.smartPriority));
  return sortedForms;
});

// Provider para obtener formularios enviados a procesamiento
final processingDataFormsProvider = Provider.family<List<DataForm>, String>((ref, investigationId) {
  final forms = ref.watch(dataFormsByInvestigationProvider(investigationId));
  return forms.where((form) => form.status == DataFormStatus.sent).toList();
});
