import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para el modo de tema (dark/light)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark; // Por defecto modo oscuro
});

// Provider para toggle del tema
final themeToggleProvider = Provider<Function>((ref) {
  return () {
    final currentMode = ref.read(themeModeProvider);
    ref.read(themeModeProvider.notifier).state =
        currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  };
});
