import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cycle_info.dart';
import '../models/period_record.dart';

import 'cycle_calculator.dart'; // 

class StorageService {
  static const _setupCompletedKey = 'setup_completed';
  static const _lastPeriodDateKey = 'last_period_date';
  static const _periodLengthKey = 'period_length';
  static const _cycleLengthKey = 'cycle_length';

  static const _periodRecordsKey = 'period_records';
  static const _periodRecordsMigratedKey =
      'period_records_migrated';

  /// Setup tamamlandı mı?
  static Future<bool> isSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_setupCompletedKey) ?? false;
  }

  /// Setup tamamlandı olarak işaretle
  static Future<void> setSetupCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _setupCompletedKey,
      value,
    );
  }

  /// Son regl başlangıç tarihini kaydet
  static Future<void> saveLastPeriodDate(
    DateTime date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedDate = _normalizeDate(date);

    await prefs.setString(
      _lastPeriodDateKey,
      normalizedDate.toIso8601String(),
    );
  }

  /// Son regl başlangıç tarihini getir
  static Future<DateTime?> getLastPeriodDate() async {
    await _migrateOldCycleInfoIfNeeded();

    final records = await getPeriodRecords();

    if (records.isNotEmpty) {
      return records.last.startDate;
    }

    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastPeriodDateKey);

    if (value == null) {
      return null;
    }

    return _normalizeDate(
      DateTime.parse(value),
    );
  }

  /// Varsayılan regl süresini kaydet
  static Future<void> savePeriodLength(int value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _periodLengthKey,
      value,
    );
  }

  /// Varsayılan regl süresini getir
  static Future<int> getPeriodLength() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_periodLengthKey) ?? 5;
  }

  /// Döngü süresini kaydet
  static Future<void> saveCycleLength(int value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _cycleLengthKey,
      value,
    );
  }

  /// Döngü süresini getir
  static Future<int> getCycleLength() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_cycleLengthKey) ?? 28;
  }

  /// Tüm döngü bilgilerini eski model yapısında getir
  ///
  /// Mevcut ekranların çalışmaya devam etmesi için şimdilik korunuyor.
  /// Tüm döngü bilgilerini hesaplayıp dinamik model yapısında getirir.
  static Future<CycleInfo?> getCycleInfo() async {
    final lastPeriodDate = await getLastPeriodDate();

    if (lastPeriodDate == null) {
      return null;
    }

    final periodRecords = await getPeriodRecords();
    final fallbackPeriodLength = await getPeriodLength();
    final fallbackCycleLength = await getCycleLength();

    // Gerçek kayıtlar varsa CycleCalculator üzerinden dinamik ortalamaları alıyoruz.
    final calculatedPeriodLength = CycleCalculator.calculatePredictedPeriodLength(
      records: periodRecords,
      fallbackPeriodLength: fallbackPeriodLength,
    );

    final calculatedCycleLength = CycleCalculator.calculatePredictedCycleLength(
      records: periodRecords,
      fallbackCycleLength: fallbackCycleLength,
    );

    return CycleInfo(
      lastPeriodDate: lastPeriodDate,
      periodLength: calculatedPeriodLength,
      cycleLength: calculatedCycleLength,
    );
  }

  /// Kayıtlı döngü bilgisi var mı?
  static Future<bool> hasCycleInfo() async {
    final records = await getPeriodRecords();

    if (records.isNotEmpty) {
      return true;
    }

    return (await getLastPeriodDate()) != null;
  }

  /// Kaydedilmiş tüm gerçek regl kayıtlarını getir
  static Future<List<PeriodRecord>> getPeriodRecords() async {
    await _migrateOldCycleInfoIfNeeded();

    final prefs = await SharedPreferences.getInstance();
    final storedRecords = prefs.getStringList(
      _periodRecordsKey,
    );

    if (storedRecords == null || storedRecords.isEmpty) {
      return [];
    }

    final records = <PeriodRecord>[];

    for (final storedRecord in storedRecords) {
      try {
        final decodedRecord = jsonDecode(storedRecord);

        if (decodedRecord is! Map<String, dynamic>) {
          continue;
        }

        records.add(
          PeriodRecord.fromJson(decodedRecord),
        );
      } catch (_) {
        // Invalid records are ignored so one damaged entry
        // does not prevent all other records from loading.
      }
    }

    records.sort(
      (first, second) =>
          first.startDate.compareTo(second.startDate),
    );

    return records;
  }

  /// Tüm gerçek regl kayıtlarını kaydet
  static Future<void> savePeriodRecords(
  List<PeriodRecord> records,
) async {
  final prefs = await SharedPreferences.getInstance();

  final normalizedRecords = records
      .map(
        (record) => PeriodRecord(
          startDate: _normalizeDate(record.startDate),
          endDate: record.endDate == null
              ? null
              : _normalizeDate(record.endDate!),
          predictedLength: record.predictedLength,
        ),
      )
      .toList()
    ..sort(
      (first, second) =>
          first.startDate.compareTo(second.startDate),
    );

  final encodedRecords = normalizedRecords
      .map(
        (record) => jsonEncode(record.toJson()),
      )
      .toList();

  await prefs.setStringList(
    _periodRecordsKey,
    encodedRecords,
  );

  if (normalizedRecords.isNotEmpty) {
    final latestRecord = normalizedRecords.last;

    await prefs.setString(
      _lastPeriodDateKey,
      latestRecord.startDate.toIso8601String(),
    );
  } else {
    await prefs.remove(_lastPeriodDateKey);
  }
}

  /// Yeni bir gerçek regl kaydı ekle
  static Future<void> addPeriodRecord(
    PeriodRecord record,
  ) async {
    final records = await getPeriodRecords();
    final normalizedStartDate = _normalizeDate(
      record.startDate,
    );

    final existingRecordIndex = records.indexWhere(
      (existingRecord) => _isSameDay(
        existingRecord.startDate,
        normalizedStartDate,
      ),
    );

    final normalizedRecord = PeriodRecord(
      startDate: normalizedStartDate,
      endDate: record.endDate == null
      ? null
      : _normalizeDate(record.endDate!),
  predictedLength: record.predictedLength,
    );


    if (existingRecordIndex >= 0) {
      records[existingRecordIndex] = normalizedRecord;
    } else {
      records.add(normalizedRecord);
    }

    await savePeriodRecords(records);
  }

  /// Mevcut bir gerçek regl kaydını güncelle
  static Future<bool> updatePeriodRecord({
    required DateTime oldStartDate,
    required PeriodRecord updatedRecord,
  }) async {
    final records = await getPeriodRecords();
    final normalizedOldStartDate = _normalizeDate(
      oldStartDate,
    );

    final recordIndex = records.indexWhere(
      (record) => _isSameDay(
        record.startDate,
        normalizedOldStartDate,
      ),
    );

    if (recordIndex == -1) {
      return false;
    }

    records[recordIndex] = PeriodRecord(
      startDate: _normalizeDate(
        updatedRecord.startDate,
      ),
      endDate: updatedRecord.endDate == null
          ? null
          : _normalizeDate(updatedRecord.endDate!),
      predictedLength: updatedRecord.predictedLength,
    );

    await savePeriodRecords(records);

    return true;
  }

  /// Başlangıç tarihine göre gerçek regl kaydını kaldır
  static Future<bool> removePeriodRecord(
    DateTime startDate,
  ) async {
    final records = await getPeriodRecords();
    final normalizedStartDate = _normalizeDate(
      startDate,
    );

    final initialRecordCount = records.length;

    records.removeWhere(
      (record) => _isSameDay(
        record.startDate,
        normalizedStartDate,
      ),
    );

    if (records.length == initialRecordCount) {
      return false;
    }

    await savePeriodRecords(records);

    return true;
  }

  /// Removes the currently ongoing period record.
