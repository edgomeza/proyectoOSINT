import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/investigations_provider.dart';
import '../../../providers/graph_provider.dart';
import '../../../providers/timeline_provider.dart';
import '../../../providers/geo_location_provider.dart';
import '../../../services/report_generation_service.dart';

class ReportsTab extends ConsumerStatefulWidget {
  final String investigationId;

  const ReportsTab({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<ReportsTab> {
  bool _isGenerating = false;
  String? _lastGeneratedPath;

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(
      investigationByIdProvider(widget.investigationId),
    );

    if (investigation == null) {
      return const Center(child: Text('Investigation not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Generation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate comprehensive investigation reports',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),

          // Report Types
          _buildReportCard(
            context,
            title: 'Full Investigation Report',
            description:
                'Complete report with all entities, relationships, timeline, and geographic data',
            icon: Icons.description,
            color: Colors.blue,
            onGenerate: _generateFullReport,
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            context,
            title: 'Summary Report',
            description: 'Concise overview with key statistics and highlights',
            icon: Icons.summarize,
            color: Colors.green,
            onGenerate: _generateSummaryReport,
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            context,
            title: 'Custom Report',
            description: 'Select specific sections to include',
            icon: Icons.tune,
            color: Colors.purple,
            onGenerate: () => _showCustomReportDialog(context),
          ),
          const SizedBox(height: 24),

          // Generation Status
          if (_isGenerating)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Generating report...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),

          // Last Generated Report
          if (_lastGeneratedPath != null)
            Card(
              color: Colors.green.withValues(alpha:0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Report Generated Successfully',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Saved to: $_lastGeneratedPath',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Open file location
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Check your documents/reports folder'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Open Location'),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Report Settings
          Text(
            'Export Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Include Graphs'),
                    subtitle: const Text('Add relationship graph visualizations'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('Include Timeline'),
                    subtitle: const Text('Add chronological event timeline'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('Include Maps'),
                    subtitle: const Text('Add geographic location maps'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('Include High-Risk Items'),
                    subtitle: const Text('Highlight critical findings'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onGenerate,
  }) {
    return Card(
      child: InkWell(
        onTap: _isGenerating ? null : onGenerate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.outline,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateFullReport() async {
    setState(() => _isGenerating = true);

    try {
      final investigation = ref.read(
        investigationByIdProvider(widget.investigationId),
      )!;
      final nodes = ref.read(nodesByInvestigationProvider(widget.investigationId));
      final relationships = ref.read(
        relationshipsByInvestigationProvider(widget.investigationId),
      );
      final events = ref.read(
        eventsByInvestigationProvider(widget.investigationId),
      );
      final locations = ref.read(
        locationsByInvestigationProvider(widget.investigationId),
      );

      final file = await ReportGenerationService.generateInvestigationReport(
        investigation: investigation,
        nodes: nodes,
        relationships: relationships,
        events: events,
        locations: locations,
      );

      setState(() {
        _isGenerating = false;
        _lastGeneratedPath = file.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateSummaryReport() async {
    setState(() => _isGenerating = true);

    try {
      final investigation = ref.read(
        investigationByIdProvider(widget.investigationId),
      )!;
      final nodes = ref.read(nodesByInvestigationProvider(widget.investigationId));
      final relationships = ref.read(
        relationshipsByInvestigationProvider(widget.investigationId),
      );

      final file = await ReportGenerationService.generateSummaryReport(
        investigation: investigation,
        nodes: nodes,
        relationships: relationships,
      );

      setState(() {
        _isGenerating = false;
        _lastGeneratedPath = file.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Summary report generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCustomReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Report'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: Text('Executive Summary'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Entities'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Relationships'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Timeline'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Geographic Analysis'),
                value: true,
                onChanged: null,
              ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Custom report generation - coming soon'),
                ),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
