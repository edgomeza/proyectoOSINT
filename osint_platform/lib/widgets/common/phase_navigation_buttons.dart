import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhaseNavigationButtons extends StatelessWidget {
  const PhaseNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/'),
          tooltip: 'Ir al inicio',
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.folder_outlined),
          onPressed: () => context.go('/investigations'),
          tooltip: 'Ver investigaciones',
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
