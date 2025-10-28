import 'package:uuid/uuid.dart';

/// Represents a node in the relationship graph
class EntityNode {
  final String id;
  final String label;
  final EntityNodeType type;
  final Map<String, dynamic> attributes;
  final double confidence;
  final List<String> tags;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RiskLevel riskLevel;

  // Visual properties
  final String? imageUrl;
  final String? iconData;

  // Graph position (for manual layout)
  double? x;
  double? y;

  EntityNode({
    String? id,
    required this.label,
    required this.type,
    this.attributes = const {},
    this.confidence = 1.0,
    this.tags = const [],
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.riskLevel = RiskLevel.unknown,
    this.imageUrl,
    this.iconData,
    this.x,
    this.y,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  EntityNode copyWith({
    String? label,
    EntityNodeType? type,
    Map<String, dynamic>? attributes,
    double? confidence,
    List<String>? tags,
    String? description,
    DateTime? updatedAt,
    RiskLevel? riskLevel,
    String? imageUrl,
    String? iconData,
    double? x,
    double? y,
  }) {
    return EntityNode(
      id: id,
      label: label ?? this.label,
      type: type ?? this.type,
      attributes: attributes ?? this.attributes,
      confidence: confidence ?? this.confidence,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      riskLevel: riskLevel ?? this.riskLevel,
      imageUrl: imageUrl ?? this.imageUrl,
      iconData: iconData ?? this.iconData,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'attributes': attributes,
      'confidence': confidence,
      'tags': tags,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'riskLevel': riskLevel.name,
      'imageUrl': imageUrl,
      'iconData': iconData,
      'x': x,
      'y': y,
    };
  }

  factory EntityNode.fromJson(Map<String, dynamic> json) {
    return EntityNode(
      id: json['id'] as String,
      label: json['label'] as String,
      type: EntityNodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EntityNodeType.other,
      ),
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => RiskLevel.unknown,
      ),
      imageUrl: json['imageUrl'] as String?,
      iconData: json['iconData'] as String?,
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
    );
  }
}

enum EntityNodeType {
  person,
  company,
  organization,
  socialNetwork,
  location,
  document,
  event,
  email,
  phone,
  website,
  ipAddress,
  cryptocurrency,
  vehicle,
  property,
  other,
}

enum RiskLevel {
  critical,
  high,
  medium,
  low,
  none,
  unknown,
}

extension EntityNodeTypeExtension on EntityNodeType {
  String get displayName {
    switch (this) {
      case EntityNodeType.person:
        return 'Person';
      case EntityNodeType.company:
        return 'Company';
      case EntityNodeType.organization:
        return 'Organization';
      case EntityNodeType.socialNetwork:
        return 'Social Network';
      case EntityNodeType.location:
        return 'Location';
      case EntityNodeType.document:
        return 'Document';
      case EntityNodeType.event:
        return 'Event';
      case EntityNodeType.email:
        return 'Email';
      case EntityNodeType.phone:
        return 'Phone';
      case EntityNodeType.website:
        return 'Website';
      case EntityNodeType.ipAddress:
        return 'IP Address';
      case EntityNodeType.cryptocurrency:
        return 'Cryptocurrency';
      case EntityNodeType.vehicle:
        return 'Vehicle';
      case EntityNodeType.property:
        return 'Property';
      case EntityNodeType.other:
        return 'Other';
    }
  }
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.critical:
        return 'Critical';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.none:
        return 'None';
      case RiskLevel.unknown:
        return 'Unknown';
    }
  }
}
