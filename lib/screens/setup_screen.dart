import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:within/l10n/app_localizations.dart';

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
  bool _isButtonPressed = false;

  String _monthName(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context)!;

    switch (month) {
      case 1:
        return l10n.month1;
      case 2:
        return l10n.month2;
      case 3:
        return l10n.month3;
      case 4:
        return l10n.month4;
      case 5:
        return l10n.month5;
      case 6:
        return l10n.month6;
      case 7:
        return l10n.month7;
      case 8:
        return l10n.month8;
      case 9:
        return l10n.month9;
      case 10:
        return l10n.month10;
      case 11:
        return l10n.month11;
      case 12:
        return l10n.month12;
      default:
        return '';
    }
  }

  String _formattedDate(BuildContext context) {
    return '${_lastPeriodDate.day} '
        '${_monthName(context, _lastPeriodDate.month)} '
        '${_lastPeriodDate.year}';
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    setState(() {
      _lastPeriodDate = pickedDate;
    });
  }

  Future<void> _completeSetup() async {
    if (!_hasReadInformation || _isSaving) {
      return;
    }

    await HapticFeedback.lightImpact();

    if (!mounted) {
      return;
    }

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
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.saveFailed,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canStart = _hasReadInformation && !_isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShortScreen = constraints.maxHeight < 700;
            final isNarrowScreen = constraints.maxWidth < 360;
            final horizontalPadding = isNarrowScreen ? 16.0 : 24.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isShortScreen ? 8 : 12,
                horizontalPadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SetupHeader(),
                  SizedBox(height: isShortScreen ? 4 : 6),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      isNarrowScreen ? 16 : 20,
                      isShortScreen ? 16 : 18,
                      isNarrowScreen ? 16 : 20,
                      isShortScreen ? 16 : 20,
                    ),
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            icon: Icons.calendar_today_rounded,
                            iconColor: AppColors.primary,
                            title: l10n.lastPeriodStart,
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
                                      _formattedDate(context),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
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
                      SizedBox(height: isShortScreen ? 14 : 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            icon: Icons.water_drop_rounded,
                            iconColor: AppColors.period,
                            title: l10n.periodDuration,
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
                      SizedBox(height: isShortScreen ? 14 : 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            icon: Icons.autorenew_rounded,
                            iconColor: AppColors.cycle,
                            title: l10n.averageCycle,
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
                      SizedBox(height: isShortScreen ? 14 : 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF6842A5),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.setupDisclaimer,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  height: 1.35,
                                  color: Color(0xFF574675),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isShortScreen ? 14 : 18),
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
                            title: Text(
                              l10n.disclaimerAccepted,
                              style: const TextStyle(
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
                                if (!canStart || _isSaving) {
                                  return;
                                }

                                setState(() {
                                  _isButtonPressed = true;
                                });
                              },
                              onPointerUp: (_) {
                                if (!_isButtonPressed) {
                                  return;
                                }

                                setState(() {
                                  _isButtonPressed = false;
                                });
                              },
                              onPointerCancel: (_) {
                                if (!_isButtonPressed) {
                                  return;
                                }

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
                                            _isButtonPressed || _isSaving
                                                ? 10
                                                : 20,
                                        spreadRadius:
                                            _isButtonPressed ? 0 : 1,
                                        offset: Offset(
                                          0,
                                          _isButtonPressed ? 4 : 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: FilledButton(
                                    onPressed:
                                        canStart ? _completeSetup : null,
                                    style: ButtonStyle(
                                      elevation:
                                          const WidgetStatePropertyAll(0),
                                      shadowColor:
                                          const WidgetStatePropertyAll(
                                        Colors.transparent,
                                      ),
                                      foregroundColor:
                                          const WidgetStatePropertyAll(
                                        Colors.white,
                                      ),
                                      backgroundColor:
                                          WidgetStateProperty.resolveWith<Color>(
                                        (states) {
                                          if (_isSaving) {
                                            return const Color(0xFF57358D);
                                          }

                                          if (!canStart) {
                                            return const Color(0xFFC7B9E5);
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
                                          WidgetStateProperty.resolveWith<
                                              Color?>((states) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return Colors.white.withValues(
                                            alpha: 0.10,
                                          );
                                        }

                                        return null;
                                      }),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeIn,
                                      child: _isSaving
                                          ? Row(
                                              key: const ValueKey('loading'),
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  l10n.setupSaving,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              l10n.setupStart,
                                              key: const ValueKey('buttonText'),
                                              style: const TextStyle(
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
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowScreen = constraints.maxWidth < 340;
        final imageSize = isNarrowScreen ? 88.0 : 104.0;

        return Padding(
          padding: const EdgeInsets.only(
            top: 4,
            bottom: 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.setupTitle,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: isNarrowScreen ? 23 : 26,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF342A49),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.setupDescription,
                      style: TextStyle(
                        fontSize: isNarrowScreen ? 12 : 13,
                        height: 1.35,
                        color: const Color(0xFF655C75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: Image.asset(
                  'assets/images/Within_head.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        );
      },
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
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF342A49),
                ),
          ),
        ),
      ],
    );
  }
}
