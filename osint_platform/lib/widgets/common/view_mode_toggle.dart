import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/view_mode_provider.dart';

class ViewModeToggle extends ConsumerWidget {
  const ViewModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final isSimple = viewMode == ViewMode.simple;

    return ZoomIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(
              context: context,
              ref: ref,
              icon: Icons.view_agenda_outlined,
              label: 'Simple',
              isActive: isSimple,
              onTap: () {
                if (!isSimple) {
                  ref.read(viewModeProvider.notifier).state = ViewMode.simple;
                }
              },
            ),
            Container(
              width: 1,
              height: 32,
              color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
            ),
            _buildToggleButton(
              context: context,
              ref: ref,
              icon: Icons.dashboard_outlined,
              label: 'Detallada',
              isActive: !isSimple,
              onTap: () {
                if (isSimple) {
                  ref.read(viewModeProvider.notifier).state = ViewMode.detailed;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha:0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
