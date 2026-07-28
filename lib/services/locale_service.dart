import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  LocaleService._();

  static const String _localePreferenceKey = 'app_locale';

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale('tr'));

  static Locale get currentLocale => localeNotifier.value;

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguageCode = preferences.getString(_localePreferenceKey);

    if (_isSupported(savedLanguageCode)) {
      localeNotifier.value = Locale(savedLanguageCode!);
      return;
    }

    final deviceLanguageCode =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();

    localeNotifier.value = _isSupported(deviceLanguageCode)
        ? Locale(deviceLanguageCode)
        : const Locale('tr');
  }

  static Future<void> setLocale(String languageCode) async {
    if (!_isSupported(languageCode)) {
      return;
    }

    final normalizedLanguageCode = languageCode.toLowerCase();
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _localePreferenceKey,
      normalizedLanguageCode,
    );

    localeNotifier.value = Locale(normalizedLanguageCode);
  }

  static bool _isSupported(String? languageCode) {
    return languageCode == 'tr' || languageCode == 'en';
  }
}
