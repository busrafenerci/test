import 'package:flutter/material.dart';
import 'package:within/l10n/app_localizations.dart';

import '../models/cycle_info.dart';
import '../models/period_record.dart';
import '../services/cycle_calculator.dart';
import '../services/storage_service.dart';
import '../widgets/cycle_ring.dart';

class HomeScreen extends StatefulWidget {
  final int refreshVersion;

  const HomeScreen({
    super.key,
    this.refreshVersion = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<Map<String, dynamic>> _dataFuture;
  CyclePhaseDetails? _selectedPhaseDetails;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  bool get _isTurkish =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'tr';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshVersion != oldWidget.refreshVersion) {
      _reloadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _reloadData();
    }
  }

  void _loadData() {
    _dataFuture = _fetchHomeScreenData();
  }

  Future<Map<String, dynamic>> _fetchHomeScreenData() async {
    final actualRecords = await StorageService.getPeriodRecords();
    final fallbackPeriodLength = await StorageService.getPeriodLength();
    final fallbackCycleLength = await StorageService.getCycleLength();

    return {
      'actualRecords': actualRecords,
      'fallbackPeriodLength': fallbackPeriodLength,
      'fallbackCycleLength': fallbackCycleLength,
    };
  }

  void _reloadData() {
    setState(() {
      _selectedPhaseDetails = null;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7657A8),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState();
            }

            final data = snapshot.data!;
            final List<PeriodRecord> actualRecords = data['actualRecords'];
            final int fallbackPeriodLength = data['fallbackPeriodLength'];
            final int fallbackCycleLength = data['fallbackCycleLength'];

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            final cycleInfo = _createCycleInfoForToday(
              today: today,
              records: actualRecords,
              fallbackPeriodLength: fallbackPeriodLength,
              fallbackCycleLength: fallbackCycleLength,
            );

            final result = CycleCalculator.calculate(
              cycleInfo,
              currentDate: today,
            );

            return _buildHomeContent(
              cycleInfo: cycleInfo,
              result: result,
            );
          },
        ),
      ),
    );
  }

  CycleInfo _createCycleInfoForToday({
    required DateTime today,
    required List<PeriodRecord> records,
    required int fallbackPeriodLength,
    required int fallbackCycleLength,
  }) {
    final lastPastOrTodayRecord = CycleCalculator.findLastRecordBefore(
      today,
      records,
    );

    if (lastPastOrTodayRecord != null) {
      return CycleInfo(
        lastPeriodDate: lastPastOrTodayRecord.startDate,
        periodLength: lastPastOrTodayRecord.periodLength,
        cycleLength: fallbackCycleLength,
      );
    }

    // There is no past record, but there may be a future period start.
    // In that case, estimate the previous cycle start by going back one
    // full cycle. This prevents a future date from being shown as day 1 today.
    final futureRecords = records.where((record) {
      final startDate = _dateOnly(record.startDate);
      return startDate.isAfter(today);
    }).toList()
      ..sort((first, second) =>
          first.startDate.compareTo(second.startDate));

    if (futureRecords.isNotEmpty) {
      final nearestFutureRecord = futureRecords.first;
      final estimatedPreviousPeriodDate = _dateOnly(
        nearestFutureRecord.startDate,
      ).subtract(
        Duration(days: fallbackCycleLength),
      );

      return CycleInfo(
        lastPeriodDate: estimatedPreviousPeriodDate,
        periodLength: nearestFutureRecord.periodLength,
        cycleLength: fallbackCycleLength,
      );
    }

    // Defensive fallback for an unexpected empty record list.
    return CycleInfo(
      lastPeriodDate: today.subtract(
        Duration(days: fallbackCycleLength - 1),
      ),
      periodLength: fallbackPeriodLength,
      cycleLength: fallbackCycleLength,
    );
  }

  Widget _buildHomeContent({
    required CycleInfo cycleInfo,
    required CycleResult result,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_selectedPhaseDetails != null) {
          setState(() {
            _selectedPhaseDetails = null;
          });
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.homeGreeting,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2733),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _l10n.homeSubtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF77707E),
              ),
            ),
            const SizedBox(height: 14),
            _buildCycleCard(result, cycleInfo),
            const SizedBox(height: 10),
            _buildTodayStatusCard(
              result: result,
            ),
            const SizedBox(height: 10),
            _buildCompactCycleInfoCard(
              cycleInfo: cycleInfo,
              result: result,
            ),
          ],
        ),
      ),
    );
  }

  String _getHomeImage({
    required CycleInfo cycleInfo,
    required CycleResult result,
  }) {
    final ovulationDay = cycleInfo.cycleLength - 14;

    if (result.phase == CyclePhase.menstruation) {
      return 'assets/images/Within_home_period.png';
    }

    if (result.cycleDay == ovulationDay) {
      return 'assets/images/Within_home_ovulation.png';
    }

    if (result.phase == CyclePhase.fertile) {
      return 'assets/images/Within_home_fertile.png';
    }

    if (result.phase == CyclePhase.pms) {
      return 'assets/images/Within_home_pms.png';
    }

    return 'assets/images/Within_home_default.png';
  }

  Widget _buildCycleCard(
    CycleResult result,
    CycleInfo cycleInfo,
  ) {
    return Container(
      width: double.infinity,
      height: 326,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Center(
                child: CycleRing(
                  cycleDay: result.cycleDay,
                  cycleLength: cycleInfo.cycleLength,
                  periodLength: cycleInfo.periodLength,
                  phaseName: _localizedPhaseName(result),
                  phaseIcon: result.phaseIcon,
                  imagePath: _getHomeImage(
                    cycleInfo: cycleInfo,
                    result: result,
                  ),
                  onPhaseChanged: (details) {
                    setState(() {
                      _selectedPhaseDetails = details == null
                          ? null
                          : _localizedPhaseDetails(details);
                    });
                  },
                ),
              ),
            ),
          ),
          if (_selectedPhaseDetails != null)
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: _buildPhaseTooltip(_selectedPhaseDetails!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhaseTooltip(CyclePhaseDetails details) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 132,
        maxWidth: 175,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFECE4F5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            details.icon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2733),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details.dayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7657A8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatusCard({
    required CycleResult result,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFECE4F5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE5F7),
              shape: BoxShape.circle,
            ),
            child: Text(
              result.phaseIcon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _l10n.homeTodayStatus,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B8490),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentPhaseTitle(result),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2733),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentDayText(result),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7657A8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentPhaseDescription(result),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.2,
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

  String _localizedPhaseName(CycleResult result) {
    switch (result.phase) {
      case CyclePhase.menstruation:
        return _l10n.homePhaseMenstruationName;
      case CyclePhase.renewal:
        return _l10n.homePhaseRenewalName;
      case CyclePhase.fertile:
        return _l10n.homePhaseFertileName;
      case CyclePhase.pms:
        return _l10n.homePhasePmsName;
      case CyclePhase.rest:
        return _l10n.homePhaseRestName;
    }
  }

  CyclePhaseDetails _localizedPhaseDetails(CyclePhaseDetails details) {
    final dayNumbers = RegExp(r'\d+')
        .allMatches(details.dayText)
        .map((match) => int.parse(match.group(0)!))
        .toList();

    final String title;
    final String description;

    switch (details.icon) {
      case '🩸':
        title = _l10n.homePhaseMenstruationName;
        description = _l10n.homeTooltipMenstruationDescription;
        break;
      case '🌱':
        title = _l10n.homePhaseRenewalName;
        description = _l10n.homeTooltipRenewalDescription;
        break;
      case '🌸':
        title = _l10n.homePhaseFertileName;
        description = _l10n.homeTooltipFertileDescription;
        break;
      case '💤':
        title = _l10n.homePhaseRestPmsName;
        description = _l10n.homeTooltipRestPmsDescription;
        break;
      default:
        title = details.title;
        description = details.description;
    }

    String dayText = details.dayText;

    if (dayNumbers.length == 1) {
      dayText = _formatCycleDay(dayNumbers.first);
    } else if (dayNumbers.length >= 2) {
      dayText = _formatCycleDayRange(
        dayNumbers.first,
        dayNumbers[1],
      );
    }

    return CyclePhaseDetails(
      title: title,
      description: description,
      dayText: dayText,
      icon: details.icon,
    );
  }

  String _currentPhaseTitle(CycleResult result) {
    switch (result.phase) {
      case CyclePhase.menstruation:
        return _l10n.homePhaseMenstruationTitle;
      case CyclePhase.renewal:
        return _l10n.homePhaseRenewalTitle;
      case CyclePhase.fertile:
        return _l10n.homePhaseFertileTitle;
      case CyclePhase.pms:
        return _l10n.homePhasePmsTitle;
      case CyclePhase.rest:
        return _l10n.homePhaseRestTitle;
    }
  }

  String _currentDayText(CycleResult result) {
    if (result.phase == CyclePhase.menstruation) {
      return _formatPeriodDay(result.cycleDay);
    }

    return _formatCycleDay(result.cycleDay);
  }

  String _formatPeriodDay(int day) {
    if (_isTurkish) {
      return '$day. ${_l10n.homePeriodDayLabel}';
    }

    return '${_l10n.homePeriodDayLabel} $day';
  }

  String _formatCycleDay(int day) {
    if (_isTurkish) {
      return '$day. ${_l10n.homeCycleDayLabel}';
    }

    return '${_l10n.homeCycleDayLabel} $day';
  }

  String _formatCycleDayRange(int startDay, int endDay) {
    if (_isTurkish) {
      return '$startDay–$endDay. ${_l10n.homeCycleDaysLabel}';
    }

    return '${_l10n.homeCycleDaysLabel} $startDay–$endDay';
  }

  String _currentPhaseDescription(CycleResult result) {
    switch (result.phase) {
      case CyclePhase.menstruation:
        return _l10n.homePhaseMenstruationDescription;
      case CyclePhase.renewal:
        return _l10n.homePhaseRenewalDescription;
      case CyclePhase.fertile:
        return _l10n.homePhaseFertileDescription;
      case CyclePhase.pms:
        return _l10n.homePhasePmsDescription;
      case CyclePhase.rest:
        return _l10n.homePhaseRestDescription;
    }
  }

  Widget _buildCompactCycleInfoCard({
    required CycleInfo cycleInfo,
    required CycleResult result,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactInfoRow(
            icon: Icons.calendar_month_rounded,
            iconBackgroundColor: const Color(0xFFFCE6EF),
            iconColor: const Color(0xFFE34D87),
            label: _l10n.homeNextPeriod,
            value: _nextPeriodText(result.daysUntilNextPeriod),
            trailingText: _formatDate(result.nextPeriodDate),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            endIndent: 16,
            color: Color(0xFFF1EDF4),
          ),
          _buildCompactInfoRow(
            icon: Icons.bar_chart_rounded,
            iconBackgroundColor: const Color(0xFFEFE8FA),
            iconColor: const Color(0xFF7657A8),
            label: _l10n.homeCycleInfo,
            value:
                '${cycleInfo.cycleLength} ${_l10n.homeCycleLengthSuffix}',
            trailingText:
                '${_l10n.homePeriodShortLabel} '
                '${cycleInfo.periodLength} '
                '${cycleInfo.periodLength == 1 ? _l10n.daySingular : _l10n.dayPlural}',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String label,
    required String value,
    required String trailingText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B8490),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2733),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 112),
            child: Text(
              trailingText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9A939F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _l10n.homeLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _reloadData,
              child: Text(_l10n.homeRetry),
            ),
          ],
        ),
      ),
    );
  }

  String _nextPeriodText(int days) {
    if (days == 0) {
      return _l10n.homePeriodExpectedToday;
    }

    if (days == 1) {
      return _l10n.homeOneDayLeft;
    }

    return '$days ${_l10n.homeDaysLeftSuffix}';
  }

  String _formatDate(DateTime date) {
    final months = [
      _l10n.month1,
      _l10n.month2,
      _l10n.month3,
      _l10n.month4,
      _l10n.month5,
      _l10n.month6,
      _l10n.month7,
      _l10n.month8,
      _l10n.month9,
      _l10n.month10,
      _l10n.month11,
      _l10n.month12,
    ];

    final month = months[date.month - 1];

    if (_isTurkish) {
      return '${date.day} $month ${date.year}';
    }

    return '$month ${date.day}, ${date.year}';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
