import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/navigation_drawer.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../models/investigation_phase.dart';
import '../../providers/investigations_provider.dart';
import '../../providers/graph_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/geo_location_provider.dart';
import '../../widgets/graph/interactive_graph_widget.dart';
import '../../widgets/timeline/timeline_widget.dart';
import '../../widgets/map/geographic_map_widget.dart';
import 'tabs/overview_tab.dart';
import 'tabs/analysis_tools_tab.dart';
import 'tabs/reports_tab.dart';

class AnalysisScreenRedesigned extends ConsumerStatefulWidget {
  final String investigationId;

  const AnalysisScreenRedesigned({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<AnalysisScreenRedesigned> createState() =>
      _AnalysisScreenRedesignedState();
}

class _AnalysisScreenRedesignedState
    extends ConsumerState<AnalysisScreenRedesigned>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
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

    // Get statistics
    final graphStats = ref.watch(graphStatsProvider);
    final timelineStats = ref.watch(timelineStatsProvider);
    ref.watch(geoStatsProvider);

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
            const Text('Analysis', style: TextStyle(fontSize: 18)),
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
          // Statistics Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hub,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${graphStats.totalNodes}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.timeline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${timelineStats.totalEvents}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.hub), text: 'Graph'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
            Tab(icon: Icon(Icons.analytics), text: 'Tools'),
            Tab(icon: Icon(Icons.description), text: 'Reports'),
          ],
        ),
      ),
      drawer: const AppNavigationDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          OverviewTab(investigationId: widget.investigationId),

          // Graph Tab
          InteractiveGraphWidget(
            investigationId: widget.investigationId,
            onNodeTap: (node) => _showNodeDetails(context, node),
            onEdgeTap: (edge) => _showEdgeDetails(context, edge),
          ),

          // Timeline Tab
          DynamicTimelineWidget(
            investigationId: widget.investigationId,
            onEventTap: (event) => _showEventDetails(context, event),
          ),

          // Map Tab
          GeographicMapWidget(
            investigationId: widget.investigationId,
            onLocationTap: (location) => _showLocationDetails(context, location),
          ),

          // Analysis Tools Tab
          AnalysisToolsTab(investigationId: widget.investigationId),

          // Reports Tab
          ReportsTab(investigationId: widget.investigationId),
        ],
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: widget.investigationId,
        currentPhase: InvestigationPhase.analysis,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    switch (_currentTabIndex) {
      case 1: // Graph tab
        return FloatingActionButton.extended(
          heroTag: 'add_node',
          onPressed: () => _showAddNodeDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Entity'),
        );
      case 2: // Timeline tab
        return FloatingActionButton.extended(
          heroTag: 'add_event',
          onPressed: () => _showAddEventDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Event'),
        );
      case 3: // Map tab
        return FloatingActionButton.extended(
          heroTag: 'add_location',
          onPressed: () => _showAddLocationDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Location'),
        );
      default:
        return null;
    }
  }

  void _showNodeDetails(BuildContext context, node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(node.label)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', node.type.displayName),
              _buildDetailRow('Risk Level', node.riskLevel.displayName),
              _buildDetailRow(
                'Confidence',
                '${(node.confidence * 100).toInt()}%',
              ),
              if (node.description != null) ...[
                const SizedBox(height: 8),
                Text(node.description!),
              ],
              if (node.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: node.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEdgeDetails(BuildContext context, edge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(edge.label),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Type', edge.type.displayName),
            _buildDetailRow('Confidence', '${(edge.confidence * 100).toInt()}%'),
            _buildDetailRow('Weight', edge.weight.toString()),
            if (edge.description != null) ...[
              const SizedBox(height: 8),
              Text(edge.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', event.timestamp.toString()),
              _buildDetailRow('Type', event.type.displayName),
              _buildDetailRow('Priority', event.priority.displayName),
              if (event.location != null)
                _buildDetailRow('Location', event.location!),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(event.description!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(BuildContext context, location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Type', location.type.displayName),
            _buildDetailRow('Risk', location.risk.displayName),
            _buildDetailRow(
              'Coordinates',
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
            ),
            if (location.address != null)
              _buildDetailRow('Address', location.address!),
            if (location.description != null) ...[
              const SizedBox(height: 8),
              Text(location.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddNodeDialog(BuildContext context) {
    // Placeholder - will be implemented with entity creation form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entity creation form - to be implemented'),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    // Placeholder - will be implemented with event creation form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event creation form - to be implemented'),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    // Placeholder - will be implemented with location creation form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location creation form - to be implemented'),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Screen Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This screen provides comprehensive analysis tools for your investigation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• Overview: Summary and statistics'),
              Text('• Graph: Interactive relationship visualization'),
              Text('• Timeline: Chronological events'),
              Text('• Map: Geographic analysis with heatmaps'),
              Text('• Tools: Advanced analysis algorithms'),
              Text('• Reports: Generate and export reports'),
              SizedBox(height: 16),
              Text(
                'Use the tabs to switch between different analysis views.',
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
