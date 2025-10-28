import 'package:flutter/material.dart';
import 'translations_es.dart';
import 'translations_en.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    _localizedStrings = _getTranslations(locale.languageCode);
    return true;
  }

  Map<String, String> _getTranslations(String languageCode) {
    switch (languageCode) {
      case 'es':
        return translationsEs;
      case 'en':
        return translationsEn;
      default:
        return translationsEs;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
