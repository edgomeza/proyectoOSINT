import 'package:uuid/uuid.dart';

/// Represents a relationship (edge) between two entities in the graph
class Relationship {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final RelationshipType type;
  final String label;
  final double confidence;
  final double weight; // For graph algorithms (shortest path, etc.)
  final Map<String, dynamic> attributes;
  final List<String> evidenceIds; // References to supporting documents/data
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final bool isDirected;

  Relationship({
    String? id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.type,
    String? label,
    this.confidence = 1.0,
    this.weight = 1.0,
    this.attributes = const {},
    this.evidenceIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.description,
    this.isDirected = true,
  })  : id = id ?? const Uuid().v4(),
        label = label ?? type.displayName,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Relationship copyWith({
    String? sourceNodeId,
    String? targetNodeId,
    RelationshipType? type,
    String? label,
    double? confidence,
    double? weight,
    Map<String, dynamic>? attributes,
    List<String>? evidenceIds,
    DateTime? updatedAt,
    String? description,
    bool? isDirected,
  }) {
    return Relationship(
      id: id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      type: type ?? this.type,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      weight: weight ?? this.weight,
      attributes: attributes ?? this.attributes,
      evidenceIds: evidenceIds ?? this.evidenceIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      description: description ?? this.description,
      isDirected: isDirected ?? this.isDirected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceNodeId': sourceNodeId,
      'targetNodeId': targetNodeId,
      'type': type.name,
      'label': label,
      'confidence': confidence,
      'weight': weight,
      'attributes': attributes,
      'evidenceIds': evidenceIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'isDirected': isDirected,
    };
  }

  factory Relationship.fromJson(Map<String, dynamic> json) {
    return Relationship(
      id: json['id'] as String,
      sourceNodeId: json['sourceNodeId'] as String,
      targetNodeId: json['targetNodeId'] as String,
      type: RelationshipType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RelationshipType.other,
      ),
      label: json['label'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
      evidenceIds: (json['evidenceIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
      isDirected: json['isDirected'] as bool? ?? true,
    );
  }
}

enum RelationshipType {
  familyRelation,
  businessPartner,
  employee,
  shareholder,
  director,
  owns,
  manages,
  associated,
  knows,
  friends,
  colleague,
  neighbor,
  attended,
  located,
  registered,
  communicated,
  transacted,
  linked,
  mentioned,
  suspected,
  other,
}

extension RelationshipTypeExtension on RelationshipType {
  String get displayName {
    switch (this) {
      case RelationshipType.familyRelation:
        return 'Relación Familiar';
      case RelationshipType.businessPartner:
        return 'Socio Comercial';
      case RelationshipType.employee:
        return 'Empleado';
      case RelationshipType.shareholder:
        return 'Accionista';
      case RelationshipType.director:
        return 'Director';
      case RelationshipType.owns:
        return 'Propietario';
      case RelationshipType.manages:
        return 'Administra';
      case RelationshipType.associated:
        return 'Asociado';
      case RelationshipType.knows:
        return 'Conoce';
      case RelationshipType.friends:
        return 'Amigos';
      case RelationshipType.colleague:
        return 'Colega';
      case RelationshipType.neighbor:
        return 'Vecino';
      case RelationshipType.attended:
        return 'Asistió';
      case RelationshipType.located:
        return 'Ubicado';
      case RelationshipType.registered:
        return 'Registrado';
      case RelationshipType.communicated:
        return 'Comunicado';
      case RelationshipType.transacted:
        return 'Transaccionó';
      case RelationshipType.linked:
        return 'Vinculado';
      case RelationshipType.mentioned:
        return 'Mencionado';
      case RelationshipType.suspected:
        return 'Sospechoso';
      case RelationshipType.other:
        return 'Otro';
    }
  }
}
