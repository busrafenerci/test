import 'package:flutter/material.dart';
import 'package:within/l10n/app_localizations.dart';

import '../theme/app_colors.dart';

class NumberPicker extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final Color color;
  final Color backgroundColor;
  final String? suffix;
  final String Function(int value)? valueFormatter;

  const NumberPicker({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.primaryLight,
    this.suffix,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final canDecrease = value > minValue;
    final canIncrease = value < maxValue;

    final localizedSuffix = suffix ??
        (value == 1
            ? l10n.daySingular
            : l10n.dayPlural);

    final displayValue =
        valueFormatter?.call(value) ?? '$value $localizedSuffix';

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              onPressed: canDecrease
                  ? () => onChanged(value - 1)
                  : null,
              icon: const Icon(Icons.remove_rounded),
              iconSize: 28,
              color: color,
              disabledColor: color.withValues(alpha: 0.3),
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: AppColors.border,
          ),
          Expanded(
            flex: 2,
            child: Text(
              displayValue,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: AppColors.border,
          ),
          Expanded(
            child: IconButton(
              onPressed: canIncrease
                  ? () => onChanged(value + 1)
                  : null,
              icon: const Icon(Icons.add_rounded),
              iconSize: 28,
              color: color,
              disabledColor: color.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}