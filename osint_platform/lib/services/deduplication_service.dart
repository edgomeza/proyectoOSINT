import 'package:string_similarity/string_similarity.dart';
import '../models/data_form.dart';

/// Service for detecting and managing duplicate data forms
class DeduplicationService {
  /// Find potential duplicates for a given form
  static List<DuplicateMatch> findDuplicates(
    DataForm target,
    List<DataForm> allForms, {
    double similarityThreshold = 0.7,
  }) {
    final matches = <DuplicateMatch>[];

    for (final candidate in allForms) {
      // Skip self
      if (candidate.id == target.id) continue;

      // Only compare forms of the same category
      if (candidate.category != target.category) continue;

      final similarity = calculateSimilarity(target, candidate);

      if (similarity >= similarityThreshold) {
        matches.add(DuplicateMatch(
          form1: target,
          form2: candidate,
          similarity: similarity,
          matchingFields: _getMatchingFields(target, candidate),
          conflicts: _getConflicts(target, candidate),
        ));
      }
    }

    // Sort by similarity (highest first)
    matches.sort((a, b) => b.similarity.compareTo(a.similarity));

    return matches;
  }

  /// Calculate similarity between two forms
  static double calculateSimilarity(DataForm form1, DataForm form2) {
    if (form1.category != form2.category) return 0.0;

    double totalScore = 0.0;
    int comparisonCount = 0;

    // Get all unique field keys
    final allKeys = {...form1.fields.keys, ...form2.fields.keys};

    for (final key in allKeys) {
      final value1 = form1.fields[key];
      final value2 = form2.fields[key];

      // Skip if both are null
      if (value1 == null && value2 == null) continue;

      // If one is null and the other isn't, it's a mismatch
      if (value1 == null || value2 == null) {
        comparisonCount++;
        continue;
      }

      // Calculate field similarity
      final fieldScore = _calculateFieldSimilarity(
        key,
        value1.toString(),
        value2.toString(),
      );

      // Weight important fields more heavily
      final weight = _getFieldWeight(key);
      totalScore += fieldScore * weight;
      comparisonCount += weight.toInt();
    }

    return comparisonCount > 0 ? totalScore / comparisonCount : 0.0;
  }

  /// Merge two forms into a master record
  static DataForm merge(
    DataForm primary,
    DataForm secondary,
    MergeStrategy strategy,
  ) {
    final mergedFields = <String, dynamic>{};

    // Get all unique field keys
    final allKeys = {...primary.fields.keys, ...secondary.fields.keys};

    for (final key in allKeys) {
      final value1 = primary.fields[key];
      final value2 = secondary.fields[key];

      // Decide which value to use based on strategy
      if (value1 == null && value2 != null) {
        mergedFields[key] = value2;
      } else if (value2 == null && value1 != null) {
        mergedFields[key] = value1;
      } else if (value1 != null && value2 != null) {
        mergedFields[key] = _mergeFieldValues(
          key,
          value1,
          value2,
          strategy,
          primary,
          secondary,
        );
      }
    }

    // Combine tags
    final mergedTags = {...primary.tags, ...secondary.tags}.toList();

    // Combine notes
    String? mergedNotes;
    if (primary.notes != null && secondary.notes != null) {
      mergedNotes = '${primary.notes}\n---\n${secondary.notes}';
    } else {
      mergedNotes = primary.notes ?? secondary.notes;
    }

    // Use highest confidence
    final mergedConfidence = primary.confidence > secondary.confidence
        ? primary.confidence
        : secondary.confidence;

    // Use highest priority
    final mergedPriority = primary.priority > secondary.priority
        ? primary.priority
        : secondary.priority;

    return primary.copyWith(
      fields: mergedFields,
      tags: mergedTags,
      notes: mergedNotes,
      confidence: mergedConfidence,
      priority: mergedPriority,
    );
  }

  // Private helper methods

  static double _calculateFieldSimilarity(String key, String value1, String value2) {
    // Exact match
    if (value1 == value2) return 1.0;

    // Normalize values
    final normalized1 = value1.toLowerCase().trim();
    final normalized2 = value2.toLowerCase().trim();

    if (normalized1 == normalized2) return 1.0;

    // Use string similarity for text fields
    if (_isTextField(key)) {
      return normalized1.similarityTo(normalized2);
    }

    // For other fields, binary match
    return 0.0;
  }

  static double _getFieldWeight(String key) {
    // Key identifier fields have highest weight
    if (key.toLowerCase() == 'email') return 3.0;
    if (key.toLowerCase() == 'phone') return 3.0;
    if (key.toLowerCase().contains('id')) return 3.0;

    // Name fields have high weight
    if (key.toLowerCase().contains('name')) return 2.5;

    // Important fields
    if (key.toLowerCase().contains('address')) return 2.0;
    if (key.toLowerCase().contains('company')) return 2.0;

    // Default weight
    return 1.0;
  }

  static bool _isTextField(String key) {
    return key.toLowerCase().contains('name') ||
           key.toLowerCase().contains('description') ||
           key.toLowerCase().contains('notes') ||
           key.toLowerCase().contains('title') ||
           key.toLowerCase().contains('address');
  }

