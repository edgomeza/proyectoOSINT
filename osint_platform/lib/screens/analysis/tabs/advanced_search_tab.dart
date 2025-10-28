import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/graph_provider.dart';
import '../../../providers/timeline_provider.dart';
import '../../../providers/geo_location_provider.dart';
import '../../../providers/data_forms_provider.dart';

class AdvancedSearchTab extends ConsumerStatefulWidget {
  final String investigationId;

  const AdvancedSearchTab({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<AdvancedSearchTab> createState() => _AdvancedSearchTabState();
}

class _AdvancedSearchTabState extends ConsumerState<AdvancedSearchTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  SearchCategory _selectedCategory = SearchCategory.all;
  List<SearchResult> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _searchResults = [];
    });

    final results = <SearchResult>[];

    // Search entities
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.entities) {
      final nodes = ref
          .read(nodesByInvestigationProvider(widget.investigationId));
      for (final node in nodes) {
        if (node.label.toLowerCase().contains(query) ||
            node.type.displayName.toLowerCase().contains(query) ||
            (node.description?.toLowerCase().contains(query) ?? false)) {
          results.add(SearchResult(
            title: node.label,
            subtitle: node.type.displayName,
            description: node.description,
            category: 'Entity',
            icon: Icons.hub,
            data: node,
          ));
        }
      }
    }

    // Search events
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.events) {
      final events = ref
          .read(eventsByInvestigationProvider(widget.investigationId));
      for (final event in events) {
        if (event.title.toLowerCase().contains(query) ||
            event.type.displayName.toLowerCase().contains(query) ||
            (event.description?.toLowerCase().contains(query) ?? false) ||
            (event.location?.toLowerCase().contains(query) ?? false)) {
          results.add(SearchResult(
            title: event.title,
            subtitle: event.type.displayName,
            description: event.description,
            category: 'Event',
            icon: Icons.timeline,
            data: event,
          ));
        }
      }
    }

    // Search locations
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.locations) {
      final locations = ref
          .read(locationsByInvestigationProvider(widget.investigationId));
      for (final location in locations) {
        if (location.name.toLowerCase().contains(query) ||
            location.type.displayName.toLowerCase().contains(query) ||
            (location.address?.toLowerCase().contains(query) ?? false) ||
            (location.description?.toLowerCase().contains(query) ?? false)) {
          results.add(SearchResult(
            title: location.name,
            subtitle: location.type.displayName,
            description: location.description,
            category: 'Location',
            icon: Icons.map,
            data: location,
          ));
        }
      }
    }

    // Search forms
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.forms) {
      final forms = ref
          .read(dataFormsByInvestigationProvider(widget.investigationId));
      for (final form in forms) {
        bool matches = false;
        String matchedField = '';

        for (final entry in form.fields.entries) {
          if (entry.key.toLowerCase().contains(query) ||
              entry.value.toString().toLowerCase().contains(query)) {
            matches = true;
            matchedField = '${entry.key}: ${entry.value}';
            break;
          }
        }

        if (matches) {
          results.add(SearchResult(
            title: form.category.displayName,
            subtitle: matchedField,
            description: form.notes,
            category: 'Form',
            icon: Icons.description,
            data: form,
          ));
        }
      }
    }

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advanced Search',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Search across all investigation data',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search entities, events, locations, and forms...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _performSearch(),
            onSubmitted: (value) => _performSearch(),
          ),
          const SizedBox(height: 16),

          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SearchCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _performSearch();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          if (_searchQuery.isNotEmpty) ...[
            Text(
              'Found ${_searchResults.length} results for "$_searchQuery"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
          ],

          Expanded(
            child: _searchResults.isEmpty && _searchQuery.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter a search query to find data',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found for "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return _buildResultCard(result);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(result.icon, color: Colors.blue),
        ),
        title: Text(
          result.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (result.description != null) ...[
              const SizedBox(height: 4),
              Text(
                result.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            result.category,
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
        ),
        onTap: () => _showResultDetails(result),
      ),
    );
  }

  void _showResultDetails(SearchResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', result.category),
              _buildDetailRow('Category', result.subtitle),
              if (result.description != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(result.description!),
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
}

class SearchResult {
  final String title;
  final String subtitle;
  final String? description;
  final String category;
  final IconData icon;
  final dynamic data;

  SearchResult({
    required this.title,
    required this.subtitle,
    this.description,
    required this.category,
    required this.icon,
    required this.data,
  });
}

enum SearchCategory {
  all,
  entities,
  events,
  locations,
  forms,
}

extension SearchCategoryExtension on SearchCategory {
  String get displayName {
    switch (this) {
      case SearchCategory.all:
        return 'All';
      case SearchCategory.entities:
        return 'Entities';
      case SearchCategory.events:
        return 'Events';
      case SearchCategory.locations:
        return 'Locations';
      case SearchCategory.forms:
        return 'Forms';
    }
  }
}
