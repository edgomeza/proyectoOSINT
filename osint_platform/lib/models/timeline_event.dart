import 'package:uuid/uuid.dart';

/// Represents an event on the investigation timeline
class TimelineEvent {
  final String id;
  final String investigationId;
  final String title;
  final String? description;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TimelineEventType type;
  final EventPriority priority;
  final List<String> entityIds; // Related entity nodes
  final List<String> relationshipIds; // Related relationships
  final List<String> evidenceIds; // Supporting evidence
  final Map<String, dynamic> metadata;
  final String? location; // Optional location reference
  final double? latitude;
  final double? longitude;
  final List<String> tags;
  final double confidence;

  TimelineEvent({
    String? id,
    required this.investigationId,
    required this.title,
    this.description,
    required this.timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.type,
    this.priority = EventPriority.medium,
    this.entityIds = const [],
    this.relationshipIds = const [],
    this.evidenceIds = const [],
    this.metadata = const {},
    this.location,
    this.latitude,
    this.longitude,
    this.tags = const [],
    this.confidence = 1.0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TimelineEvent copyWith({
    String? title,
    String? description,
    DateTime? timestamp,
    DateTime? updatedAt,
    TimelineEventType? type,
    EventPriority? priority,
    List<String>? entityIds,
    List<String>? relationshipIds,
    List<String>? evidenceIds,
    Map<String, dynamic>? metadata,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? tags,
    double? confidence,
  }) {
    return TimelineEvent(
      id: id,
      investigationId: investigationId,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      type: type ?? this.type,
      priority: priority ?? this.priority,
      entityIds: entityIds ?? this.entityIds,
      relationshipIds: relationshipIds ?? this.relationshipIds,
      evidenceIds: evidenceIds ?? this.evidenceIds,
      metadata: metadata ?? this.metadata,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investigationId': investigationId,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type.name,
      'priority': priority.name,
      'entityIds': entityIds,
      'relationshipIds': relationshipIds,
      'evidenceIds': evidenceIds,
      'metadata': metadata,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'confidence': confidence,
    };
  }

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String,
      investigationId: json['investigationId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      type: TimelineEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TimelineEventType.other,
      ),
      priority: EventPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => EventPriority.medium,
      ),
      entityIds: (json['entityIds'] as List<dynamic>?)?.cast<String>() ?? [],
      relationshipIds: (json['relationshipIds'] as List<dynamic>?)?.cast<String>() ?? [],
      evidenceIds: (json['evidenceIds'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

enum TimelineEventType {
  meeting,
  transaction,
  communication,
  travel,
  registration,
  employment,
  investigation,
  arrest,
  court,
  social,
  publication,
  alert,
  discovery,
  other,
}

enum EventPriority {
  critical,
  high,
  medium,
  low,
}

extension TimelineEventTypeExtension on TimelineEventType {
  String get displayName {
    switch (this) {
      case TimelineEventType.meeting:
        return 'Reunión';
      case TimelineEventType.transaction:
        return 'Transacción';
      case TimelineEventType.communication:
        return 'Comunicación';
      case TimelineEventType.travel:
        return 'Viaje';
      case TimelineEventType.registration:
        return 'Registro';
      case TimelineEventType.employment:
        return 'Empleo';
      case TimelineEventType.investigation:
        return 'Investigación';
      case TimelineEventType.arrest:
        return 'Arresto';
      case TimelineEventType.court:
        return 'Tribunal';
      case TimelineEventType.social:
        return 'Social';
      case TimelineEventType.publication:
        return 'Publicación';
      case TimelineEventType.alert:
        return 'Alerta';
      case TimelineEventType.discovery:
        return 'Descubrimiento';
      case TimelineEventType.other:
        return 'Otro';
    }
  }
}

extension EventPriorityExtension on EventPriority {
  String get displayName {
    switch (this) {
      case EventPriority.critical:
        return 'Crítico';
      case EventPriority.high:
        return 'Alto';
      case EventPriority.medium:
        return 'Medio';
      case EventPriority.low:
        return 'Bajo';
    }
  }
}
