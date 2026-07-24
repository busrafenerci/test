import '../models/cycle_info.dart';
import '../models/period_record.dart';

enum CyclePhase {
  menstruation,
  renewal,
  fertile,
  rest,
}

class CycleResult {
  final int cycleDay;
  final int daysUntilNextPeriod;
  final DateTime nextPeriodDate;
  final CyclePhase phase;

  const CycleResult({
    required this.cycleDay,
    required this.daysUntilNextPeriod,
    required this.nextPeriodDate,
    required this.phase,
  });

  String get phaseName {
    switch (phase) {
      case CyclePhase.menstruation:
        return 'Regl';
      case CyclePhase.renewal:
        return 'Yenilenme';
      case CyclePhase.fertile:
        return 'Verimli dönem';
      case CyclePhase.rest:
        return 'Dinlenme';
    }
  }

  String get phaseIcon {
    switch (phase) {
      case CyclePhase.menstruation:
        return '🩸';
      case CyclePhase.renewal:
        return '🌱';
      case CyclePhase.fertile:
        return '🌸';
      case CyclePhase.rest:
        return '💤';
    }
  }
}

class CycleCalculator {
  CycleCalculator._();

  static const int _historyLimit = 3;

  // ---------------------------------------------------------------------------
  // Existing calculation used by HomeScreen
  // ---------------------------------------------------------------------------

  static CycleResult calculate(
    CycleInfo cycleInfo, {
    DateTime? currentDate,
  }) {
    final today = _dateOnly(
      currentDate ?? DateTime.now(),
    );

    final lastPeriodDate = _dateOnly(
      cycleInfo.lastPeriodDate,
    );

    final differenceInDays = today
        .difference(lastPeriodDate)
        .inDays;

    final normalizedDifference =
        differenceInDays < 0 ? 0 : differenceInDays;

    final cycleDay =
        (normalizedDifference % cycleInfo.cycleLength) + 1;

    final daysUntilNextPeriod =
        cycleInfo.cycleLength - cycleDay + 1;

    final nextPeriodDate = today.add(
      Duration(days: daysUntilNextPeriod),
    );

    final phase = _calculatePhase(
      cycleDay: cycleDay,
      periodLength: cycleInfo.periodLength,
      cycleLength: cycleInfo.cycleLength,
    );

    return CycleResult(
      cycleDay: cycleDay,
      daysUntilNextPeriod: daysUntilNextPeriod,
      nextPeriodDate: nextPeriodDate,
      phase: phase,
    );
  }

  static CyclePhase _calculatePhase({
    required int cycleDay,
    required int periodLength,
    required int cycleLength,
  }) {
    final ovulationDay = cycleLength - 14;
    final fertileStart = ovulationDay - 4;
    final fertileEnd = ovulationDay + 1;

    if (cycleDay <= periodLength) {
      return CyclePhase.menstruation;
    }

    if (cycleDay < fertileStart) {
      return CyclePhase.renewal;
    }

    if (cycleDay <= fertileEnd) {
      return CyclePhase.fertile;
    }

    return CyclePhase.rest;
  }

  // ---------------------------------------------------------------------------
  // New calculations based on actual period records
  // ---------------------------------------------------------------------------

  static int calculatePredictedPeriodLength({
    required List<PeriodRecord> records,
    required int fallbackPeriodLength,
  }) {
    final completedRecords = _getCompletedRecords(
      records,
    );

    if (completedRecords.isEmpty) {
      return fallbackPeriodLength;
    }

    final recentRecords = _takeRecentRecords(
      completedRecords,
      _historyLimit,
    );

    final periodLengths = recentRecords
        .map(
          (record) => record.periodLength,
        )
        .toList();

    return _calculateMedian(periodLengths);
  }

  static int calculatePredictedCycleLength({
    required List<PeriodRecord> records,
    required int fallbackCycleLength,
  }) {
    final sortedRecords = [...records]
      ..sort(
        (first, second) =>
            first.startDate.compareTo(second.startDate),
      );

    if (sortedRecords.length < 2) {
      return fallbackCycleLength;
    }

    final cycleLengths = <int>[];

    for (
      var index = 1;
      index < sortedRecords.length;
      index++
    ) {
      final previousRecord = sortedRecords[index - 1];
      final currentRecord = sortedRecords[index];

      final difference = _dateOnly(
        currentRecord.startDate,
      ).difference(
        _dateOnly(previousRecord.startDate),
      ).inDays;

      // Ignore clearly invalid cycle intervals.
      if (difference >= 15 && difference <= 60) {
        cycleLengths.add(difference);
      }
    }

    if (cycleLengths.isEmpty) {
      return fallbackCycleLength;
    }

    final recentCycleLengths =
        cycleLengths.length <= _historyLimit
            ? cycleLengths
            : cycleLengths.sublist(
                cycleLengths.length - _historyLimit,
              );

    return _calculateMedian(
      recentCycleLengths,
    );
  }

