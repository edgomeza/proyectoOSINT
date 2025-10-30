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
    return true;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
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
                  icon: Icons.arrow_back_ios_rounded,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPhaseIcon(currentPhase),
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentPhase.displayName,
                    style: TextStyle(
                      fontSize: 14,
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
                  icon: Icons.arrow_forward_ios_rounded,
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
            size: 14,
            color: isEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isNext) ...[
          const SizedBox(width: 8),
          Icon(
            icon,
            size: 14,
            color: isEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
          ),
        ],
      ],
    );

    if (!isEnabled) {
      return Opacity(
        opacity: 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: buttonContent,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: buttonContent,
        ),
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
        return Icons.edit_note_outlined;
      case InvestigationPhase.collection:
        return Icons.collections_bookmark_outlined;
      case InvestigationPhase.processing:
        return Icons.sync_outlined;
      case InvestigationPhase.analysis:
        return Icons.analytics_outlined;
      case InvestigationPhase.reports:
        return Icons.description_outlined;
    }
  }

  void _navigateToPhase(BuildContext context, InvestigationPhase phase) {
    final route = '/investigation/$investigationId/${phase.routeName}';
    context.go(route);
  }
}
