import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import '../../models/timeline_event.dart';
import '../../providers/timeline_provider.dart';

class DynamicTimelineWidget extends ConsumerStatefulWidget {
  final String investigationId;
  final Function(TimelineEvent)? onEventTap;
  final bool showFilters;

  const DynamicTimelineWidget({
    super.key,
    required this.investigationId,
    this.onEventTap,
    this.showFilters = true,
  });

  @override
  ConsumerState<DynamicTimelineWidget> createState() =>
      _DynamicTimelineWidgetState();
}

class _DynamicTimelineWidgetState
    extends ConsumerState<DynamicTimelineWidget> {
  // Filters
  Set<TimelineEventType> selectedTypes = {};
  Set<EventPriority> selectedPriorities = {};
  DateTime? startDate;
  DateTime? endDate;
  bool groupByDate = true;

  @override
  Widget build(BuildContext context) {
    final events =
        ref.watch(eventsByInvestigationProvider(widget.investigationId));

    // Apply filters
    final filteredEvents = _filterEvents(events);

    // Group by date if enabled
    final groupedEvents = groupByDate
        ? _groupEventsByDate(filteredEvents)
        : {'All Events': filteredEvents};

    return Column(
      children: [
        if (widget.showFilters) _buildFilterBar(context),
        Expanded(
          child: filteredEvents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedEvents.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedEvents.keys.elementAt(index);
                    final dayEvents = groupedEvents[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (groupByDate) _buildDateHeader(context, dateKey),
                        ...dayEvents.asMap().entries.map((entry) {
                          final eventIndex = entry.key;
                          final event = entry.value;
                          final isFirst = eventIndex == 0;
                          final isLast = eventIndex == dayEvents.length - 1;

                          return _buildTimelineTile(
                            context,
                            event,
                            isFirst: isFirst && !groupByDate,
                            isLast: isLast && index == groupedEvents.length - 1,
                          );
                        }),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Type Filter
            _buildFilterChip(
              context,
              icon: Icons.category,
              label: 'Type',
              onTap: () => _showTypeFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Priority Filter
            _buildFilterChip(
              context,
              icon: Icons.flag,
              label: 'Priority',
              onTap: () => _showPriorityFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Date Range
            _buildFilterChip(
              context,
              icon: Icons.date_range,
              label: startDate != null
                  ? 'Date Range'
                  : 'All Dates',
              onTap: () => _showDateRangeDialog(context),
            ),
            const SizedBox(width: 8),

            // Group by Date Toggle
            _buildFilterChip(
              context,
              icon: groupByDate ? Icons.view_day : Icons.view_stream,
              label: groupByDate ? 'Grouped' : 'Linear',
              onTap: () => setState(() => groupByDate = !groupByDate),
            ),
            const SizedBox(width: 8),

            // Reset
            _buildFilterChip(
              context,
              icon: Icons.refresh,
              label: 'Reset',
              onTap: _resetFilters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String dateKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 16, bottom: 8),
      child: Text(
        dateKey,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    TimelineEvent event, {
    required bool isFirst,
    required bool isLast,
  }) {
    final color = _getEventColor(event.type, event.priority);
    final timeFormat = DateFormat('HH:mm');

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.2,
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: color.withOpacity(0.5),
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicator: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getEventIcon(event.type),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      endChild: InkWell(
        onTap: () => widget.onEventTap?.call(event),
        child: Container(
          margin: const EdgeInsets.only(left: 16, bottom: 16, right: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildPriorityBadge(context, event.priority),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(event.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  if (event.location != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        event.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (event.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: event.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              if (event.entityIds.isNotEmpty ||
                  event.relationshipIds.isNotEmpty ||
                  event.evidenceIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (event.entityIds.isNotEmpty)
                      _buildCountBadge(
                        context,
                        Icons.person,
                        event.entityIds.length,
                      ),
                    if (event.relationshipIds.isNotEmpty)
                      _buildCountBadge(
                        context,
                        Icons.link,
                        event.relationshipIds.length,
                      ),
                    if (event.evidenceIds.isNotEmpty)
                      _buildCountBadge(
                        context,
                        Icons.description,
                        event.evidenceIds.length,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, EventPriority priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCountBadge(BuildContext context, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No timeline events',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Events will appear here as you build your investigation',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<TimelineEvent> _filterEvents(List<TimelineEvent> events) {
    return events.where((event) {
      if (selectedTypes.isNotEmpty && !selectedTypes.contains(event.type)) {
        return false;
      }
      if (selectedPriorities.isNotEmpty &&
          !selectedPriorities.contains(event.priority)) {
        return false;
      }
      if (startDate != null && event.timestamp.isBefore(startDate!)) {
        return false;
      }
      if (endDate != null && event.timestamp.isAfter(endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  Map<String, List<TimelineEvent>> _groupEventsByDate(
    List<TimelineEvent> events,
  ) {
    final grouped = <String, List<TimelineEvent>>{};
    final dateFormat = DateFormat('MMMM dd, yyyy');

    for (final event in events) {
      final dateKey = dateFormat.format(event.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(event);
    }

    return grouped;
  }

  Color _getEventColor(TimelineEventType type, EventPriority priority) {
    if (priority == EventPriority.critical) return Colors.red.shade700;
    if (priority == EventPriority.high) return Colors.orange.shade600;

    switch (type) {
      case TimelineEventType.meeting:
        return Colors.blue.shade600;
      case TimelineEventType.transaction:
        return Colors.green.shade600;
      case TimelineEventType.communication:
        return Colors.cyan.shade600;
      case TimelineEventType.travel:
        return Colors.purple.shade600;
      case TimelineEventType.arrest:
        return Colors.red.shade700;
      case TimelineEventType.alert:
        return Colors.amber.shade700;
      case TimelineEventType.discovery:
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getEventIcon(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.meeting:
        return Icons.groups;
      case TimelineEventType.transaction:
        return Icons.payment;
      case TimelineEventType.communication:
        return Icons.chat;
      case TimelineEventType.travel:
        return Icons.flight;
      case TimelineEventType.registration:
        return Icons.app_registration;
      case TimelineEventType.employment:
        return Icons.work;
      case TimelineEventType.investigation:
        return Icons.search;
      case TimelineEventType.arrest:
        return Icons.local_police;
      case TimelineEventType.court:
        return Icons.gavel;
      case TimelineEventType.social:
        return Icons.people;
      case TimelineEventType.publication:
        return Icons.article;
      case TimelineEventType.alert:
        return Icons.notification_important;
      case TimelineEventType.discovery:
        return Icons.lightbulb;
      default:
        return Icons.event;
    }
  }

  Color _getPriorityColor(EventPriority priority) {
    switch (priority) {
      case EventPriority.critical:
        return Colors.red;
      case EventPriority.high:
        return Colors.orange;
      case EventPriority.medium:
        return Colors.blue;
      case EventPriority.low:
        return Colors.green;
    }
  }

  void _showTypeFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: TimelineEventType.values.map((type) {
                return CheckboxListTile(
                  title: Text(type.displayName),
                  value: selectedTypes.contains(type),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        selectedTypes.add(type);
                      } else {
                        selectedTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => selectedTypes.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showPriorityFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Priority'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: EventPriority.values.map((priority) {
              return CheckboxListTile(
                title: Text(priority.displayName),
                value: selectedPriorities.contains(priority),
                onChanged: (value) {
                  setDialogState(() {
                    if (value == true) {
                      selectedPriorities.add(priority);
                    } else {
                      selectedPriorities.remove(priority);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => selectedPriorities.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showDateRangeDialog(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      selectedTypes.clear();
      selectedPriorities.clear();
      startDate = null;
      endDate = null;
    });
  }
}
