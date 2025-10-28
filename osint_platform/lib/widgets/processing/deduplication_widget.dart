import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/data_form.dart';
import '../../services/deduplication_service.dart';
import '../../providers/data_forms_provider.dart';

class DeduplicationWidget extends ConsumerStatefulWidget {
  final String investigationId;

  const DeduplicationWidget({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<DeduplicationWidget> createState() =>
      _DeduplicationWidgetState();
}

class _DeduplicationWidgetState extends ConsumerState<DeduplicationWidget> {
  List<DuplicateMatch>? _matches;
  bool _isScanning = false;
  double _similarityThreshold = 0.7;

  @override
  void initState() {
    super.initState();
    _scanForDuplicates();
  }

  Future<void> _scanForDuplicates() async {
    setState(() => _isScanning = true);

    // Get all forms for this investigation
    final allForms = ref.read(dataFormsProvider);
    final investigationForms = allForms
        .where((f) => f.investigationId == widget.investigationId)
        .toList();

    // Find duplicates for each form
    final allMatches = <DuplicateMatch>[];

    for (final form in investigationForms) {
      final matches = DeduplicationService.findDuplicates(
        form,
        investigationForms,
        similarityThreshold: _similarityThreshold,
      );
      allMatches.addAll(matches);
    }

    // Remove duplicate matches (A-B and B-A are the same)
    final uniqueMatches = <DuplicateMatch>[];
    final seenPairs = <String>{};

    for (final match in allMatches) {
      final pair1 = '${match.form1.id}-${match.form2.id}';
      final pair2 = '${match.form2.id}-${match.form1.id}';

      if (!seenPairs.contains(pair1) && !seenPairs.contains(pair2)) {
        uniqueMatches.add(match);
        seenPairs.add(pair1);
      }
    }

    setState(() {
      _matches = uniqueMatches;
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    const Icon(Icons.content_copy, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duplicate Detection',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            _matches == null
                                ? 'Scanning for duplicates...'
                                : '${_matches!.length} potential duplicates found',
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
                        onPressed: _scanForDuplicates,
                        tooltip: 'Rescan',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Similarity Threshold: ${(_similarityThreshold * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Slider(
                            value: _similarityThreshold,
                            min: 0.5,
                            max: 1.0,
                            divisions: 10,
                            label: '${(_similarityThreshold * 100).toInt()}%',
                            onChanged: (value) {
                              setState(() => _similarityThreshold = value);
                            },
                            onChangeEnd: (_) => _scanForDuplicates(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Results
        if (_isScanning)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning for duplicates...'),
                ],
              ),
            ),
          )
        else if (_matches == null || _matches!.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text('No duplicates found'),
                  const SizedBox(height: 8),
                  Text(
                    'All records appear to be unique',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _matches!.length,
              itemBuilder: (context, index) {
                final match = _matches![index];
                return _buildMatchCard(context, match);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, DuplicateMatch match) {
    final suggestions = DeduplicationService.analyzeMerge(match);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getSimilarityColor(match.similarity).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${(match.similarity * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getSimilarityColor(match.similarity),
            ),
          ),
        ),
        title: Text(
          '${_getFormLabel(match.form1)} ↔ ${_getFormLabel(match.form2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${match.matchingFields.length} matching fields, ${match.conflicts.length} conflicts',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suggestions
                if (suggestions.isNotEmpty) ...[
                  Text(
                    'AI Suggestions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...suggestions.map((suggestion) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(suggestion.reason)),
                            Text(
                              '${(suggestion.confidence * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                ],

                // Matching Fields
                if (match.matchingFields.isNotEmpty) ...[
                  Text(
                    'Matching Fields (${match.matchingFields.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: match.matchingFields.map((field) {
                      return Chip(
                        label: Text(field, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: BorderSide(color: Colors.green.shade300),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Conflicts
                if (match.conflicts.isNotEmpty) ...[
                  Text(
                    'Conflicting Fields (${match.conflicts.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...match.conflicts.map((conflict) => Card(
                        color: Colors.orange.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conflict.field,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Form 1:',
                                            style: TextStyle(fontSize: 10)),
                                        const SizedBox(height: 4),
                                        Text(conflict.value1),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.swap_horiz, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Form 2:',
                                            style: TextStyle(fontSize: 10)),
                                        const SizedBox(height: 4),
                                        Text(conflict.value2),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _dismissMatch(match),
                      child: const Text('Not a duplicate'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showMergeDialog(context, match),
                      icon: const Icon(Icons.merge),
                      label: const Text('Merge Records'),
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

  String _getFormLabel(DataForm form) {
    if (form.fields.containsKey('name')) {
      return form.fields['name'].toString();
    }
    return 'Form ${form.id.substring(0, 8)}';
  }

  Color _getSimilarityColor(double similarity) {
    if (similarity >= 0.9) return Colors.red;
    if (similarity >= 0.8) return Colors.orange;
    if (similarity >= 0.7) return Colors.amber;
    return Colors.blue;
  }

  void _dismissMatch(DuplicateMatch match) {
    setState(() {
      _matches!.remove(match);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match dismissed')),
    );
  }

  void _showMergeDialog(BuildContext context, DuplicateMatch match) {
    showDialog(
      context: context,
      builder: (context) => _MergeDialog(
        match: match,
        onMerge: (merged) {
          _completeMerge(match, merged);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _completeMerge(DuplicateMatch match, DataForm merged) {
    // Update the primary form
    ref.read(dataFormsProvider.notifier).update(merged);

    // Remove the secondary form
    ref.read(dataFormsProvider.notifier).remove(match.form2.id);

    setState(() {
      _matches!.remove(match);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Records merged successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _MergeDialog extends StatefulWidget {
  final DuplicateMatch match;
  final Function(DataForm) onMerge;

  const _MergeDialog({
    required this.match,
    required this.onMerge,
  });

  @override
  State<_MergeDialog> createState() => _MergeDialogState();
}

class _MergeDialogState extends State<_MergeDialog> {
  MergeStrategy _strategy = MergeStrategy.preferHigherConfidence;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Merge Records'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select merge strategy:'),
            const SizedBox(height: 12),
            ...MergeStrategy.values.map((strategy) {
              return RadioListTile<MergeStrategy>(
                title: Text(_getStrategyName(strategy)),
                subtitle: Text(_getStrategyDescription(strategy)),
                value: strategy,
                groupValue: _strategy,
                onChanged: (value) {
                  setState(() => _strategy = value!);
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final merged = DeduplicationService.merge(
              widget.match.form1,
              widget.match.form2,
              _strategy,
            );
            widget.onMerge(merged);
          },
          child: const Text('Merge'),
        ),
      ],
    );
  }

  String _getStrategyName(MergeStrategy strategy) {
    switch (strategy) {
      case MergeStrategy.preferPrimary:
        return 'Prefer First Record';
      case MergeStrategy.preferSecondary:
        return 'Prefer Second Record';
      case MergeStrategy.preferNewer:
        return 'Prefer Newer';
      case MergeStrategy.preferHigherConfidence:
        return 'Prefer Higher Confidence';
      case MergeStrategy.preferLonger:
        return 'Prefer Longer Values';
      case MergeStrategy.combine:
        return 'Combine Values';
    }
  }

  String _getStrategyDescription(MergeStrategy strategy) {
    switch (strategy) {
      case MergeStrategy.preferPrimary:
        return 'Use values from the first record when there are conflicts';
      case MergeStrategy.preferSecondary:
        return 'Use values from the second record when there are conflicts';
      case MergeStrategy.preferNewer:
        return 'Use values from the most recently updated record';
      case MergeStrategy.preferHigherConfidence:
        return 'Use values from the record with higher confidence score';
      case MergeStrategy.preferLonger:
        return 'Use longer values (usually more detailed)';
      case MergeStrategy.combine:
        return 'Combine conflicting values (e.g., "Value1 / Value2")';
    }
  }
}
