import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para el idioma actual
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es', 'ES'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLanguage() {
    if (state.languageCode == 'es') {
      state = const Locale('en', 'US');
    } else {
      state = const Locale('es', 'ES');
    }
  }
}

// Idiomas soportados
final supportedLocales = [
  const Locale('es', 'ES'),
  const Locale('en', 'US'),
];

// Información de idiomas
class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

final supportedLanguages = {
  'es': const LanguageInfo(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
  ),
  'en': const LanguageInfo(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇬🇧',
  ),
};
