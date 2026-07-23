import '../models/cycle_info.dart';

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
  static CycleResult calculate(
    CycleInfo cycleInfo, {
    DateTime? currentDate,
  }) {
    final today = _dateOnly(currentDate ?? DateTime.now());
    final lastPeriodDate = _dateOnly(cycleInfo.lastPeriodDate);

    final differenceInDays = today.difference(lastPeriodDate).inDays;

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

  static DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }
}