import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/data_form_status.dart';

class CategorySelector extends StatelessWidget {
  final DataFormCategory? selectedCategory;
  final Function(DataFormCategory) onCategorySelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona el tipo de información',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: DataFormCategory.values.map((category) {
              final isSelected = selectedCategory == category;
              return FadeIn(
                delay: Duration(milliseconds: DataFormCategory.values.indexOf(category) * 50),
                child: _buildCategoryChip(context, category, isSelected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, DataFormCategory category, bool isSelected) {
    final color = _getCategoryColor(category);

    return InkWell(
      onTap: () => onCategorySelected(category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha:0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              color: isSelected ? color : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? color : Colors.grey.shade800,
                  ),
                ),
                if (isSelected)
                  Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha:0.8),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