  static DateTime? calculateNextPeriodStart({
    required List<PeriodRecord> records,
    required int fallbackCycleLength,
  }) {
    if (records.isEmpty) {
      return null;
    }

    final sortedRecords = [...records]
      ..sort(
        (first, second) =>
            first.startDate.compareTo(second.startDate),
      );

    final latestRecord = sortedRecords.last;

    final predictedCycleLength =
        calculatePredictedCycleLength(
      records: sortedRecords,
      fallbackCycleLength: fallbackCycleLength,
    );

    return _dateOnly(
      latestRecord.startDate,
    ).add(
      Duration(days: predictedCycleLength),
    );
  }

  static PeriodRecord? calculateNextPredictedRecord({
    required List<PeriodRecord> records,
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  }) {
    final predictedStartDate =
        calculateNextPeriodStart(
      records: records,
      fallbackCycleLength: fallbackCycleLength,
    );

    if (predictedStartDate == null) {
      return null;
    }

    final predictedPeriodLength =
        calculatePredictedPeriodLength(
      records: records,
      fallbackPeriodLength: fallbackPeriodLength,
    );

    return PeriodRecord(
      startDate: predictedStartDate,
      periodLength: predictedPeriodLength,
    );
  }

  static List<PeriodRecord> generatePredictedRecords({
    required List<PeriodRecord> records,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required int fallbackCycleLength,
    required int fallbackPeriodLength,
  }) {
    if (records.isEmpty) {
      return [];
    }

    final sortedRecords = [...records]
      ..sort(
        (first, second) =>
            first.startDate.compareTo(second.startDate),
      );

    final predictedCycleLength =
        calculatePredictedCycleLength(
      records: sortedRecords,
      fallbackCycleLength: fallbackCycleLength,
    );

    final predictedPeriodLength =
        calculatePredictedPeriodLength(
      records: sortedRecords,
      fallbackPeriodLength: fallbackPeriodLength,
    );

    var predictedStartDate = _dateOnly(
      sortedRecords.last.startDate,
    ).add(
      Duration(days: predictedCycleLength),
    );

    final normalizedRangeStart = _dateOnly(
      rangeStart,
    );

    final normalizedRangeEnd = _dateOnly(
      rangeEnd,
    );

    while (predictedStartDate
        .add(
          Duration(
            days: predictedPeriodLength - 1,
          ),
        )
        .isBefore(normalizedRangeStart)) {
      predictedStartDate = predictedStartDate.add(
        Duration(days: predictedCycleLength),
      );
    }

    final predictedRecords = <PeriodRecord>[];

    while (!predictedStartDate.isAfter(
      normalizedRangeEnd,
    )) {
      predictedRecords.add(
        PeriodRecord(
          startDate: predictedStartDate,
          periodLength: predictedPeriodLength,
        ),
      );

      predictedStartDate = predictedStartDate.add(
        Duration(days: predictedCycleLength),
      );
    }

    return predictedRecords;
  }

  static bool isActualPeriodDay({
    required DateTime date,
    required List<PeriodRecord> records,
  }) {
    return records.any(
      (record) => record.containsDate(date),
    );
  }

  static PeriodRecord? findActualRecordForDate({
    required DateTime date,
    required List<PeriodRecord> records,
  }) {
    for (final record in records) {
      if (record.containsDate(date)) {
        return record;
      }
    }

    return null;
  }

  static bool isPredictedPeriodDay({
    required DateTime date,
    required List<PeriodRecord> predictedRecords,
  }) {
    return predictedRecords.any(
      (record) => record.containsDate(date),
    );
  }

  static List<PeriodRecord> _getCompletedRecords(
    List<PeriodRecord> records,
  ) {
    final today = _dateOnly(DateTime.now());

    final completedRecords = records.where(
      (record) {
        return record.endDate != null && !record.endDate!.isAfter(today);
      },
    ).toList()
      ..sort(
        (first, second) =>
            first.startDate.compareTo(second.startDate),
      );

    return completedRecords;
  }

  static List<PeriodRecord> _takeRecentRecords(
    List<PeriodRecord> records,
    int count,
  ) {
    if (records.length <= count) {
      return records;
    }

    return records.sublist(
      records.length - count,
    );
  }

  static int _calculateMedian(
    List<int> values,
  ) {
    if (values.isEmpty) {
      throw ArgumentError(
        'Median hesaplamak için en az bir değer gerekir.',
      );
    }

    final sortedValues = [...values]..sort();
    final middleIndex = sortedValues.length ~/ 2;

    if (sortedValues.length.isOdd) {
      return sortedValues[middleIndex];
    }

    final firstMiddleValue =
        sortedValues[middleIndex - 1];

    final secondMiddleValue =
        sortedValues[middleIndex];

    return (
      (firstMiddleValue + secondMiddleValue) / 2
    ).round();
  }

  static DateTime _dateOnly(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }
}