import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/encryption_service.dart';
import 'screens/auth/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  final _encryptionService = EncryptionService();
  bool _isLoading = true;
  bool _isUnlocked = false;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // App está cerrando o en background, encriptar y bloquear
      _encryptionService.encryptDatabase();
      _encryptionService.lock();
      setState(() {
        _isUnlocked = false;
      });
    }
  }

  Future<void> _checkAuthStatus() async {
    final isFirstLaunch = await _encryptionService.isFirstLaunch();
    setState(() {
      _isFirstLaunch = isFirstLaunch;
      _isLoading = false;
    });
  }

  void _handleUnlocked() {
    setState(() {
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: themeMode == ThemeMode.dark
                  ? AppTheme.darkGradient
                  : AppTheme.lightGradient,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    if (!_isUnlocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: LockScreen(
          isFirstLaunch: _isFirstLaunch,
          onUnlocked: _handleUnlocked,
        ),
      );
    }

    return MaterialApp.router(
      title: 'Plataforma OSINT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      routerConfig: appRouter,
    );
  }
}
