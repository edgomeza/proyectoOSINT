import 'package:uuid/uuid.dart';
import 'data_form_status.dart';

class DataForm {
  final String id;
  final String investigationId;
  final DataFormCategory category;
  final DataFormStatus status;
  final Map<String, dynamic> fields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int priority;
  final double confidence;
  final List<String> tags;
  final String? notes;

  DataForm({
    String? id,
    required this.investigationId,
    required this.category,
    this.status = DataFormStatus.draft,
    this.fields = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    this.priority = 0,
    this.confidence = 0.5,
    this.tags = const [],
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DataForm copyWith({
    String? id,
    String? investigationId,
    DataFormCategory? category,
    DataFormStatus? status,
    Map<String, dynamic>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? priority,
    double? confidence,
    List<String>? tags,
    String? notes,
  }) {
    return DataForm(
      id: id ?? this.id,
      investigationId: investigationId ?? this.investigationId,
      category: category ?? this.category,
      status: status ?? this.status,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      priority: priority ?? this.priority,
      confidence: confidence ?? this.confidence,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }

  // Calcula la completitud del formulario basándose en los campos completados
  double get completeness {
    if (fields.isEmpty) return 0.0;
    final nonEmptyFields = fields.values.where((value) {
      if (value == null) return false;
      if (value is String) return value.isNotEmpty;
      if (value is List) return value.isNotEmpty;
      return true;
    }).length;
    return nonEmptyFields / fields.length;
  }

  // Calcula una puntuación de prioridad inteligente
  int get smartPriority {
    double score = 0;

    // Factor de completitud (mayor completitud = mayor prioridad)
    score += completeness * 30;

    // Factor de confianza
    score += confidence * 25;

    // Factor de simplicidad (menos campos = más fácil de revisar primero)
    final simplicity = fields.isEmpty ? 0 : (1 - (fields.length / 20)).clamp(0.0, 1.0);
    score += simplicity * 20;

    // Factor temporal (más reciente = mayor prioridad)
    final daysSinceUpdate = DateTime.now().difference(updatedAt).inDays;
    final recency = (1 - (daysSinceUpdate / 30).clamp(0.0, 1.0));
    score += recency * 15;

    // Prioridad manual
    score += priority * 10;

    return score.round();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investigationId': investigationId,
      'category': category.name,
      'status': status.name,
      'fields': fields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'priority': priority,
      'confidence': confidence,
      'tags': tags,
      'notes': notes,
    };
  }

  factory DataForm.fromJson(Map<String, dynamic> json) {
    return DataForm(
      id: json['id'],
      investigationId: json['investigationId'],
      category: DataFormCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => DataFormCategory.other,
      ),
      status: DataFormStatus.values.firstWhere(
        (stat) => stat.name == json['status'],
        orElse: () => DataFormStatus.draft,
      ),
      fields: Map<String, dynamic>.from(json['fields'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      priority: json['priority'] ?? 0,
      confidence: json['confidence']?.toDouble() ?? 0.5,
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'],
    );
  }
}
