import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investigation.dart';
import '../models/investigation_phase.dart';

// Notifier para gestionar la lista de investigaciones
class InvestigationsNotifier extends StateNotifier<List<Investigation>> {
  InvestigationsNotifier() : super([]) {
    _loadMockData();
  }

  // Cargar datos de ejemplo (en el futuro esto vendrá de una base de datos)
  void _loadMockData() {
    state = [
      Investigation(
        name: 'Investigación de Prueba 1',
        description: 'Esta es una investigación de ejemplo para demostrar la funcionalidad de la plataforma',
        currentPhase: InvestigationPhase.planning,
        objectives: [
          'Identificar fuentes de información relevantes',
          'Recopilar datos de redes sociales',
          'Analizar patrones de comportamiento',
        ],
        keyQuestions: [
          '¿Cuál es la identidad digital del sujeto?',
          '¿Qué conexiones tiene con otras entidades?',
        ],
        isActive: true,
        completeness: 0.35,
      ),
      Investigation(
        name: 'Análisis de Red Social',
        description: 'Investigación sobre patrones de interacción en plataformas sociales',
        currentPhase: InvestigationPhase.collection,
        objectives: [
          'Mapear red de contactos',
          'Identificar influencers clave',
        ],
        completeness: 0.60,
      ),
      Investigation(
        name: 'Verificación de Identidad',
        description: 'Proceso de verificación de identidad digital',
        currentPhase: InvestigationPhase.processing,
        objectives: [
          'Validar información personal',
          'Cruzar datos de múltiples fuentes',
        ],
        completeness: 0.75,
      ),
    ];
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
