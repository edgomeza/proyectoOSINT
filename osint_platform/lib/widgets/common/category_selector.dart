import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/data_form_status.dart';

class CategorySelector extends StatelessWidget {
  final DataFormCategory? selectedCategory;
  final Function(DataFormCategory) onCategorySelected;
  final List<DataFormCategory>? availableCategories;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.availableCategories,
  });

  @override
  Widget build(BuildContext context) {
    final categories = availableCategories ?? DataFormCategory.values;

    return FadeIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de información',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((category) {
              final isSelected = selectedCategory == category;
              return _buildCategoryChip(context, category, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, DataFormCategory category, bool isSelected) {
    final color = _getCategoryColor(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCategorySelected(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(15)
                : Theme.of(context).cardColor,
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(category),
                color: isSelected ? color : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ],
          ),
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
