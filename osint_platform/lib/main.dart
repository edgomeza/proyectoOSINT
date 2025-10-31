import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/elk_stack_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/encryption_service.dart';
import 'screens/auth/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar sqflite_ffi para plataformas de escritorio
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
    _stopELKServices();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // App está cerrando o en background, encriptar y bloquear
      _encryptionService.encryptDatabase();
      _encryptionService.lock();
      _stopELKServices();
      setState(() {
        _isUnlocked = false;
      });
    }
  }

  String _getProjectPath() {
    // Obtener la ruta del proyecto Docker (directorio padre de osint_platform)
    final currentPath = Directory.current.path;

    // Si estamos en osint_platform, ir al directorio padre
    if (currentPath.endsWith('osint_platform')) {
      return Directory(currentPath).parent.path;
    }

    // Si no, asumir que ya estamos en el directorio del proyecto
    return currentPath;
  }

  void _initializeELKServices() {
    try {
      final projectPath = _getProjectPath();
      // Obtener credenciales del usuario autenticado
      final username = _encryptionService.currentUsername;
      final password = _encryptionService.currentPassword;

      // Pasar credenciales a Elasticsearch si están disponibles
      ref.read(elkStackProvider.notifier).initialize(
        projectPath,
        username: username,
        password: password,
      );
    } catch (e) {
      debugPrint('Error initializing ELK services: $e');
    }
  }

  void _stopELKServices() {
    try {
      ref.read(elkStackProvider.notifier).stopServices();
    } catch (e) {
      debugPrint('Error stopping ELK services: $e');
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

    // Inicializar servicios ELK después de desbloquear
    _initializeELKServices();
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
