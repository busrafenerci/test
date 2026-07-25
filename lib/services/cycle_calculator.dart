import '../models/cycle_info.dart';
import '../models/period_record.dart';

enum CyclePhase {
  menstruation,
  renewal,
  fertile,
  pms,
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
      case CyclePhase.pms:
        return 'PMS dönemi';
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
      case CyclePhase.pms:
        return '🔮';
      case CyclePhase.rest:
        return '💤';
    }
  }
}

class CycleCalculator {
  CycleCalculator._();

  static const int _historyLimit = 6;

  /// Verilen tarihin döngünün kaçıncı günü olduğunu hesaplar
  static int getCycleDay({
    required DateTime date,
    required CycleInfo cycleInfo,
  }) {
    final targetDate = _dateOnly(date);
    final lastPeriodDate = _dateOnly(cycleInfo.lastPeriodDate);

    final differenceInDays = targetDate.difference(lastPeriodDate).inDays;
    final normalizedDifference = differenceInDays < 0 ? 0 : differenceInDays;

    return (normalizedDifference % cycleInfo.cycleLength) + 1;
  }

  /// Verilen tarihten ÖNCEKİ en yakın gerçek regl kaydını bulur (Takvim ve Ana Sayfa ortak mantığı)
  static PeriodRecord? findLastRecordBefore(DateTime date, List<PeriodRecord> records) {
    if (records.isEmpty) return null;

    final targetDate = _dateOnly(date);

    final sorted = [...records]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    PeriodRecord? candidate;
    for (final record in sorted) {
      final recStart = _dateOnly(record.startDate);
      if (recStart.isBefore(targetDate) || recStart.isAtSameMomentAs(targetDate)) {
        candidate = record;
      } else {
        break;
      }
    }

    return candidate;
  }

  /// Verilen tarihin doğurgan (verimli) döneme denk gelip gelmediğini kontrol eder
  /// Verilen tarihin doğurgan (verimli) döneme denk gelip gelmediğini kontrol eder
  static bool isFertileDay({
    required DateTime date,
    required CycleInfo cycleInfo,
  }) {
    final cycleDay = getCycleDay(date: date, cycleInfo: cycleInfo);
    final ovulationDay = cycleInfo.cycleLength - 14;
    final fertileStart = ovulationDay - 4;
    final fertileEnd = ovulationDay + 1;

    return cycleDay >= fertileStart && cycleDay <= fertileEnd;
  }

  /// Verilen tarihin tam yumurtlama (ovülasyon) gününe denk gelip gelmediğini kontrol eder
  static bool isOvulationDay({
    required DateTime date,
    required CycleInfo cycleInfo,
  }) {
    final cycleDay = getCycleDay(date: date, cycleInfo: cycleInfo);
    final ovulationDay = cycleInfo.cycleLength - 14;

    return cycleDay == ovulationDay;
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

  static CycleResult calculate(
    CycleInfo cycleInfo, {
    DateTime? currentDate,
  }) {
    final today = _dateOnly(
      currentDate ?? DateTime.now(),
    );

    final cycleDay = getCycleDay(date: today, cycleInfo: cycleInfo);

    final daysUntilNextPeriod = cycleInfo.cycleLength - cycleDay + 1;

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
    final pmsStartDay = cycleLength - 6;

    if (cycleDay <= periodLength) {
      return CyclePhase.menstruation;
    }

    if (cycleDay < fertileStart) {
      return CyclePhase.renewal;
    }

    if (cycleDay <= fertileEnd) {
      return CyclePhase.fertile;
    }

    if (cycleDay >= pmsStartDay) {
      return CyclePhase.pms;
    }

    return CyclePhase.rest;
  }

  static int calculatePredictedPeriodLength({
    required List<PeriodRecord> records,
    required int fallbackPeriodLength,
  }) {
    final completedRecords = _getCompletedRecords(records);

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
        (first, second) => first.startDate.compareTo(second.startDate),
      );

    if (sortedRecords.length < 2) {
      return fallbackCycleLength;
    }

    final cycleLengths = <int>[];

    for (var index = 1; index < sortedRecords.length; index++) {
      final previousRecord = sortedRecords[index - 1];
      final currentRecord = sortedRecords[index];

      final difference = _dateOnly(
        currentRecord.startDate,
      ).difference(
        _dateOnly(previousRecord.startDate),
      ).inDays;

      if (difference >= 15 && difference <= 60) {
        cycleLengths.add(difference);
      }
    }

    if (cycleLengths.isEmpty) {
      return fallbackCycleLength;
    }

    final recentCycleLengths = cycleLengths.length <= _historyLimit
        ? cycleLengths
        : cycleLengths.sublist(
            cycleLengths.length - _historyLimit,
          );

    return _calculateMedian(recentCycleLengths);
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
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final predictedCycleLength = calculatePredictedCycleLength(
      records: sortedRecords,
      fallbackCycleLength: fallbackCycleLength,
    );

    final predictedPeriodLength = calculatePredictedPeriodLength(
      records: sortedRecords,
      fallbackPeriodLength: fallbackPeriodLength,
    );

    final predictedRecords = <PeriodRecord>[];
    final normalizedRangeEnd = _dateOnly(rangeEnd);

    for (int i = 0; i < sortedRecords.length - 1; i++) {
      final currentRecord = sortedRecords[i];
      final nextRecord = sortedRecords[i + 1];

      var nextPredictedStart = _dateOnly(currentRecord.startDate).add(
        Duration(days: predictedCycleLength),
      );

      while (nextPredictedStart.isBefore(_dateOnly(nextRecord.startDate))) {
        final predictedEnd = nextPredictedStart.add(
          Duration(days: predictedPeriodLength - 1),
        );

        if (predictedEnd.isBefore(_dateOnly(nextRecord.startDate))) {
          predictedRecords.add(
            PeriodRecord(
              startDate: nextPredictedStart,
              periodLength: predictedPeriodLength,
            ),
          );
        }

        nextPredictedStart = nextPredictedStart.add(
          Duration(days: predictedCycleLength),
        );
      }
    }

    var futurePredictedStart = _dateOnly(sortedRecords.last.startDate).add(
      Duration(days: predictedCycleLength),
    );

    while (!futurePredictedStart.isAfter(normalizedRangeEnd)) {
      predictedRecords.add(
        PeriodRecord(
          startDate: futurePredictedStart,
          periodLength: predictedPeriodLength,
        ),
      );

      futurePredictedStart = futurePredictedStart.add(
        Duration(days: predictedCycleLength),
      );
    }

    return predictedRecords;
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
        (first, second) => first.startDate.compareTo(second.startDate),
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

    final firstMiddleValue = sortedValues[middleIndex - 1];
    final secondMiddleValue = sortedValues[middleIndex];

    return ((firstMiddleValue + secondMiddleValue) / 2).round();
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