import 'package:flutter/material.dart';

import '../models/cycle_info.dart';
import '../services/storage_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final Future<CycleInfo?> _cycleInfoFuture =
      StorageService.getCycleInfo();

  DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

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
        child: FutureBuilder<CycleInfo?>(
          future: _cycleInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7657A8),
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Döngü bilgileri yüklenemedi.',
                  style: TextStyle(
                    color: Color(0xFF77707E),
                  ),
                ),
              );
            }

            final cycleInfo = snapshot.data;

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
                    'Regl ve tahmini döngü günlerini burada görebilirsin.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF77707E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCalendarCard(cycleInfo),
                  const SizedBox(height: 16),
                  if (cycleInfo != null) ...[
                    _buildSelectedDayCard(cycleInfo),
                    const SizedBox(height: 20),
                  ],
                  _buildLegend(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCard(CycleInfo? cycleInfo) {
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
          _buildCalendarGrid(cycleInfo),
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

  Widget _buildCalendarGrid(CycleInfo? cycleInfo) {
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

        return _buildDayCell(
          date,
          cycleInfo,
        );
      },
    );
  }

  Widget _buildDayCell(
    DateTime date,
    CycleInfo? cycleInfo,
  ) {
    final today = DateTime.now();

    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    final phaseColor = _getPhaseColor(
      date,
      cycleInfo,
    );

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
              color: const Color(0xFF2D2733),
            ),
          ),
        ),
      ),
    );
  }
  int _getCycleDay(
  DateTime date,
  CycleInfo cycleInfo,
) {
  final selectedDate = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final lastPeriodDate = DateTime(
    cycleInfo.lastPeriodDate.year,
    cycleInfo.lastPeriodDate.month,
    cycleInfo.lastPeriodDate.day,
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

Widget _buildSelectedDayCard(
  CycleInfo cycleInfo,
) {
  final cycleDay = _getCycleDay(
    _selectedDate,
    cycleInfo,
  );

  final phaseName = _getPhaseName(
    _selectedDate,
    cycleInfo,
  );

  final phaseColor = _getPhaseColor(
    _selectedDate,
    cycleInfo,
  );

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
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: phaseColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${_selectedDate.day}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2733),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                '$cycleDay. döngü günü · $phaseName',
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
  );
}

Widget _buildLegend() {
  return const Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _LegendItem(
              color: Color(0xFFF4A8BC),
              label: 'Regl',
            ),
          ),
          Expanded(
            child: _LegendItem(
              color: Color(0xFF9DD8AE),
              label: 'Yenilenme',
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _LegendItem(
              color: Color(0xFFF3CF62),
              label: 'Doğurgan dönem',
            ),
          ),
          Expanded(
            child: _LegendItem(
              color: Color(0xFFCDB6F5),
              label: 'Dinlenme',
            ),
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
  });
}

void _showNextMonth() {
  setState(() {
    _visibleMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
    );
  });
}
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

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
              color: Colors.black.withValues(alpha: 0.08),
              width: 0.5,
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF77707E),
          ),
        ),
      ],
    );
  }
}
