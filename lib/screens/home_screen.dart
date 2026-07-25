import 'calendar_screen.dart';
import 'package:flutter/material.dart';

import '../models/cycle_info.dart';
import '../models/period_record.dart';
import '../services/cycle_calculator.dart';
import '../services/storage_service.dart';
import '../widgets/cycle_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

            final today = DateTime.now();
            final normalizedToday = DateTime(today.year, today.month, today.day);

            final relevantRecord = CycleCalculator.findLastRecordBefore(
              normalizedToday,
              actualRecords,
            );

            DateTime lastPeriodDate;
            int periodLength = fallbackPeriodLength;
            int cycleLength = fallbackCycleLength;

            if (relevantRecord != null) {
              lastPeriodDate = relevantRecord.startDate;
              periodLength = relevantRecord.periodLength;
            } else if (actualRecords.isNotEmpty) {
              final sorted = [...actualRecords]
                ..sort((a, b) => a.startDate.compareTo(b.startDate));
              lastPeriodDate = sorted.first.startDate;
            } else {
              lastPeriodDate = normalizedToday.subtract(const Duration(days: 14));
            }

            final cycleInfo = CycleInfo(
              lastPeriodDate: lastPeriodDate,
              periodLength: periodLength,
              cycleLength: cycleLength,
            );

            final result = CycleCalculator.calculate(
              cycleInfo,
              currentDate: normalizedToday,
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

  Widget _buildHomeContent({
    required CycleInfo cycleInfo,
    required CycleResult result,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Luna’ya hoş geldin',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2733),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bugünkü durumun',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF77707E),
            ),
          ),
          const SizedBox(height: 22),
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                );
                if (mounted) {
                  _reloadData();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7657A8),
                side: const BorderSide(
                  color: Color(0xFF7657A8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Takvimi Görüntüle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}