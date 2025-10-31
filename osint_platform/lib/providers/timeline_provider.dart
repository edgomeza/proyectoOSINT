import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline_event.dart';
import '../services/elasticsearch_service.dart';
import '../services/logstash_service.dart';

/// State Notifier for managing timeline events
class TimelineEventsNotifier extends StateNotifier<List<TimelineEvent>> {
  final ElasticsearchService _elasticsearchService;
  final LogstashService _logstashService;
  static const String _eventsIndex = 'osint-timeline-events';

  TimelineEventsNotifier(this._elasticsearchService, this._logstashService) : super([]) {
    _loadFromElasticsearch();
  }

  /// Load all events from Elasticsearch
  Future<void> _loadFromElasticsearch() async {
    try {
      final result = await _elasticsearchService.search(
        _eventsIndex,
        size: 10000,
        sort: [
          {'timestamp': 'asc'}
        ],
      );

      if (result.documents.isNotEmpty) {
        final events = result.documents
            .map((doc) => TimelineEvent.fromJson(doc.data))
            .toList();
        state = events;
      }
    } catch (e) {
      // If index doesn't exist or error occurs, start with empty state
      state = [];
    }
  }

  Future<void> addEvent(TimelineEvent event) async {
    state = [...state, event];
    _sortByTimestamp();

    // Persist to Elasticsearch
    await _elasticsearchService.indexDocument(
      _eventsIndex,
      event.toJson(),
      documentId: event.id,
    );

    // Log to Logstash
    await _logstashService.sendEvent(
      investigationId: event.investigationId,
      phase: 'analysis',
      eventType: 'timeline_event_created',
      data: event.toJson(),
    );
  }

  Future<void> updateEvent(TimelineEvent updatedEvent) async {
    state = [
      for (final event in state)
        if (event.id == updatedEvent.id) updatedEvent else event,
    ];
    _sortByTimestamp();

    // Update in Elasticsearch
    await _elasticsearchService.indexDocument(
      _eventsIndex,
      updatedEvent.toJson(),
      documentId: updatedEvent.id,
    );

    // Log to Logstash
    await _logstashService.sendEvent(
      investigationId: updatedEvent.investigationId,
      phase: 'analysis',
      eventType: 'timeline_event_updated',
      data: updatedEvent.toJson(),
    );
  }

  Future<void> removeEvent(String eventId) async {
    final event = getEventById(eventId);
    state = state.where((event) => event.id != eventId).toList();

    // Delete from Elasticsearch
    await _elasticsearchService.deleteDocument(_eventsIndex, eventId);

    // Log to Logstash
    if (event != null) {
      await _logstashService.sendEvent(
        investigationId: event.investigationId,
        phase: 'analysis',
        eventType: 'timeline_event_deleted',
        data: {'eventId': eventId, 'eventTitle': event.title},
      );
    }
  }

  void clearEvents() {
    state = [];
  }

  void _sortByTimestamp() {
    state = [...state]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  TimelineEvent? getEventById(String id) {
    try {
      return state.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  List<TimelineEvent> getEventsByType(TimelineEventType type) {
    return state.where((event) => event.type == type).toList();
  }

  List<TimelineEvent> getEventsByPriority(EventPriority priority) {
    return state.where((event) => event.priority == priority).toList();
  }

  List<TimelineEvent> getEventsByDateRange(DateTime start, DateTime end) {
    return state.where((event) {
      return event.timestamp.isAfter(start) && event.timestamp.isBefore(end);
    }).toList();
  }

  List<TimelineEvent> searchEvents(String query) {
    final lowerQuery = query.toLowerCase();
    return state.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          (event.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          event.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get events related to a specific entity
  List<TimelineEvent> getEventsForEntity(String entityId) {
    return state.where((event) => event.entityIds.contains(entityId)).toList();
  }

  /// Get events with location data
  List<TimelineEvent> getEventsWithLocation() {
    return state.where((event) {
      return event.latitude != null && event.longitude != null;
    }).toList();
  }
}

/// Provider for timeline events
final timelineEventsProvider =
    StateNotifierProvider<TimelineEventsNotifier, List<TimelineEvent>>((ref) {
  return TimelineEventsNotifier(
    ElasticsearchService(),
    LogstashService(),
  );
});

/// Derived provider: Get events by investigation ID
final eventsByInvestigationProvider =
    Provider.family<List<TimelineEvent>, String>((ref, investigationId) {
  final events = ref.watch(timelineEventsProvider);
  return events.where((event) => event.investigationId == investigationId).toList();
});

/// Derived provider: Get critical and high priority events
final highPriorityEventsProvider = Provider<List<TimelineEvent>>((ref) {
  final events = ref.watch(timelineEventsProvider);
  return events
      .where((event) =>
          event.priority == EventPriority.critical ||
          event.priority == EventPriority.high)
      .toList();
});

/// Derived provider: Timeline statistics
final timelineStatsProvider = Provider<TimelineStats>((ref) {
  final events = ref.watch(timelineEventsProvider);

  return TimelineStats(
    totalEvents: events.length,
    eventsByType: _countByType(events),
    eventsByPriority: _countByPriority(events),
    eventsWithLocation: events.where((e) => e.latitude != null).length,
  );
});

Map<TimelineEventType, int> _countByType(List<TimelineEvent> events) {
  final counts = <TimelineEventType, int>{};
  for (final event in events) {
    counts[event.type] = (counts[event.type] ?? 0) + 1;
  }
  return counts;
}

Map<EventPriority, int> _countByPriority(List<TimelineEvent> events) {
  final counts = <EventPriority, int>{};
  for (final event in events) {
    counts[event.priority] = (counts[event.priority] ?? 0) + 1;
  }
  return counts;
}

class TimelineStats {
  final int totalEvents;
  final Map<TimelineEventType, int> eventsByType;
  final Map<EventPriority, int> eventsByPriority;
  final int eventsWithLocation;

  TimelineStats({
    required this.totalEvents,
    required this.eventsByType,
    required this.eventsByPriority,
    required this.eventsWithLocation,
  });
}
