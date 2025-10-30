import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../models/data_form.dart';
import '../../models/data_form_status.dart';

class DataFormCard extends StatelessWidget {
  final DataForm form;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSendToProcessing;

  const DataFormCard({
    super.key,
    required this.form,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSendToProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(form.category).withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(form.category),
                        color: _getCategoryColor(form.category),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            form.category.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateFormat.format(form.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(form.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildFieldsPreview(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: form.completeness,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          form.completeness > 0.7 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(form.completeness * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: form.completeness > 0.7 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (onEdit != null && form.status == DataFormStatus.draft)
                      _buildActionChip(
                        context: context,
                        icon: Icons.edit,
                        label: 'Editar',
                        onTap: onEdit!,
                        color: Colors.blue,
                      ),
                    if (onSendToProcessing != null && form.status == DataFormStatus.draft)
                      _buildActionChip(
                        context: context,
                        icon: Icons.send,
                        label: 'Enviar',
                        onTap: onSendToProcessing!,
                        color: Colors.green,
                      ),
                    if (onDelete != null)
                      _buildActionChip(
                        context: context,
                        icon: Icons.delete_outline,
                        label: 'Eliminar',
                        onTap: onDelete!,
                        color: Colors.red,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldsPreview() {
    final nonEmptyFields = form.fields.entries
        .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
        .take(3)
        .toList();

    if (nonEmptyFields.isEmpty) {
      return Text(
        'Sin datos',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nonEmptyFields.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[800], fontSize: 13),
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: entry.value.toString()),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(DataFormStatus status) {
    Color color;
    String text;

    switch (status) {
      case DataFormStatus.draft:
        color = Colors.orange;
        text = 'Borrador';
        break;
      case DataFormStatus.collected:
        color = Colors.blue;
        text = 'Recopilado';
        break;
      case DataFormStatus.inReview:
        color = Colors.purple;
        text = 'En Revisión';
        break;
      case DataFormStatus.reviewed:
        color = Colors.green;
        text = 'Revisado';
        break;
      case DataFormStatus.sent:
        color = Colors.teal;
        text = 'Enviado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha:0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.personalData:
        return Colors.blue;
      case DataFormCategory.digitalData:
        return Colors.purple;
      case DataFormCategory.geographicData:
        return Colors.green;
      case DataFormCategory.temporalData:
        return Colors.teal;
      case DataFormCategory.financialData:
        return Colors.amber;
      case DataFormCategory.socialMediaData:
        return Colors.orange;
      case DataFormCategory.multimediaData:
        return Colors.pink;
      case DataFormCategory.technicalData:
        return Colors.indigo;
      case DataFormCategory.corporateData:
        return Colors.deepPurple;
    }
  }

  IconData _getCategoryIcon(DataFormCategory category) {
    switch (category) {
      case DataFormCategory.personalData:
        return Icons.person_outline;
      case DataFormCategory.digitalData:
        return Icons.dns_outlined;
      case DataFormCategory.geographicData:
        return Icons.location_on_outlined;
      case DataFormCategory.temporalData:
        return Icons.schedule_outlined;
      case DataFormCategory.financialData:
        return Icons.attach_money_outlined;
      case DataFormCategory.socialMediaData:
        return Icons.share_outlined;
      case DataFormCategory.multimediaData:
        return Icons.perm_media_outlined;
      case DataFormCategory.technicalData:
        return Icons.code_outlined;
      case DataFormCategory.corporateData:
        return Icons.business_outlined;
    }
  }
}