static Future<PeriodRecord> removeOngoingPeriod() async {
  final records = await getPeriodRecords();

  final ongoingIndex = records.indexWhere(
    (record) => record.isOngoing,
  );

  if (ongoingIndex == -1) {
    throw StateError(
      'No ongoing period found.',
    );
  }

  final removedRecord = records.removeAt(ongoingIndex);

  await savePeriodRecords(records);

  return removedRecord;
}

/// Starts a new period on the selected date.
///
/// Only one ongoing period can exist at a time.

  static Future<PeriodRecord> startPeriod(
  DateTime startDate, {
  int predictedLength = 4,
}) async {
  final records = await getPeriodRecords();
  final normalizedStartDate = _normalizeDate(startDate);

  final hasOngoingRecord = records.any(
    (record) => record.isOngoing,
  );

  if (hasOngoingRecord) {
    throw StateError(
      'An ongoing period already exists.',
    );
  }

  final hasRecordOnSelectedDate = records.any(
    (record) => _isSameDay(
      record.startDate,
      normalizedStartDate,
    ),
  );

  if (hasRecordOnSelectedDate) {
    throw StateError(
      'A period record already exists for this date.',
    );
  }

  final newRecord = PeriodRecord(
    startDate: normalizedStartDate,
    predictedLength: predictedLength,
  );

  records.add(newRecord);

  await savePeriodRecords(records);

  return newRecord;
}

  static Future<PeriodRecord> finishOngoingPeriod(
  DateTime endDate,
) async {
  final records = await getPeriodRecords();
  final normalizedEndDate = _normalizeDate(endDate);

  final ongoingIndex = records.indexWhere(
    (record) => record.isOngoing,
  );

  if (ongoingIndex == -1) {
    throw StateError(
      'No ongoing period found.',
    );
  }

  final ongoingRecord = records[ongoingIndex];

  final periodDuration = normalizedEndDate
          .difference(
            _normalizeDate(ongoingRecord.startDate),
          )
          .inDays +
      1;

  if (periodDuration > 15) {
    throw StateError(
      'ONGOING_PERIOD_TOO_LONG',
    );
  }

  final finishedRecord = ongoingRecord.finish(
    normalizedEndDate,
  );

  records[ongoingIndex] = finishedRecord;

  await savePeriodRecords(records);

  return finishedRecord;
}

  /// Verilen tarih gerçek regl başlangıcı mı?
  static Future<bool> isPeriodStartDate(
    DateTime date,
  ) async {
    final records = await getPeriodRecords();

    return records.any(
      (record) => _isSameDay(
        record.startDate,
        date,
      ),
    );
  }

  /// Eski tek tarihli kaydı yeni liste yapısına aktar
  static Future<void> _migrateOldCycleInfoIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();

    final hasAlreadyMigrated =
        prefs.getBool(_periodRecordsMigratedKey) ?? false;

    if (hasAlreadyMigrated) {
      return;
    }

    final existingRecords = prefs.getStringList(
      _periodRecordsKey,
    );

    if (existingRecords != null && existingRecords.isNotEmpty) {
      await prefs.setBool(
        _periodRecordsMigratedKey,
        true,
      );

      return;
    }

    final oldDateValue = prefs.getString(
      _lastPeriodDateKey,
    );

    if (oldDateValue != null) {
      try {
        final oldStartDate = _normalizeDate(
          DateTime.parse(oldDateValue),
        );

        final oldPeriodLength =
            prefs.getInt(_periodLengthKey) ?? 5;

        final migratedRecord = PeriodRecord(
          startDate: oldStartDate,
          periodLength: oldPeriodLength,
        );

        await prefs.setStringList(
          _periodRecordsKey,
          [
            jsonEncode(
              migratedRecord.toJson(),
            ),
          ],
        );
      } catch (_) {
        // The old value is ignored if it cannot be parsed.
      }
    }

    await prefs.setBool(
      _periodRecordsMigratedKey,
      true,
    );
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  static bool _isSameDay(
    DateTime firstDate,
    DateTime secondDate,
  ) {
    return firstDate.year == secondDate.year &&
        firstDate.month == secondDate.month &&
        firstDate.day == secondDate.day;
  }
}