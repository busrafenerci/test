import 'package:flutter/material.dart';

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
    setState(_loadData);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            cycleInfo: cycleInfo,
            result: result,
          ),
          const SizedBox(height: 18),
          _buildCycleCard(result, cycleInfo),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Sonraki regl',
            value: _nextPeriodText(result.daysUntilNextPeriod),
            subtitle: _formatDate(result.nextPeriodDate),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Döngü bilgilerin',
            value: '${cycleInfo.cycleLength} günlük döngü',
            subtitle: 'Ortalama regl süresi: ${cycleInfo.periodLength} gün',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required CycleInfo cycleInfo,
    required CycleResult result,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Luna’ya hoş geldin',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2733),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bugünkü durumun',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF77707E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 104,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDE5F7),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7657A8)
                          .withValues(alpha: 0.08),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Image.asset(
                  _getHomeImage(
                    cycleInfo: cycleInfo,
                    result: result,
                  ),
                  width: 100,
                  height: 94,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getHomeImage({
    required CycleInfo cycleInfo,
    required CycleResult result,
  }) {
    final ovulationDay = cycleInfo.cycleLength - 14;

    if (result.phase == CyclePhase.menstruation) {
      return 'assets/images/luna_home_period.png';
    }

    if (result.cycleDay == ovulationDay) {
      return 'assets/images/luna_home_ovulation.png';
    }

    if (result.phase == CyclePhase.fertile) {
      return 'assets/images/luna_home_fertile.png';
    }

    if (result.phase == CyclePhase.pms) {
      return 'assets/images/luna_home_pms.png';
    }

    return 'assets/images/luna_home_default.png';
  }

  Widget _buildCycleCard(
    CycleResult result,
    CycleInfo cycleInfo,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
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
      child: Center(
        child: CycleRing(
          cycleDay: result.cycleDay,
          cycleLength: cycleInfo.cycleLength,
          periodLength: cycleInfo.periodLength,
          phaseName: result.phaseName,
          phaseIcon: result.phaseIcon,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF77707E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2733),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9A939F),
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
            const Text(
              'Bilgiler yüklenirken bir hata oluştu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _reloadData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  String _nextPeriodText(int days) {
    if (days == 0) {
      return 'Bugün başlaması bekleniyor';
    }

    if (days == 1) {
      return '1 gün kaldı';
    }

    return '$days gün kaldı';
  }

  String _formatDate(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
