import 'package:flutter/material.dart';

// Calendar behavior revision: 2026-07-28-v7-editable-start-window

import '../models/cycle_info.dart';
import '../models/period_record.dart';
import '../services/cycle_calculator.dart';
import '../services/storage_service.dart';
import 'package:within/l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  final int refreshVersion;

  const CalendarScreen({
    super.key,
    this.refreshVersion = 0,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  PeriodRecord? _findLastRecordBefore(DateTime date) {
    if (_actualRecords.isEmpty) return null;

    final targetDate = DateTime(date.year, date.month, date.day);

    final sorted = [..._actualRecords]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    PeriodRecord? candidate;
    for (final record in sorted) {
      final recStart = DateTime(
        record.startDate.year,
        record.startDate.month,
        record.startDate.day,
      );
      if (recStart.isBefore(targetDate) || recStart.isAtSameMomentAs(targetDate)) {
        candidate = record;
      } else {
        break;
      }
    }

    return candidate;
  }

  /// Returns cycle information for a calendar date.
  ///
  /// For dates before the first saved period, Within creates one estimated
  /// previous cycle so PMS, fertile and ovulation days can still be shown.
  CycleInfo? _getCycleInfoForDate(DateTime date) {
    final relevantRecord = _findLastRecordBefore(date);

    if (relevantRecord != null) {
      return CycleInfo(
        lastPeriodDate: relevantRecord.startDate,
        periodLength: relevantRecord.periodLength,
        cycleLength: _fallbackCycleLength,
      );
    }

    if (_actualRecords.isEmpty) {
      return null;
    }

    final sortedRecords = [..._actualRecords]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final firstStartDate = _dateOnly(sortedRecords.first.startDate);
    final targetDate = _dateOnly(date);

    if (!targetDate.isBefore(firstStartDate)) {
      return null;
    }

    final estimatedPreviousStartDate = firstStartDate.subtract(
      Duration(days: _fallbackCycleLength),
    );

    // Only estimate the single cycle immediately before the first real record.
    if (targetDate.isBefore(estimatedPreviousStartDate)) {
      return null;
    }

    return CycleInfo(
      lastPeriodDate: estimatedPreviousStartDate,
      periodLength: _fallbackPeriodLength,
      cycleLength: _fallbackCycleLength,
    );
  }

  List<PeriodRecord> _actualRecords = [];
  List<PeriodRecord> _predictedRecords = [];

  static const int _maximumPeriodLength = 10;

  int get _defaultUnfinishedPeriodLength {
    final predictedLength = CycleCalculator.calculatePredictedPeriodLength(
      records: _actualRecords,
      fallbackPeriodLength: _fallbackPeriodLength,
    );

    return predictedLength.clamp(1, _maximumPeriodLength).toInt();
  }

  /// Finds a period whose saved start date is one or two days after [date].
  ///
  /// This allows the user to correct a recently entered period start without
  /// creating a separate historical period record.
  PeriodRecord? _findPeriodStartCorrectionCandidate(DateTime date) {
    final targetDate = _dateOnly(date);
    final sortedRecords = [..._actualRecords]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    for (final record in sortedRecords) {
      final startDate = _dateOnly(record.startDate);
      final daysBeforeStart = startDate.difference(targetDate).inDays;

      if (daysBeforeStart == 1 || daysBeforeStart == 2) {
        return record;
      }

      if (startDate.isAfter(targetDate.add(const Duration(days: 2)))) {
        break;
      }
    }

    return null;
  }

  /// Finds the nearest period that may use [date] as its real end date.
  ///
  /// The user can correct an automatically estimated end date by selecting
  /// any day from the period start through the tenth day. A later period
  /// always takes priority, so records are never extended across another
  /// period start.
  PeriodRecord? _findPeriodEndCandidate(DateTime date) {
    final targetDate = _dateOnly(date);
    final sortedRecords = [..._actualRecords]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    for (final record in sortedRecords) {
      final startDate = _dateOnly(record.startDate);
      final dayNumber = targetDate.difference(startDate).inDays + 1;

      if (dayNumber < 1 || dayNumber > _maximumPeriodLength) {
        continue;
      }

      final hasLaterRecordBeforeOrOnTarget = _actualRecords.any((other) {
        if (identical(other, record)) {
          return false;
        }

        final otherStartDate = _dateOnly(other.startDate);
        return otherStartDate.isAfter(startDate) &&
            !otherStartDate.isAfter(targetDate);
      });

      if (!hasLaterRecordBeforeOrOnTarget) {
        return record;
      }
    }

    return null;
  }

  int _fallbackPeriodLength = 4;
  int _fallbackCycleLength = 28;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<String> get _monthNames => [
        _l10n.calendarMonthJanuary,
        _l10n.calendarMonthFebruary,
        _l10n.calendarMonthMarch,
        _l10n.calendarMonthApril,
        _l10n.calendarMonthMay,
        _l10n.calendarMonthJune,
        _l10n.calendarMonthJuly,
        _l10n.calendarMonthAugust,
        _l10n.calendarMonthSeptember,
        _l10n.calendarMonthOctober,
        _l10n.calendarMonthNovember,
        _l10n.calendarMonthDecember,
      ];

  List<String> get _weekDays => [
        _l10n.calendarWeekdayMonday,
        _l10n.calendarWeekdayTuesday,
        _l10n.calendarWeekdayWednesday,
        _l10n.calendarWeekdayThursday,
        _l10n.calendarWeekdayFriday,
        _l10n.calendarWeekdaySaturday,
        _l10n.calendarWeekdaySunday,
      ];

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadCalendarData(showLoading: false);
    }
  }

  Future<void> _loadCalendarData({
    bool showLoading = true,
  }) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final records = await StorageService.getPeriodRecords();
      final periodLength = await StorageService.getPeriodLength();
      final cycleLength = await StorageService.getCycleLength();

      final predictions = _generatePredictions(
        records: records,
        periodLength: periodLength,
        cycleLength: cycleLength,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _actualRecords = records;
        _predictedRecords = predictions;
        _fallbackPeriodLength = periodLength;
        _fallbackCycleLength = cycleLength;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _l10n.calendarLoadError;
      });
    }
  }

  List<PeriodRecord> _generatePredictions({
    required List<PeriodRecord> records,
    required int periodLength,
    required int cycleLength,
  }) {
    final rangeStart = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    ).subtract(
      const Duration(days: 10),
    );

    final rangeEnd = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 2,
      0,
    );

    return CycleCalculator.generatePredictedRecords(
      records: records,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      fallbackCycleLength: cycleLength,
      fallbackPeriodLength: periodLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7657A8),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF77707E),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadCalendarData,
                child: Text(_l10n.calendarRetry),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.calendarTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2733),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _l10n.calendarSubtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF77707E),
            ),
          ),
          const SizedBox(height: 20),
          _buildCalendarCard(),
          const SizedBox(height: 12),
          _buildSelectedDayCard(),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 14),
          _buildWeekDayHeader(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMonthButton(
          icon: Icons.chevron_left_rounded,
          onPressed: _showPreviousMonth,
        ),
        Text(
          _formatMonthYear(_visibleMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2733),
          ),
        ),
        _buildMonthButton(
          icon: Icons.chevron_right_rounded,
          onPressed: _showNextMonth,
        ),
      ],
    );
  }

  Widget _buildMonthButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xFFF3EFF8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: const Color(0xFF7657A8),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDayHeader() {
    return Row(
      children: _weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9A939F),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );

    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final leadingEmptyCells = firstDayOfMonth.weekday - 1;
    // Always reserve 6 calendar rows (42 cells).
    // This keeps the calendar card height fixed while changing months.
    const itemCount = 42;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 4,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leadingEmptyCells + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(
          _visibleMonth.year,
          _visibleMonth.month,
          dayNumber,
        );

        return _buildDayCell(date);
      },
    );
  }

  Widget _buildDayCell(DateTime date) {
    final today = DateTime.now();

    final isToday = _isSameDay(date, today);
    final isSelected = _isSameDay(date, _selectedDate);

    final actualRecord = CycleCalculator.findActualRecordForDate(
      date: date,
      records: _actualRecords,
    );

    final isActualPeriodDay = actualRecord != null;

    final isPredictedPeriodDay = !isActualPeriodDay &&
        CycleCalculator.isPredictedPeriodDay(
          date: date,
          predictedRecords: _predictedRecords,
        );

    final Color? bgTileColor = isActualPeriodDay
        ? const Color(0xFFD9577D)
        : isPredictedPeriodDay
            ? const Color(0xFFFCE4EC)
            : null;

    final Color textColor = isActualPeriodDay
        ? Colors.white
        : isPredictedPeriodDay
            ? const Color(0xFFC74469)
            : const Color(0xFF2D2733);

    bool isFertileDay = false;
    bool isOvulationDay = false;
    bool isPmsDay = false;

    if (!isActualPeriodDay && !isPredictedPeriodDay) {
      final cycleInfo = _getCycleInfoForDate(date);

      if (cycleInfo != null) {
        isFertileDay = CycleCalculator.isFertileDay(
          date: date,
          cycleInfo: cycleInfo,
        );

        isOvulationDay = CycleCalculator.isOvulationDay(
          date: date,
          cycleInfo: cycleInfo,
        );

        final cycleResult = CycleCalculator.calculate(
          cycleInfo,
          currentDate: date,
        );

        isPmsDay = cycleResult.phase == CyclePhase.pms;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: bgTileColor,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF7657A8),
                    width: 2,
                  )
                : isToday
                    ? Border.all(
                        color: const Color(0xFFB8A4D6),
                        width: 1.5,
                      )
                    : isPredictedPeriodDay
                        ? Border.all(
                            color: const Color(0xFFE4A2B5),
                            width: 1,
                          )
                        : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, -1.0),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected || isToday || isActualPeriodDay || isOvulationDay
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isOvulationDay ? const Color(0xFFD48800) : textColor,
                    height: 1.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                child: isOvulationDay
                    ? const Text(
                        '👑',
                        style: TextStyle(fontSize: 7, height: 1),
                      )
                    : (isFertileDay || isPmsDay)
                        ? Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: isPmsDay
                                  ? const Color(0xFF8E24AA)
                                  : const Color(0xFFE6B800),
                              shape: BoxShape.circle,
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayCard() {
    final today = _dateOnly(DateTime.now());
    final selectedDate = _dateOnly(_selectedDate);
    final isFutureDate = selectedDate.isAfter(today);

    final ongoingRecord = _actualRecords
        .where((record) => record.isOngoing)
        .cast<PeriodRecord?>()
        .firstWhere(
          (record) => record != null,
          orElse: () => null,
        );

    final actualRecord = CycleCalculator.findActualRecordForDate(
      date: selectedDate,
      records: _actualRecords,
    );

    final periodStartCorrectionCandidate = actualRecord == null
        ? _findPeriodStartCorrectionCandidate(selectedDate)
        : null;

    final periodEndCandidate = actualRecord == null &&
            periodStartCorrectionCandidate == null
        ? _findPeriodEndCandidate(selectedDate)
        : null;

    final isActualPeriodDay = actualRecord != null;

    final isPredictedPeriodDay = !isActualPeriodDay &&
        CycleCalculator.isPredictedPeriodDay(
          date: selectedDate,
          predictedRecords: _predictedRecords,
        );

    String statusText;
    Widget phaseLeadingWidget;

    if (actualRecord != null) {
      final dayNumber =
          selectedDate.difference(_dateOnly(actualRecord.startDate)).inDays + 1;

      statusText = _l10n.calendarActualPeriodStatus(dayNumber);
      phaseLeadingWidget = const Icon(
        Icons.water_drop_rounded,
        color: Color(0xFFD9577D),
        size: 28,
      );
    } else if (periodStartCorrectionCandidate != null) {
      final oldStartDate =
          _dateOnly(periodStartCorrectionCandidate.startDate);
      final daysEarlier = oldStartDate.difference(selectedDate).inDays;

      statusText = _l10n.calendarStartCorrectionStatus(
        _formatDate(oldStartDate),
        daysEarlier,
      );
      phaseLeadingWidget = const Icon(
        Icons.edit_calendar_rounded,
        color: Color(0xFF7657A8),
        size: 28,
      );
    } else if (periodEndCandidate != null) {
      final dayNumber = selectedDate
              .difference(_dateOnly(periodEndCandidate.startDate))
              .inDays +
          1;

      statusText = _l10n.calendarEndCorrectionStatus(
        _formatDate(periodEndCandidate.startDate),
        dayNumber,
      );
      phaseLeadingWidget = const Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xFF7657A8),
        size: 28,
      );
    } else if (isPredictedPeriodDay) {
      statusText = _l10n.calendarPredictedPeriodDay;
      phaseLeadingWidget = const Icon(
        Icons.water_drop_outlined,
        color: Color(0xFFE4A2B5),
        size: 28,
      );
    } else {
      final cycleInfo = _getCycleInfoForDate(selectedDate);

      if (cycleInfo != null) {
        final isOvulation = CycleCalculator.isOvulationDay(
          date: selectedDate,
          cycleInfo: cycleInfo,
        );

        final cycleResult = CycleCalculator.calculate(
          cycleInfo,
          currentDate: selectedDate,
        );

        if (isOvulation) {
          statusText = _l10n.calendarEstimatedOvulationStatus(
            cycleResult.cycleDay,
          );
          phaseLeadingWidget = const Text(
            '👑',
            style: TextStyle(fontSize: 24),
          );
        } else {
          statusText = _l10n.calendarEstimatedPhaseStatus(
            cycleResult.cycleDay,
            _estimatedPhaseName(cycleResult.phase),
          );
          phaseLeadingWidget = Text(
            cycleResult.phaseIcon,
            style: const TextStyle(fontSize: 24),
          );
        }
      } else {
        statusText = _l10n.calendarNoRecord;
        phaseLeadingWidget = const Text(
          '📅',
          style: TextStyle(fontSize: 24),
        );
      }
    }

    final Widget actionSection;

    if (isFutureDate) {
      actionSection = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFF8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_clock_outlined,
              size: 18,
              color: Color(0xFF7657A8),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                _l10n.calendarFutureDateInfo,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF655A70),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (actualRecord != null) {
      // A date that already belongs to a real period can never start another
      // period. Only end-date editing/removal actions are shown here.
      if (actualRecord.isOngoing) {
        actionSection = Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _finishCurrentPeriod,
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  AppLocalizations.of(context)!.periodEnded,
                  style: const TextStyle(fontSize: 13),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7657A8),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _confirmRemoveRecord(actualRecord),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  _l10n.calendarRemovePeriodRecord,
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC74469),
                  side: const BorderSide(
                    color: Color(0xFFE4A2B5),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        actionSection = Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _confirmUpdatePeriodEnd(
                          actualRecord,
                          selectedDate,
                        ),
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  _l10n.calendarLastPeriodDay,
                  style: const TextStyle(fontSize: 13),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7657A8),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _confirmRemoveRecord(actualRecord),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  _l10n.calendarRemovePeriodRecord,
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC74469),
                  side: const BorderSide(
                    color: Color(0xFFE4A2B5),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    } else if (periodStartCorrectionCandidate != null) {
      actionSection = Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EFF8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _l10n.calendarPeriodStartCorrectionInfo(
                _formatDate(periodStartCorrectionCandidate.startDate),
              ),
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: Color(0xFF655A70),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              onPressed: _isSaving
                  ? null
                  : () => _confirmUpdatePeriodStart(
                        periodStartCorrectionCandidate,
                        selectedDate,
                      ),
              icon: const Icon(
                Icons.water_drop_outlined,
                size: 18,
              ),
              label:  Text(
                AppLocalizations.of(context)!.periodStartedToday,
                 style: const TextStyle(fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7657A8),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (periodEndCandidate != null) {
      actionSection = Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EFF8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _l10n.calendarPeriodEndExtensionInfo(
                _formatDate(periodEndCandidate.startDate),
              ),
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: Color(0xFF655A70),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              onPressed: _isSaving
                  ? null
                  : () => _confirmUpdatePeriodEnd(
                        periodEndCandidate,
                        selectedDate,
                      ),
              icon: const Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
              ),
              label: Text(
                _l10n.calendarLastPeriodDay,
                style: const TextStyle(fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7657A8),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (ongoingRecord != null) {
      final ongoingStartDate = _dateOnly(ongoingRecord.startDate);
      final isBeforeOngoingPeriod = selectedDate.isBefore(ongoingStartDate);

      actionSection = Column(
        children: [
          if (!isBeforeOngoingPeriod) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF2D8A6),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 19,
                    color: Color(0xFFD58A24),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _l10n.calendarUnfinishedPeriodInfo(
                        _defaultUnfinishedPeriodLength,
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Color(0xFF66533A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleStartPeriod,
              icon: Icon(
                isBeforeOngoingPeriod
                    ? Icons.history_rounded
                    : Icons.add_circle_outline,
                size: 18,
              ),
              label: Text(
                isBeforeOngoingPeriod
                    ? _l10n.calendarAddHistoricalPeriod
                    : selectedDate.isBefore(today)
                        ? _l10n.calendarAddHistoricalPeriod
                        : _l10n.calendarStartNewPeriod,
                style: const TextStyle(fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7657A8),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      actionSection = SizedBox(
        height: 40,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _handleStartPeriod,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  selectedDate.isBefore(today)
                      ? Icons.history_rounded
                      : Icons.water_drop_outlined,
                  size: 18,
                ),
          label: Text(
            selectedDate.isBefore(today)
                ? _l10n.calendarAddHistoricalPeriod
                : _l10n.calendarPeriodStarted,
            style: const TextStyle(fontSize: 13),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7657A8),
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Center(child: phaseLeadingWidget),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2733),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF77707E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          actionSection,
        ],
      ),
    );
  }

  Future<void> _confirmUpdatePeriodStart(
    PeriodRecord record,
    DateTime selectedDate,
  ) async {
    final normalizedSelectedDate = _dateOnly(selectedDate);
    final oldStartDate = _dateOnly(record.startDate);
    final daysEarlier = oldStartDate.difference(normalizedSelectedDate).inDays;

    if (daysEarlier != 1 && daysEarlier != 2) {
      return;
    }

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_l10n.calendarUpdateStartTitle),
          content: Text(
            '${_l10n.calendarOldStartLabel}: ${_formatDate(oldStartDate)}\n'
            '${_l10n.calendarNewStartLabel}: ${_formatDate(normalizedSelectedDate)}\n\n'
            '${_l10n.calendarUpdateStartDescription(daysEarlier)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_l10n.calendarCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7657A8),
              ),
              child: Text(_l10n.calendarUpdate),
            ),
          ],
        );
      },
    );

    if (shouldUpdate != true) {
      return;
    }

    await _updatePeriodStart(record, normalizedSelectedDate);
  }

  Future<void> _updatePeriodStart(
    PeriodRecord record,
    DateTime selectedDate,
  ) async {
    final normalizedSelectedDate = _dateOnly(selectedDate);
    final oldStartDate = _dateOnly(record.startDate);
    final daysEarlier = oldStartDate.difference(normalizedSelectedDate).inDays;

    if (daysEarlier != 1 && daysEarlier != 2) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final overlapsAnotherRecord = _actualRecords.any((other) {
        if (_isSameDay(other.startDate, record.startDate)) {
          return false;
        }

        final otherStartDate = _dateOnly(other.startDate);
        final otherEndDate = _dateOnly(other.effectiveEndDate);
        final updatedEndDate = _dateOnly(record.effectiveEndDate);

        return !updatedEndDate.isBefore(otherStartDate) &&
            !normalizedSelectedDate.isAfter(otherEndDate);
      });

      if (overlapsAnotherRecord) {
        throw StateError('UPDATED_PERIOD_OVERLAPS_EXISTING_PERIOD');
      }

      final int updatedPredictedLength;
      if (record.isOngoing) {
        updatedPredictedLength = record.predictedLength;
      } else {
        updatedPredictedLength =
            _dateOnly(record.effectiveEndDate)
                    .difference(normalizedSelectedDate)
                    .inDays +
                1;

        if (updatedPredictedLength > _maximumPeriodLength) {
          throw StateError('UPDATED_PERIOD_TOO_LONG');
        }
      }

      final updatedRecord = PeriodRecord(
        startDate: normalizedSelectedDate,
        endDate: record.endDate == null ? null : _dateOnly(record.endDate!),
        predictedLength: updatedPredictedLength,
      );

      final updated = await StorageService.updatePeriodRecord(
        oldStartDate: record.startDate,
        updatedRecord: updatedRecord,
      );

      if (!updated) {
        throw StateError('Record not found.');
      }

      await _loadCalendarData(showLoading: false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _l10n.calendarStartUpdatedMessage(
              _formatDate(normalizedSelectedDate),
            ),
          ),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      final String message;
      if (error.message == 'UPDATED_PERIOD_OVERLAPS_EXISTING_PERIOD') {
        message = _l10n.calendarStartOverlapError;
      } else if (error.message == 'UPDATED_PERIOD_TOO_LONG') {
        message = _l10n.calendarPeriodTooLongAfterStartError(
          _maximumPeriodLength,
        );
      } else {
        message = _l10n.calendarStartUpdateError;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarStartUpdateError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleStartPeriod() async {
    final today = _dateOnly(DateTime.now());
    final selectedDate = _dateOnly(_selectedDate);

    if (selectedDate.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarFutureAddError),
        ),
      );
      return;
    }

    final recordOnSelectedDate = CycleCalculator.findActualRecordForDate(
      date: selectedDate,
      records: _actualRecords,
    );

    if (recordOnSelectedDate != null) {
      final dayNumber = selectedDate
              .difference(_dateOnly(recordOnSelectedDate.startDate))
              .inDays +
          1;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_l10n.calendarAlreadyPeriodTitle),
            content: Text(
              _l10n.calendarAlreadyPeriodDescription(
                dayNumber,
                _formatDate(recordOnSelectedDate.startDate),
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(_l10n.calendarOk),
              ),
            ],
          );
        },
      );
      return;
    }

    final ongoingRecords =
        _actualRecords.where((record) => record.isOngoing).toList();

    if (ongoingRecords.isNotEmpty) {
      final ongoingRecord = ongoingRecords.first;
      final ongoingStartDate = _dateOnly(ongoingRecord.startDate);

      if (selectedDate.isBefore(ongoingStartDate)) {
        // A historical period before the current ongoing period is stored as
        // a completed 4-day record. The ongoing record is not changed.
        await _confirmAddHistoricalRecord();
        return;
      }

      // The selected date is after the ongoing period's default 4-day range.
      // Complete the old record as 4 days and create the selected record.
      final selectedIsHistorical = selectedDate.isBefore(today);
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_l10n.calendarUnfinishedRecordTitle),
            content: Text(
              '${_l10n.calendarUnfinishedRecordBase(
                _formatDate(ongoingStartDate),
                _defaultUnfinishedPeriodLength,
              )}\n\n'
              '${selectedIsHistorical
                  ? _l10n.calendarNewHistoricalRecordOutcome(
                      _formatDate(selectedDate),
                      _defaultUnfinishedPeriodLength,
                    )
                  : _l10n.calendarNewOngoingRecordOutcome(
                      _formatDate(selectedDate),
                    )}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(_l10n.calendarCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7657A8),
                ),
                child: Text(_l10n.calendarConfirm),
              ),
            ],
          );
        },
      );

      if (shouldProceed == true) {
        await _resolveOngoingPeriodAndStartNew();
      }
      return;
    }

    if (selectedDate.isBefore(today)) {
      // Every period entered for a past date is completed automatically as
      // four days. It never becomes the current ongoing period.
      await _confirmAddHistoricalRecord();
      return;
    }

    await _confirmAddRecord();
  }

  Future<void> _confirmAddHistoricalRecord() async {
    final selectedDate = _dateOnly(_selectedDate);
    final endDate = selectedDate.add(
      Duration(days: _defaultUnfinishedPeriodLength - 1),
    );

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_l10n.calendarAddHistoricalTitle),
          content: Text(
            '${_l10n.calendarStartLabel}: ${_formatDate(selectedDate)}\n'
            '${_l10n.calendarEndLabel}: ${_formatDate(endDate)}\n\n'
            '${_l10n.calendarHistoricalDurationInfo(
              _defaultUnfinishedPeriodLength,
            )}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_l10n.calendarCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7657A8),
              ),
              child: Text(_l10n.calendarAddRecord),
            ),
          ],
        );
      },
    );

    if (shouldAdd != true) {
      return;
    }

    await _addHistoricalRecord();
  }

  Future<void> _addHistoricalRecord() async {
    final selectedDate = _dateOnly(_selectedDate);
    final endDate = selectedDate.add(
      Duration(days: _defaultUnfinishedPeriodLength - 1),
    );

    final overlapsExistingRecord = _actualRecords.any((record) {
      final existingStart = _dateOnly(record.startDate);
      final existingEnd = _dateOnly(record.effectiveEndDate);

      return !endDate.isBefore(existingStart) &&
          !selectedDate.isAfter(existingEnd);
    });

    if (overlapsExistingRecord) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarOverlapError),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await StorageService.addPeriodRecord(
        PeriodRecord(
          startDate: selectedDate,
          endDate: endDate,
          predictedLength: _defaultUnfinishedPeriodLength,
        ),
      );

      await _loadCalendarData(showLoading: false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _l10n.calendarHistoricalAdded(
              _formatDate(selectedDate),
              _defaultUnfinishedPeriodLength,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarHistoricalAddError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _resolveOngoingPeriodAndStartNew() async {
    final today = _dateOnly(DateTime.now());
    final selectedDate = _dateOnly(_selectedDate);

    if (selectedDate.isAfter(today)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final records = await StorageService.getPeriodRecords();
      final ongoingIndex = records.indexWhere((record) => record.isOngoing);

      if (ongoingIndex == -1) {
        throw StateError('NO_ONGOING_PERIOD');
      }

      final ongoingRecord = records[ongoingIndex];
      final ongoingStartDate = _dateOnly(ongoingRecord.startDate);
      final calculatedEndDate = ongoingStartDate.add(
        Duration(days: _defaultUnfinishedPeriodLength - 1),
      );

      if (!selectedDate.isAfter(calculatedEndDate)) {
        throw StateError('NEW_START_OVERLAPS_ONGOING_PERIOD');
      }

      records[ongoingIndex] = PeriodRecord(
        startDate: ongoingStartDate,
        endDate: calculatedEndDate,
        predictedLength: ongoingRecord.predictedLength,
      );

      final selectedIsHistorical = selectedDate.isBefore(today);
      final newRecordEndDate = selectedIsHistorical
          ? selectedDate.add(
              Duration(days: _defaultUnfinishedPeriodLength - 1),
            )
          : null;
      final newRecordEffectiveEndDate = newRecordEndDate ??
          selectedDate.add(
            Duration(days: _defaultUnfinishedPeriodLength - 1),
          );

      final overlapsExistingRecord = records.any((record) {
        final existingStart = _dateOnly(record.startDate);
        final existingEnd = _dateOnly(record.effectiveEndDate);

        return !newRecordEffectiveEndDate.isBefore(existingStart) &&
            !selectedDate.isAfter(existingEnd);
      });

      if (overlapsExistingRecord) {
        throw StateError('NEW_RECORD_OVERLAPS_EXISTING_PERIOD');
      }

      records.add(
        PeriodRecord(
          startDate: selectedDate,
          endDate: newRecordEndDate,
          predictedLength: _defaultUnfinishedPeriodLength,
        ),
      );

      // Save the completed old record and the new record together. This avoids
      // leaving the old record closed if creating the new one fails midway.
      await StorageService.savePeriodRecords(records);
      await _loadCalendarData(showLoading: false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedIsHistorical
                ? _l10n.calendarPreviousCompletedAndHistoricalAdded(
                    _defaultUnfinishedPeriodLength,
                  )
                : _l10n.calendarPreviousCompletedAndNewStarted(
                    _defaultUnfinishedPeriodLength,
                  ),
          ),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message == 'NEW_START_OVERLAPS_ONGOING_PERIOD' ||
              error.message == 'NEW_RECORD_OVERLAPS_EXISTING_PERIOD'
          ? _l10n.calendarSelectedDateOverlapError(
              _defaultUnfinishedPeriodLength,
            )
          : _l10n.calendarNewStartSaveError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarNewStartSaveError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmAddRecord() async {
    final selectedDate = _dateOnly(_selectedDate);

    if (selectedDate.isAfter(_dateOnly(DateTime.now()))) {
      return;
    }

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_l10n.calendarNewCycleTitle),
          content: Text(
            '${_l10n.calendarConfirmStart(
              _formatDate(selectedDate),
            )}\n\n'
            '${_l10n.calendarTemporaryRecordInfo(
              _defaultUnfinishedPeriodLength,
            )}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_l10n.calendarCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_l10n.calendarPeriodStarted),
            ),
          ],
        );
      },
    );

    if (shouldAdd != true) {
      return;
    }

    await _addPeriodRecord(
      periodLength: _defaultUnfinishedPeriodLength,
    );
  }

  Future<void> _addPeriodRecord({required int periodLength}) async {
    final selectedDate = _dateOnly(_selectedDate);

    if (selectedDate.isAfter(_dateOnly(DateTime.now()))) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await StorageService.startPeriod(
        selectedDate,
        predictedLength: periodLength,
      );

      await _loadCalendarData(showLoading: false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarPeriodStartSaved),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message == 'An ongoing period already exists.'
          ? _l10n.calendarOngoingExistsError
          : _l10n.calendarDateAlreadyHasRecordError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarPeriodStartSaveError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _finishCurrentPeriod() async {
    final selectedDate = _dateOnly(_selectedDate);

    if (selectedDate.isAfter(_dateOnly(DateTime.now()))) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await StorageService.finishOngoingPeriod(selectedDate);
      await _loadCalendarData(showLoading: false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _l10n.calendarPeriodEndSaved(
              _formatDate(selectedDate),
            ),
          ),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message == 'ONGOING_PERIOD_TOO_LONG'
          ? _l10n.calendarPeriodEndTooLongError(
              _maximumPeriodLength,
            )
          : _l10n.calendarPeriodEndSaveError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarPeriodEndSaveError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmUpdatePeriodEnd(
    PeriodRecord record,
    DateTime selectedDate,
  ) async {
    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_l10n.calendarConfirmLastDayTitle),
          content: Text(
            '${_l10n.calendarLastDayLabel}: ${_formatDate(selectedDate)}\n'
            '${_l10n.calendarTotalDurationLabel}: '
            '${_l10n.calendarDayCount(
              _dateOnly(selectedDate)
                      .difference(_dateOnly(record.startDate))
                      .inDays +
                  1,
            )}\n\n'
            '${_l10n.calendarSaveRealDurationInfo}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_l10n.calendarCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7657A8),
              ),
              child: Text(_l10n.calendarUpdate),
            ),
          ],
        );
      },
    );

    if (shouldUpdate != true) {
      return;
    }

    await _updatePeriodEnd(record, selectedDate);
  }

  Future<void> _updatePeriodEnd(
    PeriodRecord record,
    DateTime selectedDate,
  ) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final normalizedSelectedDate = _dateOnly(selectedDate);
      final normalizedStartDate = _dateOnly(record.startDate);
      final newPeriodLength =
          normalizedSelectedDate.difference(normalizedStartDate).inDays + 1;

      if (newPeriodLength < 1 ||
          newPeriodLength > _maximumPeriodLength) {
        throw StateError('INVALID_PERIOD_LENGTH');
      }

      final updatedRecord = record.copyWith(
        endDate: normalizedSelectedDate,
        predictedLength: newPeriodLength,
      );

      final updated = await StorageService.updatePeriodRecord(
        oldStartDate: record.startDate,
        updatedRecord: updatedRecord,
      );

      if (!updated) {
        throw StateError('Record not found.');
      }

      await _loadCalendarData(showLoading: false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _l10n.calendarLastDaySaved(
              _formatDate(normalizedSelectedDate),
              newPeriodLength,
            ),
          ),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message == 'INVALID_PERIOD_LENGTH'
          ? _l10n.calendarPeriodLengthRangeError(
              _maximumPeriodLength,
            )
          : _l10n.calendarPeriodEndUpdateError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.calendarPeriodEndUpdateError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmRemoveRecord(PeriodRecord record) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_l10n.calendarRemoveTitle),
          content: Text(
            _l10n.calendarRemoveDescription(
              _formatDate(record.startDate),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_l10n.calendarCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC74469),
              ),
              child: Text(_l10n.calendarRemove),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) return;

    await _removePeriodRecord(record);
  }

  Future<void> _removePeriodRecord(PeriodRecord record) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final removed = await StorageService.removePeriodRecord(record.startDate);
      if (!removed) throw StateError('Record not found.');

      await _loadCalendarData(showLoading: false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.calendarRemoved)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.calendarRemoveError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildLegend() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: const Color(0xFFD9577D),
                label: _l10n.calendarLegendActualPeriod,
              ),
            ),
            Expanded(
              child: _LegendItem(
                color: const Color(0xFFFCE4EC),
                label: _l10n.calendarLegendPredictedPeriod,
                borderColor: const Color(0xFFE4A2B5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: const Color(0xFFE6B800),
                label: _l10n.calendarLegendFertileWindow,
              ),
            ),
            Expanded(
              child: _LegendItem(
                color: const Color(0xFF8E24AA),
                label: _l10n.calendarLegendPmsPhase,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _l10n.calendarPredictionDisclaimer,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.5,
            height: 1.35,
            color: Color(0xFF8A8294),
          ),
        ),
      ],
    );
  }

  String _estimatedPhaseName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return _l10n.calendarEstimatedMenstruationPhase;
      case CyclePhase.renewal:
        return _l10n.calendarEstimatedRenewalPhase;
      case CyclePhase.fertile:
        return _l10n.calendarEstimatedFertilePhase;
      case CyclePhase.pms:
        return _l10n.calendarEstimatedPmsPhase;
      case CyclePhase.rest:
        return _l10n.calendarEstimatedRestPhase;
    }
  }

  void _showPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
      );
      _predictedRecords = _generatePredictions(
        records: _actualRecords,
        periodLength: _fallbackPeriodLength,
        cycleLength: _fallbackCycleLength,
      );
    });
  }

  void _showNextMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
      );
      _predictedRecords = _generatePredictions(
        records: _actualRecords,
        periodLength: _fallbackPeriodLength,
        cycleLength: _fallbackCycleLength,
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatMonthYear(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final monthName = _monthNames[date.month - 1];
    final languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'tr') {
      return '${date.day} $monthName ${date.year}';
    }

    return '$monthName ${date.day}, ${date.year}';
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? borderColor;

  const _LegendItem({
    required this.color,
    required this.label,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF77707E),
          ),
        ),
      ],
    );
  }
}