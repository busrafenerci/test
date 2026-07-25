import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/number_picker.dart';
import 'main_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  DateTime _lastPeriodDate = DateTime.now();
  int _periodLength = 4;
  int _cycleLength = 28;

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _lastPeriodDate = pickedDate;
      });
    }
  }

  Future<void> _completeSetup() async {
  await StorageService.saveLastPeriodDate(_lastPeriodDate);
  await StorageService.savePeriodLength(_periodLength);
  await StorageService.saveCycleLength(_cycleLength);
  await StorageService.setSetupCompleted(true);

  if (!mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const MainScreen(),
    ),
    (route) => false,
  );
}

  String get formattedDate {
    const months = [
      '',
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

    return '${_lastPeriodDate.day} '
        '${months[_lastPeriodDate.month]} '
        '${_lastPeriodDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bilgilerini Ekleyelim',
                          style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: 27),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bu bilgiler yalnızca tahmin yapmak için kullanılır.',
                            style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/images/luna_home.png',
                    height: 78,
                    width: 78,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Son Regl Başlangıcı',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    size: 20,
                    color: AppColors.period,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Regl Süresi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              NumberPicker(
                value: _periodLength,
                minValue: 1,
                maxValue: 15,
                color: AppColors.period,
                backgroundColor: AppColors.periodBackground,
                onChanged: (value) {
                  setState(() {
                    _periodLength = value;
                  });
                },
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Icon(
                    Icons.autorenew_rounded,
                    size: 20,
                    color: AppColors.cycle,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ortalama Döngü',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              NumberPicker(
                value: _cycleLength,
                minValue: 21,
                maxValue: 45,
                color: AppColors.cycle,
                backgroundColor: AppColors.cycleBackground,
                onChanged: (value) {
                  setState(() {
                    _cycleLength = value;
                  });
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _completeSetup,
                  child: const Text('Başla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}