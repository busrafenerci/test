import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final settingsJson = preferences.getString(_settingsKey);

    if (settingsJson == null || settingsJson.isEmpty) {
      return const AppSettings();
    }

    try {
      final decodedJson = jsonDecode(settingsJson);

      if (decodedJson is! Map) {
        return const AppSettings();
      }

      return AppSettings.fromJson(
        Map<String, dynamic>.from(decodedJson),
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());

    await preferences.setString(
      _settingsKey,
      settingsJson,
    );
  }

  Future<void> updateAverageCycleLength(
    int cycleLength,
  ) async {
    final currentSettings = await loadSettings();

    final updatedSettings = currentSettings.copyWith(
      averageCycleLength: cycleLength,
    );

    await saveSettings(updatedSettings);
  }

  Future<void> updatePredictedPeriodLength(
    int periodLength,
  ) async {
    final currentSettings = await loadSettings();

    final updatedSettings = currentSettings.copyWith(
      predictedPeriodLength: periodLength,
    );

    await saveSettings(updatedSettings);
  }

  Future<void> resetSettings() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_settingsKey);
  }
}