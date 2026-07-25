import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import 'app_start_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  AppSettings _settings = const AppSettings();

  bool _isLoading = true;
  bool _isResetting = false;

  static const Color _primaryPurple = Color(0xFF7C5CE7);
  static const Color _darkPurple = Color(0xFF382C62);
  static const Color _backgroundColor = Color(0xFFF8F6FF);
  static const Color _borderColor = Color(0xFFECE7FA);
  static const Color _dangerColor = Color(0xFFD74B62);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.loadSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ayarlar yüklenirken bir hata oluştu.',
          ),
        ),
      );
    }
  }

  Future<void> _selectCycleLength() async {
    final selectedValue = await _showNumberPicker(
      title: 'Ortalama döngü uzunluğu',
      description:
          'Luna, bir sonraki regl tarihini tahmin ederken bu değeri kullanır.',
      currentValue: _settings.averageCycleLength,
      minimumValue: 21,
      maximumValue: 45,
    );

    if (selectedValue == null ||
        selectedValue == _settings.averageCycleLength) {
      return;
    }

    final previousSettings = _settings;

    final updatedSettings = _settings.copyWith(
      averageCycleLength: selectedValue,
    );

    setState(() {
      _settings = updatedSettings;
    });

    try {
      await _settingsService.saveSettings(updatedSettings);

      // Keep the existing cycle calculation settings synchronized.
      await StorageService.saveCycleLength(selectedValue);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _settings = previousSettings;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Döngü uzunluğu kaydedilemedi.',
          ),
        ),
      );
    }
  }

  Future<void> _selectPeriodLength() async {
    final selectedValue = await _showNumberPicker(
      title: 'Tahmini regl süresi',
      description:
          'Devam eden kayıtlar ve gelecek regl tahminleri için kullanılacak varsayılan süre.',
      currentValue: _settings.predictedPeriodLength,
      minimumValue: 1,
      maximumValue: 15,
    );

    if (selectedValue == null ||
        selectedValue == _settings.predictedPeriodLength) {
      return;
    }

    final previousSettings = _settings;

    final updatedSettings = _settings.copyWith(
      predictedPeriodLength: selectedValue,
    );

    setState(() {
      _settings = updatedSettings;
    });

    try {
      await _settingsService.saveSettings(updatedSettings);

      // Keep the existing period calculation settings synchronized.
      await StorageService.savePeriodLength(selectedValue);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _settings = previousSettings;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Regl süresi kaydedilemedi.',
          ),
        ),
      );
    }
  }

  Future<int?> _showNumberPicker({
    required String title,
    required String description,
    required int currentValue,
    required int minimumValue,
    required int maximumValue,
  }) {
    int selectedValue = currentValue;

    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D2E8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: _darkPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Color(0xFF786F8E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 250,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 52,
                        diameterRatio: 1.5,
                        perspective: 0.002,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: currentValue - minimumValue,
                        ),
                        onSelectedItemChanged: (index) {
                          setModalState(() {
                            selectedValue = minimumValue + index;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount:
                              maximumValue - minimumValue + 1,
                          builder: (context, index) {
                            final value = minimumValue + index;
                            final isSelected =
                                value == selectedValue;

                            return Center(
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 180),
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _primaryPurple.withValues(
                                          alpha: 0.10,
                                        )
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    '$value gün',
                                    style: TextStyle(
                                      fontSize:
                                          isSelected ? 21 : 17,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? _primaryPurple
                                          : const Color(
                                              0xFF8D859E,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop(
                            selectedValue,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showResetConfirmation() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Luna sıfırlansın mı?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _darkPurple,
            ),
          ),
          content: const Text(
            'Tüm regl kayıtların ve döngü ayarların kalıcı olarak silinecek.\n\n'
            'Bu işlem geri alınamaz.',
            style: TextStyle(
              height: 1.45,
              color: Color(0xFF675F78),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Vazgeç',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Tümünü Sil',
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset != true || !mounted) {
      return;
    }

    await _resetApplication();
  }

  Future<void> _resetApplication() async {
    setState(() {
      _isResetting = true;
    });

    try {
      await StorageService.clearAllData();
      await _settingsService.resetSettings();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AppStartScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veriler silinirken bir hata oluştu. Lütfen tekrar dene.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: _primaryPurple,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ayarlar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _darkPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Döngü ayarlarını düzenleyebilir, gizlilik bilgilerine erişebilir ve verilerini yönetebilirsin.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF786F8E),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SettingsSection(
                      title: 'Döngü',
                      icon: Icons.autorenew_rounded,
                      children: [
                        _SettingsTile(
                          title: 'Ortalama döngü uzunluğu',
                          subtitle:
                              '${_settings.averageCycleLength} gün',
                          icon: Icons.calendar_month_outlined,
                          onTap: _selectCycleLength,
                        ),
                        const _SettingsDivider(),
                        _SettingsTile(
                          title: 'Tahmini regl süresi',
                          subtitle:
                              '${_settings.predictedPeriodLength} gün',
                          icon: Icons.water_drop_outlined,
                          onTap: _selectPeriodLength,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SettingsSection(
                      title: 'Gizlilik',
                      icon: Icons.lock_outline_rounded,
                      children: [
                        _SettingsTile(
                          title: 'Gizlilik Politikası',
                          subtitle:
                              'Verilerinin nasıl saklandığını öğren',
                          icon: Icons.privacy_tip_outlined,
                          onTap: _openPrivacyPolicy,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SettingsSection(
                      title: 'Veriler',
                      icon: Icons.storage_outlined,
                      children: [
                        _SettingsTile(
                          title: 'Tüm Verileri Sıfırla',
                          subtitle:
                              'Regl geçmişini ve ayarları kalıcı olarak sil',
                          icon: Icons.delete_outline_rounded,
                          titleColor: _dangerColor,
                          iconColor: _dangerColor,
                          isLoading: _isResetting,
                          onTap: _isResetting
                              ? null
                              : _showResetConfirmation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _SettingsScreenState._borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              10,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _SettingsScreenState._primaryPurple
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color:
                        _SettingsScreenState._primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        _SettingsScreenState._darkPurple,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: _SettingsScreenState._borderColor,
            ),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool isLoading;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 23,
              color: iconColor ??
                  _SettingsScreenState._primaryPurple,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ??
                          const Color(0xFF514866),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF81798F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _SettingsScreenState._dangerColor,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFAAA3B8),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        left: 53,
        right: 16,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: _SettingsScreenState._borderColor,
      ),
    );
  }
}