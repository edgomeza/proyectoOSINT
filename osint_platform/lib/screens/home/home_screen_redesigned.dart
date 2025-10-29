import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/common/language_selector.dart';
import '../../widgets/common/elk_services_indicator.dart';
import '../../widgets/common/nexo_avatar.dart';
import '../../config/theme.dart';

class HomeScreenRedesigned extends ConsumerWidget {
  const HomeScreenRedesigned({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // AppBar personalizado
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      ELKServicesIndicator(),
                      SizedBox(width: 12),
                      LanguageSelector(),
                      SizedBox(width: 8),
                      ThemeToggleButton(),
                    ],
                  ),
                ),
              ),

              // Contenido principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo / Icono principal
                      FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? AppTheme.darkPrimaryGradient
                                : AppTheme.lightPrimaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode
                                        ? AppTheme.darkPrimary
                                        : AppTheme.lightPrimary)
                                    .withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Título
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Plataforma OSINT',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: size.width > 600 ? 48 : 36,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Descripción
                      FadeInDown(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Text(
                            'Sistema avanzado de inteligencia de fuentes abiertas (OSINT) '
                            'diseñado para investigaciones profesionales. Recopila, procesa '
                            'y analiza información de múltiples fuentes con tecnología de '
                            'inteligencia artificial.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Colors.black.withValues(alpha: 0.7),
                                  height: 1.6,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Tarjetas de características
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeatureChip(context, Icons.analytics_outlined, 'Análisis Avanzado', isDarkMode),
                            _buildFeatureChip(context, Icons.shield_outlined, 'Seguro', isDarkMode),
                            _buildFeatureChip(context, Icons.speed_outlined, 'Rápido', isDarkMode),
                            _buildFeatureChip(context, Icons.cloud_outlined, 'Cloud ELK', isDarkMode),
                          ],
                        ),
                      ),

                      const SizedBox(height: 64),

                      // Botones principales
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width > 800 ? 800 : double.infinity),
                        child: size.width > 600
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildNexoButton(context, isDarkMode),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildInvestigationsButton(context, isDarkMode),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildNexoButton(context, isDarkMode),
                                  const SizedBox(height: 24),
                                  _buildInvestigationsButton(context, isDarkMode),
                                ],
                              ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNexoButton(BuildContext context, bool isDarkMode) {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: InkWell(
        onTap: () {
          context.push('/nexo');
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF2196F3),
                      const Color(0xFF1976D2),
                    ]
                  : [
                      const Color(0xFFFFB74D),
                      const Color(0xFFFF9800),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Patrón de fondo
              Positioned.fill(
                child: CustomPaint(
                  painter: _CirclePatternPainter(isDarkMode),
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de Nexo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const NexoAvatar(size: 56),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nexo AI',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu asistente inteligente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestigationsButton(BuildContext context, bool isDarkMode) {
    return FadeInUp(
      delay: const Duration(milliseconds: 1000),
      child: InkWell(
        onTap: () {
          context.push('/investigations');
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF42A5F5),
                      const Color(0xFF1E88E5),
                    ]
                  : [
                      const Color(0xFFFF9800),
                      const Color(0xFFF57C00),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? AppTheme.darkAccent : AppTheme.lightSecondary)
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Patrón de fondo
              Positioned.fill(
                child: CustomPaint(
                  painter: _CirclePatternPainter(isDarkMode),
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.folder_special_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Investigaciones',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestiona tus casos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CirclePatternPainter extends CustomPainter {
  final bool isDarkMode;

  _CirclePatternPainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Círculos decorativos
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      40,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.2),
      30,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
