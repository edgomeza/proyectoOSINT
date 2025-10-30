import 'package:flutter/material.dart';
import '../../models/investigation_phase.dart';

class PhaseBadge extends StatelessWidget {
  final InvestigationPhase phase;
  final bool isCompact;

  const PhaseBadge({
    super.key,
    required this.phase,
    this.isCompact = false,
  });

  Color _getPhaseColor() {
    switch (phase) {
      case InvestigationPhase.planning:
        return Colors.blue;
      case InvestigationPhase.collection:
        return Colors.orange;
      case InvestigationPhase.processing:
        return Colors.purple;
      case InvestigationPhase.analysis:
        return Colors.green;
      case InvestigationPhase.reports:
        return Colors.red;
    }
  }

  IconData _getPhaseIcon() {
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

  @override
  Widget build(BuildContext context) {
    final color = _getPhaseColor();

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getPhaseIcon(), size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              phase.displayName,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPhaseIcon(), size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            phase.displayName,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
