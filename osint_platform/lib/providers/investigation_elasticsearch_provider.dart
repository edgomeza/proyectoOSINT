import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/investigation_elasticsearch_service.dart';
import '../models/data_form.dart';

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
    tags: params.tags,
    startDate: params.startDate,
    endDate: params.endDate,
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

/// Provider para obtener entidades por tipo en una investigación
final investigationEntitiesProvider = FutureProvider.family
    .autoDispose<Map<String, List<String>>, String>((ref, investigationId) async {
  final service = ref.read(investigationElasticsearchServiceProvider);
  return await service.getEntitiesByType(investigationId);
});

/// Parámetros para búsqueda de investigaciones
class InvestigationSearchParams {
  final String investigationId;
  final String? query;
  final String? category;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;
  final int from;
  final int size;

  InvestigationSearchParams({
    required this.investigationId,
    this.query,
    this.category,
    this.tags,
    this.startDate,
    this.endDate,
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
          tags == other.tags &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          from == other.from &&
          size == other.size;

  @override
  int get hashCode =>
      investigationId.hashCode ^
      query.hashCode ^
      category.hashCode ^
      tags.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      from.hashCode ^
      size.hashCode;
}
