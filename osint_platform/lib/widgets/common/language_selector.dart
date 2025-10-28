import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentLanguage = supportedLanguages[currentLocale.languageCode];

    return Pulse(
      duration: const Duration(milliseconds: 300),
      child: PopupMenuButton<String>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguage?.flag ?? '🌐',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        tooltip: 'Cambiar idioma / Change language',
        onSelected: (String languageCode) {
          final locale = supportedLocales.firstWhere(
            (l) => l.languageCode == languageCode,
          );
          ref.read(localeProvider.notifier).setLocale(locale);
        },
        itemBuilder: (BuildContext context) {
          return supportedLanguages.entries.map((entry) {
            final languageCode = entry.key;
            final languageInfo = entry.value;
            final isSelected = currentLocale.languageCode == languageCode;

            return PopupMenuItem<String>(
              value: languageCode,
              child: Row(
                children: [
                  Text(
                    languageInfo.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      languageInfo.nativeName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
