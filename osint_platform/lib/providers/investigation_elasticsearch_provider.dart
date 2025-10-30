import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/investigation_elasticsearch_service.dart';
import '../models/data_form.dart';
import '../models/data_form_status.dart';

/// Provider del servicio de Elasticsearch para investigaciones
final investigationElasticsearchServiceProvider =
    Provider<InvestigationElasticsearchService>((ref) {
  return InvestigationElasticsearchService();
});

/// Provider para buscar datos en una investigación
final investigationSearchProvider = FutureProvider.family
    .autoDispose<List<DataForm>, InvestigationSearchParams>((ref, params) async {
  final service = ref.read(investigationElasticsearchServiceProvider);

  return await service.searchInInvestigation(
    params.investigationId,
    query: params.query,
    category: params.category,
    status: params.status,
    tags: params.tags,
    startDate: params.startDate,
    endDate: params.endDate,
    minConfidence: params.minConfidence,
    minPriority: params.minPriority,
    from: params.from,
    size: params.size,
  );
});

/// Provider para obtener estadísticas de una investigación
final investigationStatsProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, investigationId) async {
  final service = ref.read(investigationElasticsearchServiceProvider);
  return await service.getInvestigationStats(investigationId);
});

/// Provider para obtener DataForms por estado
final formsByStatusProvider = FutureProvider.family
    .autoDispose<List<DataForm>, FormsByStatusParams>((ref, params) async {
  final service = ref.read(investigationElasticsearchServiceProvider);
  return await service.getFormsByStatus(
    params.investigationId,
    params.status,
    from: params.from,
    size: params.size,
  );
});

/// Provider para obtener DataForms por categoría
final formsByCategoryProvider = FutureProvider.family
    .autoDispose<List<DataForm>, FormsByCategoryParams>((ref, params) async {
  final service = ref.read(investigationElasticsearchServiceProvider);
  return await service.getFormsByCategory(
    params.investigationId,
    params.category,
    from: params.from,
    size: params.size,
  );
});

/// Provider para obtener DataForms de alta prioridad
final highPriorityFormsProvider = FutureProvider.family
    .autoDispose<List<DataForm>, HighPriorityParams>((ref, params) async {
  final service = ref.read(investigationElasticsearchServiceProvider);
  return await service.getHighPriorityForms(
    params.investigationId,
    limit: params.limit,
  );
});

/// Parámetros para búsqueda de investigaciones
class InvestigationSearchParams {
  final String investigationId;
  final String? query;
  final DataFormCategory? category;
  final DataFormStatus? status;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minConfidence;
  final int? minPriority;
  final int from;
  final int size;

  InvestigationSearchParams({
    required this.investigationId,
    this.query,
    this.category,
    this.status,
    this.tags,
    this.startDate,
    this.endDate,
    this.minConfidence,
    this.minPriority,
    this.from = 0,
    this.size = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestigationSearchParams &&
          runtimeType == other.runtimeType &&
          investigationId == other.investigationId &&
          query == other.query &&
          category == other.category &&
          status == other.status &&
          _listEquals(tags, other.tags) &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          minConfidence == other.minConfidence &&
          minPriority == other.minPriority &&
          from == other.from &&
          size == other.size;

  @override
  int get hashCode =>
      investigationId.hashCode ^
      query.hashCode ^
      category.hashCode ^
      status.hashCode ^
      tags.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      minConfidence.hashCode ^
      minPriority.hashCode ^
      from.hashCode ^
      size.hashCode;

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Parámetros para obtener formularios por estado
class FormsByStatusParams {
  final String investigationId;
  final DataFormStatus status;
  final int from;
  final int size;

  FormsByStatusParams({
    required this.investigationId,
    required this.status,
    this.from = 0,
    this.size = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormsByStatusParams &&
          runtimeType == other.runtimeType &&
          investigationId == other.investigationId &&
          status == other.status &&
          from == other.from &&
          size == other.size;

  @override
  int get hashCode =>
      investigationId.hashCode ^ status.hashCode ^ from.hashCode ^ size.hashCode;
}

/// Parámetros para obtener formularios por categoría
class FormsByCategoryParams {
  final String investigationId;
  final DataFormCategory category;
  final int from;
  final int size;

  FormsByCategoryParams({
    required this.investigationId,
    required this.category,
    this.from = 0,
    this.size = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormsByCategoryParams &&
          runtimeType == other.runtimeType &&
          investigationId == other.investigationId &&
          category == other.category &&
          from == other.from &&
          size == other.size;

  @override
  int get hashCode =>
      investigationId.hashCode ^ category.hashCode ^ from.hashCode ^ size.hashCode;
}

/// Parámetros para obtener formularios de alta prioridad
class HighPriorityParams {
  final String investigationId;
  final int limit;

  HighPriorityParams({
    required this.investigationId,
    this.limit = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighPriorityParams &&
          runtimeType == other.runtimeType &&
          investigationId == other.investigationId &&
          limit == other.limit;

  @override
  int get hashCode => investigationId.hashCode ^ limit.hashCode;
}
