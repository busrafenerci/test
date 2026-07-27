import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/number_picker.dart';
import 'main_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  DateTime _lastPeriodDate = DateTime.now();
  int _periodLength = 4;
  int _cycleLength = 28;
  bool _hasReadInformation = false;
  bool _isSaving = false;
  bool _isButtonPressed = false;

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

    await HapticFeedback.lightImpact();

    setState(() {
      _isSaving = true;
      _isButtonPressed = false;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 250),
    );

    try {
      await StorageService.saveLastPeriodDate(_lastPeriodDate);
      await StorageService.savePeriodLength(_periodLength);
      await StorageService.saveCycleLength(_cycleLength);
      await StorageService.setSetupCompleted(true);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

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
    final canStart = _hasReadInformation && !_isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SetupHeader(),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.045),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: Icons.calendar_today_rounded,
                            iconColor: AppColors.primary,
                            title: 'Son Regl Başlangıcı',
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _selectDate,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
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
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: Icons.water_drop_rounded,
                            iconColor: AppColors.period,
                            title: 'Regl Süresi',
                          ),
                          const SizedBox(height: 10),
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
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: Icons.autorenew_rounded,
                            iconColor: AppColors.cycle,
                            title: 'Ortalama Döngü',
                          ),
                          const SizedBox(height: 10),
                          NumberPicker(
                            value: _cycleLength,
                            minValue: 10,
                            maxValue: 45,
                            color: AppColors.cycle,
                            backgroundColor: AppColors.cycleBackground,
                            onChanged: (value) {
                              setState(() {
                                _cycleLength = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF6842A5),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Luna tarafından gösterilen regl, PMS, doğurgan dönem ve yumurtlama tarihleri tahminidir. Tıbbi tavsiye yerine geçmez ve gebelikten korunma yöntemi olarak kullanılmamalıdır.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.35,
                                  color: Color(0xFF574675),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          CheckboxListTile(
                            value: _hasReadInformation,
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      _hasReadInformation = value ?? false;
                                    });
                                  },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            horizontalTitleGap: 8,
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'Bilgilendirmeyi okudum ve anladım.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedOpacity(
                            opacity: canStart || _isSaving ? 1 : 0.7,
                            duration: const Duration(milliseconds: 180),
                            child: Listener(
                              onPointerDown: (_) {
                                if (!canStart || _isSaving) return;
                                setState(() {
                                  _isButtonPressed = true;
                                });
                              },
                              onPointerUp: (_) {
                                if (!_isButtonPressed) return;
                                setState(() {
                                  _isButtonPressed = false;
                                });
                              },
                              onPointerCancel: (_) {
                                if (!_isButtonPressed) return;
                                setState(() {
                                  _isButtonPressed = false;
                                });
                              },
                              child: AnimatedScale(
                                scale: _isButtonPressed
                                    ? 0.965
                                    : _isSaving
                                        ? 0.98
                                        : 1,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeOutCubic,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: canStart
                                            ? (_isButtonPressed || _isSaving
                                                ? const Color(0x356842A5)
                                                : const Color(0x596842A5))
                                            : Colors.transparent,
                                        blurRadius:
                                            _isButtonPressed || _isSaving ? 10 : 20,
                                        spreadRadius: _isButtonPressed ? 0 : 1,
                                        offset: Offset(
                                          0,
                                          _isButtonPressed ? 4 : 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: FilledButton(
                                    onPressed: canStart ? _completeSetup : null,
                                    style: ButtonStyle(
                                      elevation: const WidgetStatePropertyAll(0),
                                      shadowColor: const WidgetStatePropertyAll(
                                        Colors.transparent,
                                      ),
                                      foregroundColor:
                                          const WidgetStatePropertyAll(
                                        Colors.white,
                                      ),
                                      backgroundColor:
                                          WidgetStateProperty.resolveWith<Color>(
                                        (states) {
                                          if (!canStart) {
                                            return const Color(0xFFC7B9E5);
                                          }
                                          if (_isSaving) {
                                            return const Color(0xFF57358D);
                                          }
                                          if (states.contains(
                                            WidgetState.pressed,
                                          )) {
                                            return const Color(0xFF59388F);
                                          }
                                          return const Color(0xFF6842A5);
                                        },
                                      ),
                                      overlayColor:
                                          WidgetStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(
                                            WidgetState.pressed,
                                          )) {
                                            return Colors.white.withValues(
                                              alpha: 0.10,
                                            );
                                          }
                                          return null;
                                        },
                                      ),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 160),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeIn,
                                      child: _isSaving
                                          ? const Row(
                                              key: ValueKey('loading'),
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Kaydediliyor...',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Text(
                                              'Başla',
                                              key: ValueKey('buttonText'),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seni Tanıyalım',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF342A49),
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bu bilgiler kişisel döngü tahminleri oluşturmak için kullanılır.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF655C75),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const _LunaHeaderPortrait(),
      ],
    );
  }
}

class _LunaHeaderPortrait extends StatelessWidget {
  const _LunaHeaderPortrait();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33EEE4FF),
                Color(0x777A4CC5),
              ],
            ),
          ),
          child: Image.asset(
            'assets/images/luna_head.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF342A49),
              ),
        ),
      ],
    );
  }
}