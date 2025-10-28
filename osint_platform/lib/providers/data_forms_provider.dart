import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/data_form.dart';
import '../models/data_form_status.dart';

// Notifier para gestionar formularios de datos
class DataFormsNotifier extends StateNotifier<List<DataForm>> {
  DataFormsNotifier() : super([]) {
    _loadMockData();
  }

  // Cargar datos de ejemplo
  void _loadMockData() {
    // En el futuro, esto cargará datos de una base de datos
    state = [];
  }

  // Agregar nuevo formulario
  void addDataForm(DataForm form) {
    state = [...state, form];
  }

  // Actualizar formulario existente
  void updateDataForm(String id, DataForm updatedForm) {
    state = [
      for (final form in state)
        if (form.id == id) updatedForm else form,
    ];
  }

  // Eliminar formulario
  void removeDataForm(String id) {
    state = state.where((form) => form.id != id).toList();
  }

  // Cambiar estado de formulario
  void changeStatus(String id, DataFormStatus newStatus) {
    state = [
      for (final form in state)
        if (form.id == id)
          form.copyWith(status: newStatus)
        else
          form,
    ];
  }

  // Enviar formularios a procesamiento
  void sendToProcessing(List<String> formIds) {
    state = [
      for (final form in state)
        if (formIds.contains(form.id))
          form.copyWith(status: DataFormStatus.collected)
        else
          form,
    ];
  }

  // Marcar formularios como revisados
  void markAsReviewed(List<String> formIds) {
    state = [
      for (final form in state)
        if (formIds.contains(form.id))
          form.copyWith(status: DataFormStatus.reviewed)
        else
          form,
    ];
  }

  void update(DataForm cleaned) {}

  void remove(String id) {}
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
