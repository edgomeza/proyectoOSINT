import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investigation.dart';
import '../models/investigation_phase.dart';
import '../models/investigation_status.dart';

// Notifier para gestionar la lista de investigaciones
class InvestigationsNotifier extends StateNotifier<List<Investigation>> {
  InvestigationsNotifier() : super([]) {
    _loadMockData();
  }

  // Ya no cargamos datos de ejemplo - los datos provienen de Elasticsearch
  void _loadMockData() {
    // Iniciar con lista vacía
    // El usuario debe crear sus propias investigaciones
    state = [];
  }

  // Agregar nueva investigación
  void addInvestigation(Investigation investigation) {
    state = [...state, investigation];
  }

  // Actualizar investigación existente
  void updateInvestigation(String id, Investigation updatedInvestigation) {
    state = [
      for (final investigation in state)
        if (investigation.id == id) updatedInvestigation else investigation,
    ];
  }

  // Eliminar investigación
  void removeInvestigation(String id) {
    state = state.where((investigation) => investigation.id != id).toList();
  }

  // Cambiar fase de investigación
  void changePhase(String id, InvestigationPhase newPhase) {
    state = [
      for (final investigation in state)
        if (investigation.id == id)
          investigation.copyWith(currentPhase: newPhase)
        else
          investigation,
    ];
  }

  // Establecer investigación activa
  void setActiveInvestigation(String id) {
    state = [
      for (final investigation in state)
        investigation.copyWith(isActive: investigation.id == id),
    ];
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
