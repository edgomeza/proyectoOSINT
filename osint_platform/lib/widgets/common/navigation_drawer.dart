import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/investigations_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/investigation_phase.dart';

class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigations = ref.watch(investigationsProvider);
    final activeInvestigation = ref.watch(activeInvestigationProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FadeIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Plataforma OSINT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${investigations.length} investigacion${investigations.length != 1 ? "es" : ""}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Investigación Activa
            if (activeInvestigation != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FadeInLeft(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Investigación Activa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      activeInvestigation.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
            ],

            // Navegación Principal
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  FadeInLeft(
                    delay: const Duration(milliseconds: 100),
                    child: _buildDrawerItem(
                      context: context,
                      icon: Icons.home_outlined,
                      title: 'Inicio',
                      onTap: () {
                        context.go('/');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  if (activeInvestigation != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Fases de Investigación',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 150),
                      child: _buildDrawerItem(
                        context: context,
                        icon: Icons.lightbulb_outline,
                        title: 'Planificación',
                        subtitle: activeInvestigation.currentPhase == InvestigationPhase.planning
                            ? 'Fase actual'
                            : null,
                        isActive: activeInvestigation.currentPhase == InvestigationPhase.planning,
                        onTap: () {
                          context.go('/investigation/${activeInvestigation.id}/planning');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 200),
                      child: _buildDrawerItem(
                        context: context,
                        icon: Icons.collections_bookmark_outlined,
                        title: 'Recopilación',
                        subtitle: activeInvestigation.currentPhase == InvestigationPhase.collection
                            ? 'Fase actual'
                            : null,
                        isActive: activeInvestigation.currentPhase == InvestigationPhase.collection,
                        onTap: () {
                          context.go('/investigation/${activeInvestigation.id}/collection');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 250),
                      child: _buildDrawerItem(
                        context: context,
                        icon: Icons.settings_outlined,
                        title: 'Procesamiento',
                        subtitle: activeInvestigation.currentPhase == InvestigationPhase.processing
                            ? 'Fase actual'
                            : null,
                        isActive: activeInvestigation.currentPhase == InvestigationPhase.processing,
                        onTap: () {
                          context.go('/investigation/${activeInvestigation.id}/processing');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 300),
                      child: _buildDrawerItem(
                        context: context,
                        icon: Icons.analytics_outlined,
                        title: 'Análisis',
                        subtitle: activeInvestigation.currentPhase == InvestigationPhase.analysis
                            ? 'Fase actual'
                            : null,
                        isActive: activeInvestigation.currentPhase == InvestigationPhase.analysis,
                        onTap: () {
                          context.go('/investigation/${activeInvestigation.id}/analysis');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 350),
                      child: _buildDrawerItem(
                        context: context,
                        icon: Icons.description_outlined,
                        title: 'Informes',
                        subtitle: activeInvestigation.currentPhase == InvestigationPhase.reports
                            ? 'Fase actual'
                            : null,
                        isActive: activeInvestigation.currentPhase == InvestigationPhase.reports,
                        onTap: () {
                          context.go('/investigation/${activeInvestigation.id}/reports');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Footer con toggle de tema
            const Divider(),
            FadeInUp(
              child: ListTile(
                leading: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(isDark ? 'Modo claro' : 'Modo oscuro'),
                onTap: () {
                  ref.read(themeModeProvider.notifier).state =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 50),
              child: _buildLanguageSelector(context, ref),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isSpanish = currentLocale.languageCode == 'es';

    return ListTile(
      leading: Icon(
        Icons.language,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(isSpanish ? 'Idioma' : 'Language'),
      subtitle: Text(
        isSpanish ? 'Español' : 'English',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(
            value: 'es',
            label: Text('ES'),
          ),
          ButtonSegment<String>(
            value: 'en',
            label: Text('EN'),
          ),
        ],
        selected: {currentLocale.languageCode},
        onSelectionChanged: (Set<String> newSelection) {
          if (newSelection.first == 'es') {
            ref.read(localeProvider.notifier).setLocale(const Locale('es', 'ES'));
          } else {
            ref.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));
          }
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withValues(alpha:0.1)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
