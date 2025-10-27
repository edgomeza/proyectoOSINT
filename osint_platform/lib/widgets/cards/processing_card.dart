import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../models/data_form.dart';
import '../../models/data_form_status.dart';

class ProcessingCard extends StatefulWidget {
  final DataForm form;
  final VoidCallback? onMarkReviewed;
  final VoidCallback? onSendToElasticsearch;
  final VoidCallback? onEdit;

  const ProcessingCard({
    super.key,
    required this.form,
    this.onMarkReviewed,
    this.onSendToElasticsearch,
    this.onEdit,
  });

  @override
  State<ProcessingCard> createState() => _ProcessingCardState();
}

class _ProcessingCardState extends State<ProcessingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final smartPriority = widget.form.smartPriority;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: _isExpanded ? 8 : 2,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Priority Badge
                        _buildPriorityBadge(smartPriority),
                        const SizedBox(width: 12),
                        // Category Icon and Name
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(widget.form.category).withValues(alpha:0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(widget.form.category),
                            color: _getCategoryColor(widget.form.category),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.form.category.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                dateFormat.format(widget.form.updatedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Metrics Row
                    Row(
                      children: [
                        _buildMetricChip(
                          icon: Icons.check_circle_outline,
                          label: '${(widget.form.completeness * 100).toInt()}%',
                          color: widget.form.completeness > 0.7 ? Colors.green : Colors.orange,
                          tooltip: 'Completitud',
                        ),
                        const SizedBox(width: 8),
                        _buildMetricChip(
                          icon: Icons.grade,
                          label: '${(widget.form.confidence * 100).toInt()}%',
                          color: widget.form.confidence > 0.7 ? Colors.blue : Colors.grey,
                          tooltip: 'Confianza',
                        ),
                        const SizedBox(width: 8),
                        _buildMetricChip(
                          icon: Icons.description_outlined,
                          label: '${widget.form.fields.length}',
                          color: Colors.purple,
                          tooltip: 'Campos',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Essential Fields Preview
                    if (!_isExpanded) _buildFieldsPreview(),
                  ],
                ),
              ),
            ),
            // Expanded Content
            if (_isExpanded) _buildExpandedContent(),
            // Actions
            if (_isExpanded) _buildActionsBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(int priority) {
    Color color;
    String label;
    IconData icon;

    if (priority >= 70) {
      color = Colors.red;
      label = 'Alta';
      icon = Icons.priority_high;
    } else if (priority >= 40) {
      color = Colors.orange;
      label = 'Media';
      icon = Icons.remove;
    } else {
      color = Colors.green;
      label = 'Baja';
      icon = Icons.low_priority;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsPreview() {
    final essentialFields = widget.form.fields.entries.take(2).toList();

    if (essentialFields.isEmpty) {
      return Text(
        'Sin datos',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: essentialFields.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(Icons.fiber_manual_record, size: 6, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpandedContent() {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Todos los campos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.form.fields.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (widget.form.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  widget.form.notes!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (widget.onEdit != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
              ),
            ),
          if (widget.onEdit != null) const SizedBox(width: 8),
          if (widget.onMarkReviewed != null &&
              widget.form.status != DataFormStatus.reviewed)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onMarkReviewed,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Revisado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          if (widget.onSendToElasticsearch != null &&
              widget.form.status == DataFormStatus.reviewed)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onSendToElasticsearch,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Enviar a ES'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getCategoryColor(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.person:
        return Colors.blue;
      case DataFormCategory.company:
        return Colors.purple;
      case DataFormCategory.socialNetwork:
        return Colors.orange;
      case DataFormCategory.location:
        return Colors.green;
      case DataFormCategory.relationship:
        return Colors.pink;
      case DataFormCategory.document:
        return Colors.indigo;
      case DataFormCategory.event:
        return Colors.teal;
      case DataFormCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.person:
        return Icons.person_outline;
      case DataFormCategory.company:
        return Icons.business_outlined;
      case DataFormCategory.socialNetwork:
        return Icons.share_outlined;
      case DataFormCategory.location:
        return Icons.location_on_outlined;
      case DataFormCategory.relationship:
        return Icons.people_outline;
      case DataFormCategory.document:
        return Icons.description_outlined;
      case DataFormCategory.event:
        return Icons.event_outlined;
      case DataFormCategory.other:
        return Icons.more_horiz;
    }
  }
}
