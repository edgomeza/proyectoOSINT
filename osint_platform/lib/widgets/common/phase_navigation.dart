import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/investigation_phase.dart';
import '../../providers/data_forms_provider.dart';

class PhaseNavigation extends ConsumerWidget {
  final String investigationId;
  final InvestigationPhase currentPhase;

  const PhaseNavigation({
    super.key,
    required this.investigationId,
    required this.currentPhase,
  });

  bool _hasDataForPhase(InvestigationPhase phase, List<dynamic> forms) {
    // Planning siempre tiene datos (los objetivos y preguntas)
    if (phase == InvestigationPhase.planning) {
      return true;
    }

    // Collection tiene datos si hay formularios en draft o en collection
    if (phase == InvestigationPhase.collection) {
      return forms.any((form) =>
        form.status.index <= 1 // draft o inCollection
      );
    }

    // Processing tiene datos si hay formularios en processing o reviewed
    if (phase == InvestigationPhase.processing) {
      return forms.any((form) =>
        form.status.index >= 2 && form.status.index <= 3 // inProcessing o reviewed
      );
    }

    // Analysis tiene datos si hay formularios enviados a ES
    if (phase == InvestigationPhase.analysis) {
      return forms.any((form) =>
        form.status.index >= 4 // sentToES
      );
    }

    // Reports siempre está disponible si hay datos en cualquier fase
    if (phase == InvestigationPhase.reports) {
      return forms.isNotEmpty;
    }

    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forms = ref.watch(dataFormsByInvestigationProvider(investigationId));

    final previousPhase = _getPreviousPhase();
    final nextPhase = _getNextPhase();

    final hasPreviousData = previousPhase != null && _hasDataForPhase(previousPhase, forms);
    final hasNextData = nextPhase != null && _hasDataForPhase(nextPhase, forms);

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón anterior
            if (previousPhase != null)
              Expanded(
                child: _buildNavigationButton(
                  context: context,
                  label: previousPhase.displayName,
                  icon: Icons.arrow_back,
                  isNext: false,
                  isEnabled: hasPreviousData,
                  onTap: hasPreviousData
                      ? () => _navigateToPhase(context, previousPhase)
                      : null,
                ),
              )
            else
              const Expanded(child: SizedBox()),

            // Indicador de fase actual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPhaseIcon(currentPhase),
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentPhase.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Botón siguiente
            if (nextPhase != null)
              Expanded(
                child: _buildNavigationButton(
                  context: context,
                  label: nextPhase.displayName,
                  icon: Icons.arrow_forward,
                  isNext: true,
                  isEnabled: hasNextData,
                  onTap: hasNextData
                      ? () => _navigateToPhase(context, nextPhase)
                      : null,
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isNext,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isNext ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isNext) ...[
          Icon(
            icon,
            size: 16,
            color: isEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isNext) ...[
          const SizedBox(width: 6),
          Icon(
            icon,
            size: 16,
            color: isEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
          ),
        ],
      ],
    );

    if (!isEnabled) {
      return Tooltip(
        message: 'No hay datos en esta fase',
        child: Opacity(
          opacity: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: buttonContent,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: buttonContent,
      ),
    );
  }

  InvestigationPhase? _getPreviousPhase() {
    final currentIndex = InvestigationPhase.values.indexOf(currentPhase);
    if (currentIndex > 0) {
      return InvestigationPhase.values[currentIndex - 1];
    }
    return null;
  }

  InvestigationPhase? _getNextPhase() {
    final currentIndex = InvestigationPhase.values.indexOf(currentPhase);
    if (currentIndex < InvestigationPhase.values.length - 1) {
      return InvestigationPhase.values[currentIndex + 1];
    }
    return null;
  }

  IconData _getPhaseIcon(InvestigationPhase phase) {
    switch (phase) {
      case InvestigationPhase.planning:
        return Icons.edit_note;
      case InvestigationPhase.collection:
        return Icons.collections_bookmark;
      case InvestigationPhase.processing:
        return Icons.sync;
      case InvestigationPhase.analysis:
        return Icons.analytics;
      case InvestigationPhase.reports:
        return Icons.description;
    }
  }

  void _navigateToPhase(BuildContext context, InvestigationPhase phase) {
    final route = '/investigation/$investigationId/${phase.routeName}';
    context.go(route);
  }
}
