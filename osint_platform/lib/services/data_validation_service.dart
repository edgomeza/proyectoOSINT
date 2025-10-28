import 'package:intl/intl.dart';
import '../models/data_form.dart';

/// Service for validating and cleaning data forms
class DataValidationService {
  /// Validation results
  static ValidationResult validate(DataForm form) {
    final issues = <ValidationIssue>[];
    final suggestions = <String>[];

    // Check for empty required fields
    final emptyFields = _checkEmptyFields(form);
    if (emptyFields.isNotEmpty) {
      issues.add(ValidationIssue(
        severity: IssueSeverity.error,
        field: 'multiple',
        message: 'Empty required fields: ${emptyFields.join(", ")}',
        suggestion: 'Fill in required information',
      ));
    }

    // Validate email formats
    final emailIssues = _validateEmails(form);
    issues.addAll(emailIssues);

    // Validate phone numbers
    final phoneIssues = _validatePhones(form);
    issues.addAll(phoneIssues);

    // Validate dates
    final dateIssues = _validateDates(form);
    issues.addAll(dateIssues);

    // Validate URLs
    final urlIssues = _validateUrls(form);
    issues.addAll(urlIssues);

    // Check for inconsistencies
    final inconsistencies = _checkInconsistencies(form);
    issues.addAll(inconsistencies);

    // Check for duplicates (basic check)
    if (form.fields.containsKey('name') || form.fields.containsKey('email')) {
      suggestions.add('Check for potential duplicates');
    }

    return ValidationResult(
      isValid: issues.where((i) => i.severity == IssueSeverity.error).isEmpty,
      issues: issues,
      suggestions: suggestions,
    );
  }

  /// Clean and standardize data
  static DataForm clean(DataForm form, CleaningOptions options) {
    final cleanedFields = <String, dynamic>{};

    for (final entry in form.fields.entries) {
      final key = entry.key;
      var value = entry.value;

      if (value == null || value.toString().isEmpty) {
        cleanedFields[key] = value;
        continue;
      }

      // Apply cleaning based on field type
      if (options.standardizeDates && _isDateField(key)) {
        value = _cleanDate(value);
      } else if (options.standardizePhones && _isPhoneField(key)) {
        value = _cleanPhone(value);
      } else if (options.standardizeEmails && _isEmailField(key)) {
        value = _cleanEmail(value);
      } else if (options.trimWhitespace && value is String) {
        value = value.trim();
      }

      if (options.titleCase && _isNameField(key) && value is String) {
        value = _toTitleCase(value);
      }

      if (options.removeHtml && value is String) {
        value = _removeHtmlTags(value);
      }

      if (options.normalizeWhitespace && value is String) {
        value = _normalizeWhitespace(value);
      }

      if (options.removeSpecialChars && _isTextOnlyField(key) && value is String) {
        value = _removeSpecialCharacters(value);
      }

      cleanedFields[key] = value;
    }

    return form.copyWith(fields: cleanedFields);
  }

  // Validation helpers

  static List<String> _checkEmptyFields(DataForm form) {
    final empty = <String>[];
    final requiredFields = ['name', 'email', 'phone']; // Customize per category

    for (final field in requiredFields) {
      if (form.fields.containsKey(field)) {
        final value = form.fields[field];
        if (value == null || value.toString().trim().isEmpty) {
          empty.add(field);
        }
      }
    }

    return empty;
  }

