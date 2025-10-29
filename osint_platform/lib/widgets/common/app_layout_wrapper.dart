import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';
import 'nexo_floating_button.dart';

class AppLayoutWrapper extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool showNexoButton;
  final Widget child;

  const AppLayoutWrapper({
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.showNexoButton = true,
    required this.child,
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
          bottomNavigationBar: bottomNavigationBar,
        ),
        if (showNexoButton) const NexoFloatingButton(),
      ],
    );
  }
}
