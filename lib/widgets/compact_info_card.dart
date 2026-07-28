import 'package:flutter/material.dart';
import 'package:within/l10n/app_localizations.dart';

class CompactCycleInfoCard extends StatelessWidget {
  const CompactCycleInfoCard({
    super.key,
    required this.daysUntilNextPeriod,
    required this.nextPeriodDate,
    required this.cycleLength,
    required this.periodLength,
    this.onNextPeriodTap,
    this.onCycleInfoTap,
  });

  final int daysUntilNextPeriod;
  final String nextPeriodDate;
  final int cycleLength;
  final int periodLength;
  final VoidCallback? onNextPeriodTap;
  final VoidCallback? onCycleInfoTap;

  String _daysUntilNextPeriodText(AppLocalizations l10n) {
    if (daysUntilNextPeriod <= 0) {
      return l10n.homePeriodExpectedToday;
    }

    if (daysUntilNextPeriod == 1) {
      return l10n.homeOneDayLeft;
    }

    return '$daysUntilNextPeriod ${l10n.homeDaysLeftSuffix}';
  }

  String _periodLengthText(AppLocalizations l10n) {
    final dayLabel = periodLength == 1
        ? l10n.daySingular.toLowerCase()
        : l10n.dayPlural.toLowerCase();

    return '${l10n.homePeriodShortLabel} $periodLength $dayLabel';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          _CompactInfoRow(
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFFE85D91),
            iconBackgroundColor: const Color(0xFFFCE7F0),
            label: l10n.homeNextPeriod,
            title: _daysUntilNextPeriodText(l10n),
            trailingText: nextPeriodDate,
            onTap: onNextPeriodTap,
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: 72,
            endIndent: 16,
            color: Color(0xFFF1EEF3),
          ),
          _CompactInfoRow(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF7654C3),
            iconBackgroundColor: const Color(0xFFEFE8FC),
            label: l10n.homeCycleInfo,
            title: '$cycleLength ${l10n.homeCycleLengthSuffix}',
            trailingText: _periodLengthText(l10n),
            onTap: onCycleInfoTap,
          ),
        ],
      ),
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  const _CompactInfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.title,
    required this.trailingText,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final String title;
  final String trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isNarrowScreen = MediaQuery.sizeOf(context).width < 370;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 12 : 14,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: isNarrowScreen ? 38 : 42,
                height: isNarrowScreen ? 38 : 42,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isNarrowScreen ? 20 : 22,
                  color: iconColor,
                ),
              ),
              SizedBox(width: isNarrowScreen ? 10 : 12),
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
                        color: Color(0xFF99929F),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF342D3D),
                        fontSize: isNarrowScreen ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isNarrowScreen ? 82 : 105,
                ),
                child: Text(
                  trailingText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF99929F),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: Color(0xFFAAA4AF),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