  static List<ValidationIssue> _validateEmails(DataForm form) {
    final issues = <ValidationIssue>[];
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    for (final entry in form.fields.entries) {
      if (_isEmailField(entry.key)) {
        final value = entry.value?.toString() ?? '';
        if (value.isNotEmpty && !emailRegex.hasMatch(value)) {
          issues.add(ValidationIssue(
            severity: IssueSeverity.error,
            field: entry.key,
            message: 'Invalid email format: $value',
            suggestion: 'Use format: user@example.com',
          ));
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validatePhones(DataForm form) {
    final issues = <ValidationIssue>[];
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]{7,}$');

    for (final entry in form.fields.entries) {
      if (_isPhoneField(entry.key)) {
        final value = entry.value?.toString() ?? '';
        if (value.isNotEmpty && !phoneRegex.hasMatch(value)) {
          issues.add(ValidationIssue(
            severity: IssueSeverity.warning,
            field: entry.key,
            message: 'Phone number may be invalid: $value',
            suggestion: 'Use international format: +1-234-567-8900',
          ));
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validateDates(DataForm form) {
    final issues = <ValidationIssue>[];

    for (final entry in form.fields.entries) {
      if (_isDateField(entry.key)) {
        final value = entry.value?.toString() ?? '';
        if (value.isNotEmpty) {
          try {
            DateTime.parse(value);
          } catch (e) {
            issues.add(ValidationIssue(
              severity: IssueSeverity.error,
              field: entry.key,
              message: 'Invalid date format: $value',
              suggestion: 'Use ISO 8601 format: YYYY-MM-DD',
            ));
          }
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validateUrls(DataForm form) {
    final issues = <ValidationIssue>[];
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b',
    );

    for (final entry in form.fields.entries) {
      if (_isUrlField(entry.key)) {
        final value = entry.value?.toString() ?? '';
        if (value.isNotEmpty && !urlRegex.hasMatch(value)) {
          issues.add(ValidationIssue(
            severity: IssueSeverity.warning,
            field: entry.key,
            message: 'URL may be invalid: $value',
            suggestion: 'Use full URL with http:// or https://',
          ));
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _checkInconsistencies(DataForm form) {
    final issues = <ValidationIssue>[];

    // Check if email domain matches company domain
    if (form.fields.containsKey('email') && form.fields.containsKey('company')) {
      final email = form.fields['email']?.toString() ?? '';
      final company = form.fields['company']?.toString().toLowerCase() ?? '';

      if (email.isNotEmpty && company.isNotEmpty) {
        final emailDomain = email.split('@').last.toLowerCase();
        if (!emailDomain.contains(company) && !company.contains(emailDomain.split('.').first)) {
          issues.add(ValidationIssue(
            severity: IssueSeverity.info,
            field: 'email',
            message: 'Email domain doesn\'t match company name',
            suggestion: 'Verify if this is the correct association',
          ));
        }
      }
    }

    // Check future dates
    for (final entry in form.fields.entries) {
      if (_isDateField(entry.key) && !entry.key.toLowerCase().contains('expir')) {
        final value = entry.value?.toString() ?? '';
        if (value.isNotEmpty) {
          try {
            final date = DateTime.parse(value);
            if (date.isAfter(DateTime.now())) {
              issues.add(ValidationIssue(
                severity: IssueSeverity.warning,
                field: entry.key,
                message: 'Date is in the future',
                suggestion: 'Verify this is correct',
              ));
            }
          } catch (e) {
            // Already caught in date validation
          }
        }
      }
    }

    return issues;
  }

  // Cleaning helpers

  static String _cleanDate(dynamic value) {
    if (value == null) return '';

    final str = value.toString();

    // Try to parse various date formats and convert to ISO 8601
    final formats = [
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'yyyy/MM/dd',
    ];

    for (final format in formats) {
      try {
        final date = DateFormat(format).parse(str);
        return DateFormat('yyyy-MM-dd').format(date);
      } catch (e) {
        continue;
      }
    }

    return str; // Return original if parsing fails
  }

  static String _cleanPhone(dynamic value) {
    if (value == null) return '';

    String phone = value.toString();

    // Remove all non-digit characters except +
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Format as international if it's not already
    if (phone.length >= 10 && !phone.startsWith('+')) {
      phone = '+1$phone'; // Default to US, customize as needed
    }

    return phone;
  }

  static String _cleanEmail(dynamic value) {
    if (value == null) return '';
    return value.toString().toLowerCase().trim();
  }

  static String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String _removeHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  static String _normalizeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^\w\s\-\.]'), '');
  }

  // Field type detection

  static bool _isEmailField(String key) {
    return key.toLowerCase().contains('email') || key.toLowerCase().contains('mail');
  }

  static bool _isPhoneField(String key) {
    return key.toLowerCase().contains('phone') ||
           key.toLowerCase().contains('tel') ||
           key.toLowerCase().contains('mobile');
  }

  static bool _isDateField(String key) {
    return key.toLowerCase().contains('date') ||
           key.toLowerCase().contains('birth') ||
           key.toLowerCase().contains('created') ||
           key.toLowerCase().contains('updated');
  }

  static bool _isUrlField(String key) {
    return key.toLowerCase().contains('url') ||
           key.toLowerCase().contains('website') ||
           key.toLowerCase().contains('link');
  }

  static bool _isNameField(String key) {
    return key.toLowerCase().contains('name') ||
           key.toLowerCase().contains('title') ||
           key.toLowerCase().contains('company');
  }

  static bool _isTextOnlyField(String key) {
    return _isNameField(key) &&
           !key.toLowerCase().contains('description') &&
           !key.toLowerCase().contains('notes');
  }
}

/// Validation result containing issues and suggestions
class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;
  final List<String> suggestions;

  ValidationResult({
    required this.isValid,
    required this.issues,
    required this.suggestions,
  });

  int get errorCount => issues.where((i) => i.severity == IssueSeverity.error).length;
  int get warningCount => issues.where((i) => i.severity == IssueSeverity.warning).length;
  int get infoCount => issues.where((i) => i.severity == IssueSeverity.info).length;
}

/// Individual validation issue
class ValidationIssue {
  final IssueSeverity severity;
  final String field;
  final String message;
  final String suggestion;

  ValidationIssue({
    required this.severity,
    required this.field,
    required this.message,
    required this.suggestion,
  });
}

enum IssueSeverity {
  error,
  warning,
  info,
}

/// Options for data cleaning
class CleaningOptions {
  final bool trimWhitespace;
  final bool standardizeDates;
  final bool standardizePhones;
  final bool standardizeEmails;
  final bool titleCase;
  final bool removeHtml;
  final bool normalizeWhitespace;
  final bool removeSpecialChars;

  const CleaningOptions({
    this.trimWhitespace = true,
    this.standardizeDates = true,
    this.standardizePhones = true,
    this.standardizeEmails = true,
    this.titleCase = true,
    this.removeHtml = true,
    this.normalizeWhitespace = true,
    this.removeSpecialChars = false,
  });

  static const CleaningOptions all = CleaningOptions();
  static const CleaningOptions minimal = CleaningOptions(
    trimWhitespace: true,
    standardizeDates: false,
    standardizePhones: false,
    standardizeEmails: true,
    titleCase: false,
    removeHtml: false,
    normalizeWhitespace: false,
    removeSpecialChars: false,
  );
}
