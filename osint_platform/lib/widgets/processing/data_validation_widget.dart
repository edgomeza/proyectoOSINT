import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/data_form.dart';
import '../../services/data_validation_service.dart';
import '../../providers/data_forms_provider.dart';

class DataValidationWidget extends ConsumerStatefulWidget {
  final String investigationId;

  const DataValidationWidget({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<DataValidationWidget> createState() =>
      _DataValidationWidgetState();
}

class _DataValidationWidgetState extends ConsumerState<DataValidationWidget> {
  CleaningOptions _cleaningOptions = CleaningOptions.all;
  Map<String, ValidationResult> _validationResults = {};
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _validateAll();
  }

  Future<void> _validateAll() async {
    setState(() => _isScanning = true);

    final forms = ref.read(dataFormsProvider)
        .where((f) => f.investigationId == widget.investigationId)
        .toList();

    final results = <String, ValidationResult>{};

    for (final form in forms) {
      results[form.id] = DataValidationService.validate(form);
    }

    setState(() {
      _validationResults = results;
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final forms = ref.watch(dataFormsProvider)
        .where((f) => f.investigationId == widget.investigationId)
        .toList();

    final totalErrors = _validationResults.values
        .fold<int>(0, (sum, result) => sum + result.errorCount);
    final totalWarnings = _validationResults.values
        .fold<int>(0, (sum, result) => sum + result.warningCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Validation & Cleaning',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '$totalErrors errors, $totalWarnings warnings',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isScanning)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _validateAll,
                        tooltip: 'Rescan',
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        context,
                        icon: Icons.error,
                        label: 'Errors',
                        count: totalErrors,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip(
                        context,
                        icon: Icons.warning,
                        label: 'Warnings',
                        count: totalWarnings,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip(
                        context,
                        icon: Icons.check_circle,
                        label: 'Valid',
                        count: forms.length - totalErrors,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cleaning Options
        Card(
          child: ExpansionTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Cleaning Options'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Trim Whitespace'),
                      value: _cleaningOptions.trimWhitespace,
                      onChanged: (value) {
                        setState(() {
                          _cleaningOptions = CleaningOptions(
                            trimWhitespace: value!,
                            standardizeDates: _cleaningOptions.standardizeDates,
                            standardizePhones: _cleaningOptions.standardizePhones,
                            standardizeEmails: _cleaningOptions.standardizeEmails,
                            titleCase: _cleaningOptions.titleCase,
                            removeHtml: _cleaningOptions.removeHtml,
                            normalizeWhitespace: _cleaningOptions.normalizeWhitespace,
                            removeSpecialChars: _cleaningOptions.removeSpecialChars,
                          );
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Standardize Dates (ISO 8601)'),
                      value: _cleaningOptions.standardizeDates,
                      onChanged: (value) {
                        setState(() {
                          _cleaningOptions = CleaningOptions(
                            trimWhitespace: _cleaningOptions.trimWhitespace,
                            standardizeDates: value!,
                            standardizePhones: _cleaningOptions.standardizePhones,
                            standardizeEmails: _cleaningOptions.standardizeEmails,
                            titleCase: _cleaningOptions.titleCase,
                            removeHtml: _cleaningOptions.removeHtml,
                            normalizeWhitespace: _cleaningOptions.normalizeWhitespace,
                            removeSpecialChars: _cleaningOptions.removeSpecialChars,
                          );
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Standardize Phone Numbers'),
                      value: _cleaningOptions.standardizePhones,
                      onChanged: (value) {
                        setState(() {
                          _cleaningOptions = CleaningOptions(
                            trimWhitespace: _cleaningOptions.trimWhitespace,
                            standardizeDates: _cleaningOptions.standardizeDates,
                            standardizePhones: value!,
                            standardizeEmails: _cleaningOptions.standardizeEmails,
                            titleCase: _cleaningOptions.titleCase,
                            removeHtml: _cleaningOptions.removeHtml,
                            normalizeWhitespace: _cleaningOptions.normalizeWhitespace,
                            removeSpecialChars: _cleaningOptions.removeSpecialChars,
                          );
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Title Case Names'),
                      value: _cleaningOptions.titleCase,
                      onChanged: (value) {
                        setState(() {
                          _cleaningOptions = CleaningOptions(
                            trimWhitespace: _cleaningOptions.trimWhitespace,
                            standardizeDates: _cleaningOptions.standardizeDates,
                            standardizePhones: _cleaningOptions.standardizePhones,
                            standardizeEmails: _cleaningOptions.standardizeEmails,
                            titleCase: value!,
                            removeHtml: _cleaningOptions.removeHtml,
                            normalizeWhitespace: _cleaningOptions.normalizeWhitespace,
                            removeSpecialChars: _cleaningOptions.removeSpecialChars,
                          );
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Remove HTML Tags'),
                      value: _cleaningOptions.removeHtml,
                      onChanged: (value) {
                        setState(() {
                          _cleaningOptions = CleaningOptions(
                            trimWhitespace: _cleaningOptions.trimWhitespace,
                            standardizeDates: _cleaningOptions.standardizeDates,
                            standardizePhones: _cleaningOptions.standardizePhones,
                            standardizeEmails: _cleaningOptions.standardizeEmails,
                            titleCase: _cleaningOptions.titleCase,
                            removeHtml: value!,
                            normalizeWhitespace: _cleaningOptions.normalizeWhitespace,
                            removeSpecialChars: _cleaningOptions.removeSpecialChars,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _cleanAllForms(forms),
                      icon: const Icon(Icons.cleaning_services),
                      label: const Text('Clean All Forms'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Forms List
        Text(
          'Forms (${forms.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: forms.isEmpty
              ? Center(
                  child: Text(
                    'No forms to validate',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: forms.length,
                  itemBuilder: (context, index) {
                    final form = forms[index];
                    final result = _validationResults[form.id];

                    return _buildFormCard(context, form, result);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    DataForm form,
    ValidationResult? result,
  ) {
    final label = form.fields['name']?.toString() ?? 'Unnamed';

    return Card(
      child: ExpansionTile(
        leading: result == null
            ? const CircularProgressIndicator()
            : Icon(
                result.isValid ? Icons.check_circle : Icons.error,
                color: result.isValid ? Colors.green : Colors.red,
              ),
        title: Text(label),
        subtitle: result == null
            ? const Text('Validating...')
            : Text(
                '${result.errorCount} errors, ${result.warningCount} warnings',
              ),
        children: result == null
            ? []
            : [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Issues
                      if (result.issues.isNotEmpty) ...[
                        ...result.issues.map((issue) => _buildIssueItem(issue)),
                        const Divider(height: 24),
                      ],

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _cleanForm(form),
                            icon: const Icon(Icons.cleaning_services),
                            label: const Text('Clean'),
                          ),
                          const SizedBox(width: 8),
                          if (!result.isValid)
                            ElevatedButton.icon(
                              onPressed: () => _showFixDialog(context, form, result),
                              icon: const Icon(Icons.build),
                              label: const Text('Fix Issues'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildIssueItem(ValidationIssue issue) {
    Color color;
    IconData icon;

    switch (issue.severity) {
      case IssueSeverity.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case IssueSeverity.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case IssueSeverity.info:
        color = Colors.blue;
        icon = Icons.info;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.message,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                if (issue.suggestion.isNotEmpty)
                  Text(
                    '💡 ${issue.suggestion}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cleanForm(DataForm form) {
    final cleaned = DataValidationService.clean(form, _cleaningOptions);
    ref.read(dataFormsProvider.notifier).update(cleaned);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form cleaned successfully'),
        backgroundColor: Colors.green,
      ),
    );

    _validateAll();
  }

  void _cleanAllForms(List<DataForm> forms) {
    for (final form in forms) {
      final cleaned = DataValidationService.clean(form, _cleaningOptions);
      ref.read(dataFormsProvider.notifier).update(cleaned);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${forms.length} forms cleaned successfully'),
        backgroundColor: Colors.green,
      ),
    );

    _validateAll();
  }

  void _showFixDialog(BuildContext context, DataForm form, ValidationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fix Issues'),
        content: const Text(
          'This feature allows manual editing of each field to fix validation issues. '
          'It will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
