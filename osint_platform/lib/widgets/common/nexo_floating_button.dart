import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';

class NexoFloatingButton extends ConsumerStatefulWidget {
  const NexoFloatingButton({super.key});

  @override
  ConsumerState<NexoFloatingButton> createState() => _NexoFloatingButtonState();
}

class _NexoFloatingButtonState extends ConsumerState<NexoFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Positioned(
      right: 16,
      bottom: 16,
      child: FadeInUp(
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                      .withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'nexo_fab',
              onPressed: () {
                context.push('/nexo');
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? AppTheme.darkPrimaryGradient
                      : AppTheme.lightPrimaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
