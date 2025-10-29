import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';
import 'nexo_floating_button.dart';

class AppLayoutWrapper extends ConsumerWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showNexoButton;

  const AppLayoutWrapper({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showNexoButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Stack(
      children: [
        Scaffold(
          appBar: appBar,
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode ? AppTheme.darkGradient : AppTheme.lightGradient,
            ),
            child: child,
          ),
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
        ),
        if (showNexoButton) const NexoFloatingButton(),
      ],
    );
  }
}
