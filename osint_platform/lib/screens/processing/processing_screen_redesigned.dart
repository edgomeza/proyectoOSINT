import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/navigation_drawer.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../models/investigation_phase.dart';
import '../../providers/investigations_provider.dart';
import '../../widgets/processing/deduplication_widget.dart';
import '../../widgets/processing/entity_linking_widget.dart';
import '../../widgets/processing/ner_extraction_widget.dart';

class ProcessingScreenRedesigned extends ConsumerStatefulWidget {
  final String investigationId;

  const ProcessingScreenRedesigned({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<ProcessingScreenRedesigned> createState() =>
      _ProcessingScreenRedesignedState();
}

class _ProcessingScreenRedesignedState
    extends ConsumerState<ProcessingScreenRedesigned>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(
      investigationByIdProvider(widget.investigationId),
    );

    if (investigation == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Investigation not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back to Home',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Processing', style: TextStyle(fontSize: 18)),
            Text(
              investigation.name,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.content_copy), text: 'Deduplication'),
            Tab(icon: Icon(Icons.psychology), text: 'NER Extraction'),
            Tab(icon: Icon(Icons.link), text: 'Entity Linking'),
          ],
        ),
      ),
      drawer: const AppNavigationDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Deduplication Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: DeduplicationWidget(
              investigationId: widget.investigationId,
            ),
          ),

          // NER Extraction Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: NERExtractionWidget(
              investigationId: widget.investigationId,
            ),
          ),

          // Entity Linking Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: EntityLinkingWidget(
              investigationId: widget.investigationId,
            ),
          ),
        ],
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: widget.investigationId,
        currentPhase: InvestigationPhase.processing,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Processing Screen Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The Processing screen helps you organize and analyze your collected data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• Deduplication: Find and merge duplicate records'),
              Text('• NER Extraction: Extract entities from text using AI'),
              Text('• Entity Linking: Convert forms to entities and create relationships'),
              SizedBox(height: 16),
              Text(
                'Tabs explained:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Deduplication: Uses AI to find similar records and suggests merging strategies',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                '2. NER Extraction: Extract people, organizations, locations, emails, and more from text',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                '3. Entity Linking: Create graph entities and relationships for analysis',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 16),
              Text(
                'Note: NER requires the Python backend to be running (see ner_backend/README.md)',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
