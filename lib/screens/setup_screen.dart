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
  bool _hasReadInformation = false;
  bool _isSaving = false;

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
    if (!_hasReadInformation || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgiler kaydedilemedi. Lütfen tekrar dene.'),
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
        child: SingleChildScrollView(
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
                          'Bu bilgiler kişisel döngü tahminleri oluşturmak için kullanılır.',
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
              const SizedBox(height: 28),
              _SectionTitle(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                title: 'Son Regl Başlangıcı',
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
                    border: Border.all(color: AppColors.border),
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
              const SizedBox(height: 24),
              _SectionTitle(
                icon: Icons.water_drop_rounded,
                iconColor: AppColors.period,
                title: 'Regl Süresi',
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
              const SizedBox(height: 24),
              _SectionTitle(
                icon: Icons.autorenew_rounded,
                iconColor: AppColors.cycle,
                title: 'Ortalama Döngü',
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
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDCD2F7)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Luna tarafından gösterilen regl, PMS, doğurgan dönem ve yumurtlama tarihleri tahminidir. Tıbbi tavsiye yerine geçmez ve gebelikten korunma yöntemi olarak kullanılmamalıdır.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF5F5574),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _hasReadInformation,
                onChanged: (value) {
                  setState(() {
                    _hasReadInformation = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Bilgilendirmeyi okudum ve anladım.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _hasReadInformation && !_isSaving
                      ? _completeSetup
                      : null,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Başla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
