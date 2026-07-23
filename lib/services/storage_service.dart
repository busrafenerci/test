import 'package:shared_preferences/shared_preferences.dart';

import '../models/cycle_info.dart';

class StorageService {
  static const _setupCompletedKey = 'setup_completed';
  static const _lastPeriodDateKey = 'last_period_date';
  static const _periodLengthKey = 'period_length';
  static const _cycleLengthKey = 'cycle_length';

  /// Setup tamamlandı mı?
  static Future<bool> isSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_setupCompletedKey) ?? false;
  }

  /// Setup tamamlandı olarak işaretle
  static Future<void> setSetupCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_setupCompletedKey, value);
  }

  /// Son regl tarihini kaydet
  static Future<void> saveLastPeriodDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _lastPeriodDateKey,
      date.toIso8601String(),
    );
  }

  /// Son regl tarihini getir
  static Future<DateTime?> getLastPeriodDate() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastPeriodDateKey);

    if (value == null) {
      return null;
    }

    return DateTime.parse(value);
  }

  /// Regl süresini kaydet
  static Future<void> savePeriodLength(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_periodLengthKey, value);
  }

  /// Regl süresini getir
  static Future<int> getPeriodLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_periodLengthKey) ?? 5;
  }

  /// Döngü süresini kaydet
  static Future<void> saveCycleLength(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cycleLengthKey, value);
  }

  /// Döngü süresini getir
  static Future<int> getCycleLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cycleLengthKey) ?? 28;
  }

  /// Tüm döngü bilgilerini tek model olarak getir
  static Future<CycleInfo?> getCycleInfo() async {
    final lastPeriodDate = await getLastPeriodDate();

    if (lastPeriodDate == null) {
      return null;
    }

    return CycleInfo(
      lastPeriodDate: lastPeriodDate,
      periodLength: await getPeriodLength(),
      cycleLength: await getCycleLength(),
    );
  }

  /// Kayıtlı döngü bilgisi var mı?
  static Future<bool> hasCycleInfo() async {
    return (await getLastPeriodDate()) != null;
  }
}