import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:osint_platform/models/relationship.dart';
import '../../../providers/graph_provider.dart';
import '../../../services/graph_analysis_service.dart';
import '../../../models/entity_node.dart';

class AnalysisToolsTab extends ConsumerStatefulWidget {
  final String investigationId;

  const AnalysisToolsTab({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<AnalysisToolsTab> createState() => _AnalysisToolsTabState();
}

class _AnalysisToolsTabState extends ConsumerState<AnalysisToolsTab> {
  List<EntityNode>? _pathResult;
  List<EntityNode>? _searchResult;
  List<({EntityNode node, int connections})>? _centralNodesResult;
  List<List<EntityNode>>? _componentsResult;
  List<({EntityNode node1, EntityNode node2, double similarity})>? _duplicatesResult;

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodesByInvestigationProvider(widget.investigationId));
    final relationships = ref.watch(relationshipsByInvestigationProvider(widget.investigationId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Graph Analysis Tools',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Advanced algorithms for analyzing relationships and patterns',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),

          // Tools Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildToolCard(
                context,
                title: 'Shortest Path',
                description: 'Find shortest path between two entities',
                icon: Icons.route,
                color: Colors.blue,
                onTap: () => _showShortestPathDialog(context, nodes, relationships),
              ),
              _buildToolCard(
                context,
                title: 'Central Nodes',
                description: 'Find most connected entities',
                icon: Icons.hub,
                color: Colors.purple,
                onTap: () => _analyzeCentralNodes(nodes, relationships),
              ),
              _buildToolCard(
                context,
                title: 'Attribute Search',
                description: 'Advanced search by attributes',
                icon: Icons.search,
                color: Colors.green,
                onTap: () => _showAttributeSearchDialog(context, nodes),
              ),
              _buildToolCard(
                context,
                title: 'Connected Components',
                description: 'Find isolated subgraphs',
                icon: Icons.scatter_plot,
                color: Colors.orange,
                onTap: () => _analyzeComponents(nodes, relationships),
              ),
              _buildToolCard(
                context,
                title: 'Find Duplicates',
                description: 'Identify potential duplicate entities',
                icon: Icons.content_copy,
                color: Colors.red,
                onTap: () => _analyzeDuplicates(nodes),
              ),
              _buildToolCard(
                context,
                title: 'Bridge Nodes',
                description: 'Find critical connection points',
                icon: Icons.link_off,
                color: Colors.cyan,
                onTap: () => _analyzeBridgeNodes(nodes, relationships),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Results Section
          if (_pathResult != null) _buildPathResult(context),
          if (_searchResult != null) _buildSearchResult(context),
          if (_centralNodesResult != null) _buildCentralNodesResult(context),
          if (_componentsResult != null) _buildComponentsResult(context),
          if (_duplicatesResult != null) _buildDuplicatesResult(context),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShortestPathDialog(
    BuildContext context,
    List<EntityNode> nodes,
    List<Relationship> relationships,
  ) {
    if (nodes.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 2 entities')),
      );
      return;
    }

    EntityNode? startNode;
    EntityNode? endNode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Find Shortest Path'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<EntityNode>(
                decoration: const InputDecoration(labelText: 'Start Node'),
                items: nodes.map((node) {
                  return DropdownMenuItem(
                    value: node,
                    child: Text(node.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => startNode = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EntityNode>(
                decoration: const InputDecoration(labelText: 'End Node'),
                items: nodes.map((node) {
                  return DropdownMenuItem(
                    value: node,
                    child: Text(node.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => endNode = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: startNode != null && endNode != null
                  ? () {
                      final path = GraphAnalysisService.findShortestPath(
                        startNode!,
                        endNode!,
                        nodes,
                        relationships,
                      );
                      Navigator.pop(context);
                      this.setState(() => _pathResult = path);
                    }
                  : null,
              child: const Text('Find Path'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttributeSearchDialog(BuildContext context, List<EntityNode> nodes) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search by Attributes'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search query',
            hintText: 'Enter search term',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text.toLowerCase();
              final results = nodes.where((node) {
                return node.label.toLowerCase().contains(query) ||
                    (node.description?.toLowerCase().contains(query) ?? false);
              }).toList();

              Navigator.pop(context);
              setState(() => _searchResult = results);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _analyzeCentralNodes(List<EntityNode> nodes, List<Relationship> relationships) {
    final result = GraphAnalysisService.findCentralNodes(
      nodes,
      relationships,
      topN: 10,
    );
    setState(() => _centralNodesResult = result);
  }

  void _analyzeComponents(List<EntityNode> nodes, List<Relationship> relationships) {
    final result = GraphAnalysisService.findConnectedComponents(
      nodes,
      relationships,
    );
    setState(() => _componentsResult = result);
  }

  void _analyzeDuplicates(List<EntityNode> nodes) {
    final result = GraphAnalysisService.findPotentialDuplicates(
      nodes,
      similarityThreshold: 0.6,
    );
    setState(() => _duplicatesResult = result);
  }

  void _analyzeBridgeNodes(List<EntityNode> nodes, List<Relationship> relationships) {
    final result = GraphAnalysisService.findBridgeNodes(nodes, relationships);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Found ${result.length} bridge nodes')),
    );
    setState(() => _searchResult = result);
  }

  Widget _buildPathResult(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shortest Path',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _pathResult = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_pathResult == null)
              const Text('No path found')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _pathResult!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final node = entry.value;
                  return Row(
                    children: [
                      Text('${index + 1}. ${node.label}'),
                      if (index < _pathResult!.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward, size: 16),
                        ),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Results (${_searchResult!.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _searchResult = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._searchResult!.map((node) => ListTile(
                  leading: const Icon(Icons.circle, size: 8),
                  title: Text(node.label),
                  subtitle: Text(node.type.displayName),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralNodesResult(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Central Nodes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _centralNodesResult = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._centralNodesResult!.map((result) => ListTile(
                  leading: CircleAvatar(
                    child: Text('${result.connections}'),
                  ),
                  title: Text(result.node.label),
                  subtitle: Text('${result.connections} connections'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentsResult(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connected Components (${_componentsResult!.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _componentsResult = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._componentsResult!.asMap().entries.map((entry) {
              final index = entry.key;
              final component = entry.value;
              return ExpansionTile(
                title: Text('Component ${index + 1} (${component.length} nodes)'),
                children: component
                    .map((node) => ListTile(
                          leading: const Icon(Icons.circle, size: 8),
                          title: Text(node.label),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDuplicatesResult(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Potential Duplicates (${_duplicatesResult!.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _duplicatesResult = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._duplicatesResult!.map((result) => ListTile(
                  title: Text('${result.node1.label} ↔ ${result.node2.label}'),
                  subtitle: Text('Similarity: ${(result.similarity * 100).toInt()}%'),
                  trailing: SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: result.similarity,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
