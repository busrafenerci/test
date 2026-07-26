import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
            label: 'Sonraki regl',
            title: '$daysUntilNextPeriod gün kaldı',
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
            label: 'Döngü bilgilerin',
            title: '$cycleLength günlük döngü',
            trailingText: 'Regl: $periodLength gün',
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor,
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
                        color: Color(0xFF99929F),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF342D3D),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 105,
                ),
                child: Text(
                  trailingText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF99929F),
                    fontSize: 11,
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