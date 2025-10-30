import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/data_form_status.dart';

class CategorySelector extends StatefulWidget {
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
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  DataFormCategory? _hoveredCategory;

  @override
  Widget build(BuildContext context) {
    final categories = widget.availableCategories ?? DataFormCategory.values;

    return FadeIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade400,
                      Colors.indigo.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tipo de información',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final isSelected = widget.selectedCategory == category;
              final isHovered = _hoveredCategory == category;
              return FadeIn(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: 100 + (index * 50)),
                child: _buildCategoryCard(
                  context,
                  category,
                  isSelected,
                  isHovered,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    DataFormCategory category,
    bool isSelected,
    bool isHovered,
  ) {
    final color = _getCategoryColor(category);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredCategory = category),
      onExit: (_) => setState(() => _hoveredCategory = null),
      child: GestureDetector(
        onTap: () => widget.onCategorySelected(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : isHovered
                    ? color.withAlpha(20)
                    : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected || isHovered
                  ? color
                  : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected || isHovered)
                BoxShadow(
                  color: color.withAlpha(isSelected ? 40 : 20),
                  blurRadius: isSelected ? 12 : 8,
                  offset: Offset(0, isSelected ? 4 : 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(30)
                      : color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: isSelected ? Colors.white : color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[800],
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
        return Colors.blue.shade600;
      case DataFormCategory.digitalData:
        return Colors.purple.shade600;
      case DataFormCategory.geographicData:
        return Colors.green.shade600;
      case DataFormCategory.temporalData:
        return Colors.teal.shade600;
      case DataFormCategory.financialData:
        return Colors.amber.shade700;
      case DataFormCategory.socialMediaData:
        return Colors.orange.shade600;
      case DataFormCategory.multimediaData:
        return Colors.pink.shade600;
      case DataFormCategory.technicalData:
        return Colors.indigo.shade600;
      case DataFormCategory.corporateData:
        return Colors.deepPurple.shade600;
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
