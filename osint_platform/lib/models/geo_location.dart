import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';

/// Represents a geographic location for mapping and analysis
class GeoLocation {
  final String id;
  final String investigationId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double? accuracy; // In meters
  final GeoLocationType type;
  final List<String> entityIds; // Related entities
  final List<String> eventIds; // Related events
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final List<String> tags;
  final double confidence;
  final LocationRisk risk;

  GeoLocation({
    String? id,
    required this.investigationId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.type,
    this.entityIds = const [],
    this.eventIds = const [],
    this.metadata = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.tags = const [],
    this.confidence = 1.0,
    this.risk = LocationRisk.unknown,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get as LatLng for flutter_map
  LatLng get latLng => LatLng(latitude, longitude);

  GeoLocation copyWith({
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? accuracy,
    GeoLocationType? type,
    List<String>? entityIds,
    List<String>? eventIds,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    List<String>? tags,
    double? confidence,
    LocationRisk? risk,
  }) {
    return GeoLocation(
      id: id,
      investigationId: investigationId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      type: type ?? this.type,
      entityIds: entityIds ?? this.entityIds,
      eventIds: eventIds ?? this.eventIds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
      risk: risk ?? this.risk,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investigationId': investigationId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'type': type.name,
      'entityIds': entityIds,
      'eventIds': eventIds,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'tags': tags,
      'confidence': confidence,
      'risk': risk.name,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      id: json['id'] as String,
      investigationId: json['investigationId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      type: GeoLocationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GeoLocationType.other,
      ),
      entityIds: (json['entityIds'] as List<dynamic>?)?.cast<String>() ?? [],
      eventIds: (json['eventIds'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      risk: LocationRisk.values.firstWhere(
        (e) => e.name == json['risk'],
        orElse: () => LocationRisk.unknown,
      ),
    );
  }
}

enum GeoLocationType {
  residence,
  business,
  office,
  meeting,
  event,
  incident,
  travel,
  checkpoint,
  poi, // Point of Interest
  surveillance,
  other,
}

enum LocationRisk {
  critical,
  high,
  medium,
  low,
  none,
  unknown,
}

extension GeoLocationTypeExtension on GeoLocationType {
  String get displayName {
    switch (this) {
      case GeoLocationType.residence:
        return 'Residence';
      case GeoLocationType.business:
        return 'Business';
      case GeoLocationType.office:
        return 'Office';
      case GeoLocationType.meeting:
        return 'Meeting';
      case GeoLocationType.event:
        return 'Event';
      case GeoLocationType.incident:
        return 'Incident';
      case GeoLocationType.travel:
        return 'Travel';
      case GeoLocationType.checkpoint:
        return 'Checkpoint';
      case GeoLocationType.poi:
        return 'Point of Interest';
      case GeoLocationType.surveillance:
        return 'Surveillance';
      case GeoLocationType.other:
        return 'Other';
    }
  }
}

extension LocationRiskExtension on LocationRisk {
  String get displayName {
    switch (this) {
      case LocationRisk.critical:
        return 'Critical';
      case LocationRisk.high:
        return 'High';
      case LocationRisk.medium:
        return 'Medium';
      case LocationRisk.low:
        return 'Low';
      case LocationRisk.none:
        return 'None';
      case LocationRisk.unknown:
        return 'Unknown';
    }
  }
}