  static List<String> _getMatchingFields(DataForm form1, DataForm form2) {
    final matching = <String>[];

    for (final key in form1.fields.keys) {
      if (form2.fields.containsKey(key)) {
        final value1 = form1.fields[key]?.toString() ?? '';
        final value2 = form2.fields[key]?.toString() ?? '';

        if (value1.toLowerCase().trim() == value2.toLowerCase().trim()) {
          matching.add(key);
        }
      }
    }

    return matching;
  }

  static List<FieldConflict> _getConflicts(DataForm form1, DataForm form2) {
    final conflicts = <FieldConflict>[];

    for (final key in form1.fields.keys) {
      if (form2.fields.containsKey(key)) {
        final value1 = form1.fields[key];
        final value2 = form2.fields[key];

        if (value1 != null && value2 != null) {
          final str1 = value1.toString().toLowerCase().trim();
          final str2 = value2.toString().toLowerCase().trim();

          if (str1 != str2) {
            conflicts.add(FieldConflict(
              field: key,
              value1: value1.toString(),
              value2: value2.toString(),
            ));
          }
        }
      }
    }

    return conflicts;
  }

  static dynamic _mergeFieldValues(
    String key,
    dynamic value1,
    dynamic value2,
    MergeStrategy strategy,
    DataForm primary,
    DataForm secondary,
  ) {
    switch (strategy) {
      case MergeStrategy.preferPrimary:
        return value1;

      case MergeStrategy.preferSecondary:
        return value2;

      case MergeStrategy.preferNewer:
        return primary.updatedAt.isAfter(secondary.updatedAt)
            ? value1
            : value2;

      case MergeStrategy.preferHigherConfidence:
        return primary.confidence >= secondary.confidence
            ? value1
            : value2;

      case MergeStrategy.preferLonger:
        final str1 = value1.toString();
        final str2 = value2.toString();
        return str1.length >= str2.length ? value1 : value2;

      case MergeStrategy.combine:
        if (_isTextField(key)) {
          final str1 = value1.toString();
          final str2 = value2.toString();
          if (str1 != str2) {
            return '$str1 / $str2';
          }
        }
        return value1;
    }
  }

  /// Auto-suggest merge actions based on analysis
  static List<MergeSuggestion> analyzeMerge(DuplicateMatch match) {
    final suggestions = <MergeSuggestion>[];

    // Suggest which record to use as primary
    if (match.form1.confidence > match.form2.confidence) {
      suggestions.add(MergeSuggestion(
        type: SuggestionType.usePrimary,
        reason: 'Form 1 has higher confidence (${match.form1.confidence} vs ${match.form2.confidence})',
        confidence: 0.8,
      ));
    } else if (match.form2.confidence > match.form1.confidence) {
      suggestions.add(MergeSuggestion(
        type: SuggestionType.useSecondary,
        reason: 'Form 2 has higher confidence (${match.form2.confidence} vs ${match.form1.confidence})',
        confidence: 0.8,
      ));
    }

    // Analyze conflicts and suggest resolutions
    for (final conflict in match.conflicts) {
      final val1 = conflict.value1;
      final val2 = conflict.value2;

      // Suggest longer value for text fields
      if (_isTextField(conflict.field)) {
        if (val1.length > val2.length * 1.5) {
          suggestions.add(MergeSuggestion(
            type: SuggestionType.useValue1,
            field: conflict.field,
            reason: 'Value 1 is more detailed',
            confidence: 0.7,
          ));
        } else if (val2.length > val1.length * 1.5) {
          suggestions.add(MergeSuggestion(
            type: SuggestionType.useValue2,
            field: conflict.field,
            reason: 'Value 2 is more detailed',
            confidence: 0.7,
          ));
        }
      }
    }

    // If very high similarity, suggest auto-merge
    if (match.similarity > 0.9 && match.conflicts.length < 3) {
      suggestions.add(MergeSuggestion(
        type: SuggestionType.autoMerge,
        reason: 'Very high similarity with minimal conflicts',
        confidence: 0.9,
      ));
    }

    return suggestions;
  }
}

/// A potential duplicate match
class DuplicateMatch {
  final DataForm form1;
  final DataForm form2;
  final double similarity;
  final List<String> matchingFields;
  final List<FieldConflict> conflicts;

  DuplicateMatch({
    required this.form1,
    required this.form2,
    required this.similarity,
    required this.matchingFields,
    required this.conflicts,
  });
}

/// A conflict between two field values
class FieldConflict {
  final String field;
  final String value1;
  final String value2;

  FieldConflict({
    required this.field,
    required this.value1,
    required this.value2,
  });
}

/// Strategy for merging duplicate records
enum MergeStrategy {
  preferPrimary,
  preferSecondary,
  preferNewer,
  preferHigherConfidence,
  preferLonger,
  combine,
}

/// Suggestion for merge resolution
class MergeSuggestion {
  final SuggestionType type;
  final String? field;
  final String reason;
  final double confidence;

  MergeSuggestion({
    required this.type,
    this.field,
    required this.reason,
    required this.confidence,
  });
}

enum SuggestionType {
  usePrimary,
  useSecondary,
  useValue1,
  useValue2,
  autoMerge,
  manualReview,
}
