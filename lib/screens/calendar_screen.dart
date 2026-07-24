import 'package:flutter/material.dart';

import '../models/cycle_info.dart';
import '../models/period_record.dart';
import '../services/cycle_calculator.dart';
import '../services/storage_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<PeriodRecord> _actualRecords = [];
  List<PeriodRecord> _predictedRecords = [];

  int _fallbackPeriodLength = 5;
  int _fallbackCycleLength = 28;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  static const List<String> _monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> _weekDays = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
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
        _errorMessage = 'Takvim bilgileri yüklenemedi.';
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

  void _refreshPredictions() {
    _predictedRecords = _generatePredictions(
      records: _actualRecords,
      periodLength: _fallbackPeriodLength,
      cycleLength: _fallbackCycleLength,
    );
  }

  CycleInfo? get _effectiveCycleInfo {
    if (_actualRecords.isEmpty) {
      return null;
    }

    final sortedRecords = [..._actualRecords]
      ..sort(
        (first, second) =>
            first.startDate.compareTo(second.startDate),
      );

    final predictedCycleLength =
        CycleCalculator.calculatePredictedCycleLength(
      records: sortedRecords,
      fallbackCycleLength: _fallbackCycleLength,
    );

    final predictedPeriodLength =
        CycleCalculator.calculatePredictedPeriodLength(
      records: sortedRecords,
      fallbackPeriodLength: _fallbackPeriodLength,
    );

    return CycleInfo(
      lastPeriodDate: sortedRecords.last.startDate,
      periodLength: predictedPeriodLength,
      cycleLength: predictedCycleLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Takvim',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2733),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF7657A8),
        ),
      ),
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
                child: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Döngü takvimin',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2733),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gerçek ve tahmini regl günlerini buradan takip edebilirsin.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF77707E),
            ),
          ),
          const SizedBox(height: 16),
          _buildCalendarCard(),
          const SizedBox(height: 16),
          _buildSelectedDayCard(),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 22),
          _buildWeekDayHeader(),
          const SizedBox(height: 12),
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
          '${_monthNames[_visibleMonth.month - 1]} '
          '${_visibleMonth.year}',
          style: const TextStyle(
            fontSize: 19,
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: const Color(0xFF7657A8),
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
    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final itemCount = rowCount * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
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

    final actualRecord =
        CycleCalculator.findActualRecordForDate(
      date: date,
      records: _actualRecords,
    );

    final isActualPeriodDay = actualRecord != null;

    final isPredictedPeriodDay =
        !isActualPeriodDay &&
        CycleCalculator.isPredictedPeriodDay(
          date: date,
          predictedRecords: _predictedRecords,
        );

    final phaseColor = _getDayColor(
      date: date,
      isActualPeriodDay: isActualPeriodDay,
      isPredictedPeriodDay: isPredictedPeriodDay,
    );

    final textColor = isActualPeriodDay
        ? Colors.white
        : const Color(0xFF2D2733);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: phaseColor,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF7657A8),
                    width: 2.5,
                  )
                : isToday
                    ? Border.all(
                        color: const Color(0xFFB8A4D6),
                        width: 1.5,
                      )
                    : isPredictedPeriodDay
                        ? Border.all(
                            color: const Color(0xFFD9799A),
                            width: 1,
                          )
                        : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected || isToday
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Color? _getDayColor({
    required DateTime date,
    required bool isActualPeriodDay,
    required bool isPredictedPeriodDay,
  }) {
    if (isActualPeriodDay) {
      return const Color(0xFFD9577D);
    }

    if (isPredictedPeriodDay) {
      return const Color(0xFFF8D7E1);
    }

    final cycleInfo = _effectiveCycleInfo;

    if (cycleInfo == null) {
      return null;
    }

    return _getPhaseColor(
      date,
      cycleInfo,
    );
  }

  int _getCycleDay(
    DateTime date,
    CycleInfo cycleInfo,
  ) {
    final selectedDate = _dateOnly(date);
    final lastPeriodDate = _dateOnly(
      cycleInfo.lastPeriodDate,
    );

    final difference =
        selectedDate.difference(lastPeriodDate).inDays;

    return ((difference % cycleInfo.cycleLength) +
                cycleInfo.cycleLength) %
            cycleInfo.cycleLength +
        1;
  }

  String _getPhaseName(
    DateTime date,
    CycleInfo cycleInfo,
  ) {
    final cycleDay = _getCycleDay(
      date,
      cycleInfo,
    );

    final ovulationDay = cycleInfo.cycleLength - 14;
    final fertileStartDay = ovulationDay - 5;

    if (cycleDay <= cycleInfo.periodLength) {
      return 'Regl dönemi';
    }

    if (cycleDay >= fertileStartDay &&
        cycleDay <= ovulationDay) {
      return 'Doğurgan dönem';
    }

    if (cycleDay < fertileStartDay) {
      return 'Yenilenme dönemi';
    }

    return 'Dinlenme dönemi';
  }

  Color? _getPhaseColor(
    DateTime date,
    CycleInfo? cycleInfo,
  ) {
    if (cycleInfo == null) {
      return null;
    }

    final cycleDay = _getCycleDay(
      date,
      cycleInfo,
    );

    final ovulationDay = cycleInfo.cycleLength - 14;
    final fertileStartDay = ovulationDay - 5;

    if (cycleDay <= cycleInfo.periodLength) {
      return const Color(0xFFF4A8BC);
    }

    if (cycleDay >= fertileStartDay &&
        cycleDay <= ovulationDay) {
      return const Color(0xFFF3CF62);
    }

    if (cycleDay < fertileStartDay) {
      return const Color(0xFF9DD8AE);
    }

    return const Color(0xFFCDB6F5);
  }

  Widget _buildSelectedDayCard() {
    final ongoingRecord =
    _actualRecords
        .where((record) => record.isOngoing)
        .cast<PeriodRecord?>()
        .firstWhere(
          (record) => record != null,
          orElse: () => null,
        );

    final hasOngoingPeriod = ongoingRecord != null;

    final actualRecord =
        CycleCalculator.findActualRecordForDate(
      date: _selectedDate,
      records: _actualRecords,
    );

    final isActualPeriodDay = actualRecord != null;

    final isPredictedPeriodDay =
        !isActualPeriodDay &&
        CycleCalculator.isPredictedPeriodDay(
          date: _selectedDate,
          predictedRecords: _predictedRecords,
        );

    final cycleInfo = _effectiveCycleInfo;

    String statusText;

    if (isActualPeriodDay) {
      final dayNumber = _selectedDate
              .difference(actualRecord.startDate)
              .inDays +
          1;

      statusText =
          'Gerçek regl kaydı · $dayNumber. gün';
    } else if (isPredictedPeriodDay) {
      statusText = 'Luna tarafından tahmin edilen regl günü';
    } else if (cycleInfo != null) {
      final cycleDay = _getCycleDay(
        _selectedDate,
        cycleInfo,
      );

      final phaseName = _getPhaseName(
        _selectedDate,
        cycleInfo,
      );

      statusText = '$cycleDay. döngü günü · $phaseName';
    } else {
      statusText = 'Bu tarih için henüz bir döngü kaydı yok.';
    }

    final cardColor = isActualPeriodDay
        ? const Color(0xFFD9577D)
        : isPredictedPeriodDay
            ? const Color(0xFFF8D7E1)
            : _getPhaseColor(
                  _selectedDate,
                  cycleInfo,
                ) ??
                const Color(0xFFF3EFF8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_selectedDate.day}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isActualPeriodDay
                        ? Colors.white
                        : const Color(0xFF2D2733),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedDate.day} '
                      '${_monthNames[_selectedDate.month - 1]} '
                      '${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2733),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF77707E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isActualPeriodDay
    ? OutlinedButton.icon(
        onPressed: _isSaving
            ? null
            : () => _confirmRemoveRecord(actualRecord),
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text('Regl kaydını kaldır'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFC74469),
          side: const BorderSide(
            color: Color(0xFFE4A2B5),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
      )
    : hasOngoingPeriod
        ? FilledButton.icon(
            onPressed: _isSaving
                ? null
                : _finishCurrentPeriod,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Reglim Bitti'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC74469),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          )
        : FilledButton.icon(
            onPressed: _isSaving
                ? null
                : _confirmAddRecord,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.water_drop_outlined),
            label: const Text(
              'Regl Başladı',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7657A8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAddRecord() async {
  const defaultPredictedLength = 4;

  final shouldAdd = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          '🌙 Yeni Döngü',
        ),
        content: Text(
          '${_formatDate(_selectedDate)} tarihinde regl başladığını onaylıyor musun?\n\n'
          'Luna şimdilik 4 günlük geçici bir kayıt oluşturacak. '
          'Reglin bittiğinde bunu tek dokunuşla güncelleyebilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Regl Başladı'),
          ),
        ],
      );
    },
  );

  if (shouldAdd != true) {
    return;
  }

  await _addPeriodRecord(
    periodLength: defaultPredictedLength,
  );
}

 
  Future<void> _addPeriodRecord({
  required int periodLength,
}) async {
  setState(() {
    _isSaving = true;
  });

  try {
    await StorageService.startPeriod(
      _selectedDate,
      predictedLength: periodLength,
    );

    await _loadCalendarData(
      showLoading: false,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Regl başlangıcı kaydedildi.',
        ),
      ),
    );
  } on StateError catch (error) {
    if (!mounted) {
      return;
    }

    final message = error.message == 'An ongoing period already exists.'
        ? 'Devam eden bir regl kaydı zaten var.'
        : 'Bu tarih için zaten bir regl kaydı bulunuyor.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (_) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Regl başlangıcı kaydedilemedi.',
        ),
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
  setState(() {
    _isSaving = true;
  });

  try {
    await StorageService.finishOngoingPeriod(_selectedDate);

    await _loadCalendarData(showLoading: false);
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  Future<void> _confirmRemoveRecord(
    PeriodRecord record,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Regl kaydı kaldırılsın mı?',
          ),
          content: Text(
            '${_formatDate(record.startDate)} tarihinde başlayan '
            '${record.periodLength} günlük regl kaydı kaldırılacak.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFC74469),
              ),
              child: const Text('Kaldır'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    await _removePeriodRecord(record);
  }

  Future<void> _removePeriodRecord(
    PeriodRecord record,
  ) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final removed =
          await StorageService.removePeriodRecord(
        record.startDate,
      );

      if (!removed) {
        throw StateError('Record not found.');
      }

      await _loadCalendarData(
        showLoading: false,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Regl kaydı kaldırıldı.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Regl kaydı kaldırılamadı.',
          ),
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

  Widget _buildLegend() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: Color(0xFFD9577D),
                label: 'Gerçek regl',
              ),
            ),
            Expanded(
              child: _LegendItem(
                color: Color(0xFFF8D7E1),
                label: 'Tahmini regl',
                borderColor: Color(0xFFD9799A),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: Color(0xFF9DD8AE),
                label: 'Yenilenme',
              ),
            ),
            Expanded(
              child: _LegendItem(
                color: Color(0xFFF3CF62),
                label: 'Doğurgan dönem',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: Color(0xFFCDB6F5),
                label: 'Dinlenme',
              ),
            ),
            Expanded(
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  void _showPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
      );

      _refreshPredictions();
    });
  }

  void _showNextMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
      );

      _refreshPredictions();
    });
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  bool _isSameDay(
    DateTime firstDate,
    DateTime secondDate,
  ) {
    return firstDate.year == secondDate.year &&
        firstDate.month == secondDate.month &&
        firstDate.day == secondDate.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day} '
        '${_monthNames[date.month - 1]} '
        '${date.year}';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.borderColor,
  });

  final Color color;
  final String label;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ??
                  Colors.black.withValues(alpha: 0.08),
              width: borderColor == null ? 0.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF77707E),
            ),
          ),
        ),
      ],
    );
  }
}