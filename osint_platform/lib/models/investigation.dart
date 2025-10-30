import 'package:uuid/uuid.dart';
import 'investigation_phase.dart';
import 'investigation_status.dart';
import 'investigation_type.dart';

class Investigation {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final InvestigationPhase currentPhase;
  final List<InvestigationType> investigationTypes;
  final List<String> objectives;
  final Map<String, dynamic> knownInformation;
  final List<String> keyQuestions;
  final double completeness;
  final int sessionTime;
  final int fatigueLevel;
  final bool isActive;
  final InvestigationStatus status;

  Investigation({
    String? id,
    required this.name,
    required this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.currentPhase = InvestigationPhase.planning,
    this.investigationTypes = const [],
    this.objectives = const [],
    this.knownInformation = const {},
    this.keyQuestions = const [],
    this.completeness = 0.0,
    this.sessionTime = 0,
    this.fatigueLevel = 0,
    this.isActive = false,
    this.status = InvestigationStatus.inactive,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Investigation copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    InvestigationPhase? currentPhase,
    List<InvestigationType>? investigationTypes,
    List<String>? objectives,
    Map<String, dynamic>? knownInformation,
    List<String>? keyQuestions,
    double? completeness,
    int? sessionTime,
    int? fatigueLevel,
    bool? isActive,
    InvestigationStatus? status,
  }) {
    return Investigation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      currentPhase: currentPhase ?? this.currentPhase,
      investigationTypes: investigationTypes ?? this.investigationTypes,
      objectives: objectives ?? this.objectives,
      knownInformation: knownInformation ?? this.knownInformation,
      keyQuestions: keyQuestions ?? this.keyQuestions,
      completeness: completeness ?? this.completeness,
      sessionTime: sessionTime ?? this.sessionTime,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'currentPhase': currentPhase.name,
      'investigationTypes': investigationTypes.map((t) => t.name).toList(),
      'objectives': objectives,
      'knownInformation': knownInformation,
      'keyQuestions': keyQuestions,
      'completeness': completeness,
      'sessionTime': sessionTime,
      'fatigueLevel': fatigueLevel,
      'isActive': isActive,
      'status': status.value,
    };
  }

  factory Investigation.fromJson(Map<String, dynamic> json) {
    return Investigation(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      currentPhase: InvestigationPhase.values.firstWhere(
        (phase) => phase.name == json['currentPhase'],
        orElse: () => InvestigationPhase.planning,
      ),
      investigationTypes: (json['investigationTypes'] as List<dynamic>?)
              ?.map((typeName) => InvestigationType.values.firstWhere(
                    (t) => t.name == typeName,
                    orElse: () => InvestigationType.people,
                  ))
              .toList() ??
          [],
      objectives: List<String>.from(json['objectives'] ?? []),
      knownInformation: Map<String, dynamic>.from(json['knownInformation'] ?? {}),
      keyQuestions: List<String>.from(json['keyQuestions'] ?? []),
      completeness: json['completeness']?.toDouble() ?? 0.0,
      sessionTime: json['sessionTime'] ?? 0,
      fatigueLevel: json['fatigueLevel'] ?? 0,
      isActive: json['isActive'] ?? false,
      status: InvestigationStatus.values.firstWhere(
        (s) => s.value == json['status'],
        orElse: () => InvestigationStatus.inactive,
      ),
    );
  }
}
