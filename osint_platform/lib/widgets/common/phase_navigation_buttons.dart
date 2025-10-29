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
        ),
        IconButton(
          icon: const Icon(Icons.folder_outlined),
          onPressed: () => context.go('/investigations'),
          tooltip: 'Ver investigaciones',
        ),
      ],
    );
  }
}
