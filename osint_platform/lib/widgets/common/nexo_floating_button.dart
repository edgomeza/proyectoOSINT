import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../providers/nexo_button_position_provider.dart';
import '../../config/theme.dart';
import 'nexo_avatar.dart';

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
    final position = ref.watch(nexoButtonPositionProvider);
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      right: position.x,
      bottom: position.y,
      child: Draggable(
        feedback: _buildButton(isDarkMode, isDragging: true),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          // Calcular nueva posición desde la esquina inferior derecha
          final newX = screenSize.width - details.offset.dx - 30; // 30 es la mitad del botón
          final newY = screenSize.height - details.offset.dy - 30;

          // Limitar los bordes
          final clampedX = newX.clamp(16.0, screenSize.width - 76.0);
          final clampedY = newY.clamp(16.0, screenSize.height - 76.0);

          ref.read(nexoButtonPositionProvider.notifier).updatePosition(clampedX, clampedY);
        },
        child: _buildButton(isDarkMode),
      ),
    );
  }

  Widget _buildButton(bool isDarkMode, {bool isDragging = false}) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                  .withValues(alpha: isDragging ? 0.7 : 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDragging ? null : () {
              context.push('/nexo');
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? AppTheme.darkPrimaryGradient
                    : AppTheme.lightPrimaryGradient,
                shape: BoxShape.circle,
              ),
              child: const NexoAvatar(size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
