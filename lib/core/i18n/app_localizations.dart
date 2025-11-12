import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._map);

  final Locale locale;
  final Map<String, dynamic> _map;

  static Future<AppLocalizations> load(Locale locale) async {
    final data = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    final map = jsonDecode(data) as Map<String, dynamic>;
    return AppLocalizations(locale, map);
  }

  String translate(String key) {
    final value = _map[key];
    if (value is String) {
      return value;
    }
    return key;
  }

  List<String> list(String key) {
    final value = _map[key];
    if (value is List) {
      return value.cast<String>();
    }
    return const [];
  }

  List<Map<String, String>> listOfMaps(String key) {
    final dynamic value = _map[key];
    if (value is! List) {
      return const [];
    }

    final List<Map<String, String>> resolved = <Map<String, String>>[];
    for (final dynamic entry in value) {
      if (entry is! Map) {
        continue;
      }
      final Map<String, String> mapped = entry.map(
        (dynamic key, dynamic value) => MapEntry<String, String>(
          key.toString(),
          value?.toString() ?? '',
        ),
      );
      resolved.add(mapped);
    }
    return List<Map<String, String>>.unmodifiable(resolved);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension LocalizationBuildContext on BuildContext {
  AppLocalizations get l10n => Localizations.of<AppLocalizations>(this, AppLocalizations)!;
}
