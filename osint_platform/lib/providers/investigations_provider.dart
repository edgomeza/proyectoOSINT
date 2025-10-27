import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investigation.dart';
import '../models/investigation_phase.dart';
import '../models/investigation_status.dart';

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
      Investigation(
        name: 'Fraude Corporativo',
        description: 'Investigación de posibles irregularidades financieras en empresa tecnológica',
        currentPhase: InvestigationPhase.analysis,
        objectives: [
          'Analizar transacciones sospechosas',
          'Identificar beneficiarios finales',
          'Rastrear flujo de fondos',
          'Documentar evidencias',
        ],
        keyQuestions: [
          '¿Existen operaciones offshore vinculadas?',
          '¿Quiénes son los verdaderos propietarios?',
          '¿Hay documentación falsificada?',
        ],
        completeness: 0.85,
      ),
      Investigation(
        name: 'Ciberseguridad - Incidente DDoS',
        description: 'Análisis de ataque distribuido de denegación de servicio',
        currentPhase: InvestigationPhase.collection,
        objectives: [
          'Identificar origen del ataque',
          'Mapear infraestructura utilizada',
          'Recopilar indicadores de compromiso (IOCs)',
        ],
        keyQuestions: [
          '¿Quién está detrás del ataque?',
          '¿Qué vectores se utilizaron?',
        ],
        completeness: 0.45,
      ),
      Investigation(
        name: 'Due Diligence - Merger & Acquisition',
        description: 'Investigación exhaustiva de empresa objetivo para proceso de adquisición',
        currentPhase: InvestigationPhase.reports,
        objectives: [
          'Verificar información financiera',
          'Evaluar reputación corporativa',
          'Identificar riesgos legales',
          'Analizar antecedentes de directivos',
          'Revisar historial de litigios',
        ],
        completeness: 0.95,
      ),
      Investigation(
        name: 'Fuga de Información Interna',
        description: 'Rastreo de filtración de documentos confidenciales',
        currentPhase: InvestigationPhase.processing,
        objectives: [
          'Identificar punto de fuga',
          'Analizar metadatos de documentos',
          'Revisar logs de acceso',
        ],
        keyQuestions: [
          '¿Quién tuvo acceso a los documentos?',
          '¿Cuándo se produjo la filtración?',
          '¿Existe complicidad externa?',
        ],
        completeness: 0.52,
      ),
      Investigation(
        name: 'Campaña de Desinformación',
        description: 'Análisis de red de cuentas coordinadas que difunden noticias falsas',
        currentPhase: InvestigationPhase.analysis,
        objectives: [
          'Mapear red de cuentas bot',
          'Identificar narrativas principales',
          'Rastrear origen del contenido',
          'Analizar patrones temporales',
        ],
        keyQuestions: [
          '¿Quién financia la campaña?',
          '¿Qué objetivo político tiene?',
        ],
        completeness: 0.68,
      ),
      Investigation(
        name: 'Blanqueo de Capitales - Criptomonedas',
        description: 'Seguimiento de transacciones sospechosas en blockchain',
        currentPhase: InvestigationPhase.collection,
        objectives: [
          'Rastrear direcciones wallet',
          'Identificar exchanges utilizados',
          'Mapear flujo de fondos',
        ],
        completeness: 0.40,
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
