import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class CyclePhaseDetails {
  final String title;
  final String description;
  final String dayText;
  final String icon;

  const CyclePhaseDetails({
    required this.title,
    required this.description,
    required this.dayText,
    required this.icon,
  });
}

class CycleRing extends StatefulWidget {
  final int cycleDay;
  final int cycleLength;
  final int periodLength;
  final String phaseName;
  final String phaseIcon;
  final String imagePath;
  final ValueChanged<CyclePhaseDetails?>? onPhaseChanged;

  const CycleRing({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    required this.periodLength,
    required this.phaseName,
    required this.phaseIcon,
    required this.imagePath,
    this.onPhaseChanged,
  });

  @override
  State<CycleRing> createState() => _CycleRingState();
}

class _CycleRingState extends State<CycleRing> {
  static const double _widgetSize = 300;
  static const double _paintSize = 246;
  static const double _tooltipWidth = 132;
  static const double _tooltipHeight = 44;
  static const Duration _tooltipDuration = Duration(milliseconds: 1800);

  static const Offset _ringCenter = Offset(
    _widgetSize / 2,
    _widgetSize / 2,
  );

  static const double _ringRadius = _paintSize / 2 - 12;

  _PhaseSegment? _selectedPhase;
  Offset? _selectedIconCenter;
  Timer? _tooltipTimer;

  List<_PhaseSegment> _phaseSegments() {
    final safeCycleLength = math.max(1, widget.cycleLength);
    final menstruationDays = widget.periodLength.clamp(1, safeCycleLength);

    const fertileDays = 6;

    final renewalDays = math.max(
      1,
      safeCycleLength - menstruationDays - fertileDays - 10,
    ).toInt();

    final restDays = math.max(
      1,
      safeCycleLength - menstruationDays - fertileDays - renewalDays,
    ).toInt();

    return [
      _PhaseSegment(
        title: 'Regl dönemi',
        description: 'Kanama ve vücudun yenilenme sürecinin başlangıcı.',
        emoji: '🩸',
        materialIcon: Icons.water_drop_rounded,
        color: const Color(0xFFE56B8A),
        startDay: 1,
        dayCount: menstruationDays,
      ),
      _PhaseSegment(
        title: 'Yenilenme dönemi',
        description: 'Enerjinin ve östrojenin yükseldiği dinamik dönem.',
        emoji: '🌱',
        materialIcon: Icons.spa_rounded,
        color: const Color(0xFF70B982),
        startDay: menstruationDays + 1,
        dayCount: renewalDays,
      ),
      _PhaseSegment(
        title: 'Verimli dönem',
        description:
            'Doğurganlığın yükseldiği ve yumurtlamanın yaklaştığı dönem.',
        emoji: '🌸',
        materialIcon: Icons.local_florist_rounded,
        color: const Color(0xFFD8A91D),
        startDay: menstruationDays + renewalDays + 1,
        dayCount: fertileDays,
      ),
      _PhaseSegment(
        title: 'Dinlenme / PMS',
        description: 'Regl öncesi sakinleşme ve dinlenme evresi.',
        emoji: '💤',
        materialIcon: Icons.bedtime_rounded,
        color: const Color(0xFF8F73C8),
        startDay: menstruationDays + renewalDays + fertileDays + 1,
        dayCount: restDays,
      ),
    ];
  }

  Offset _iconCenterForPhase(_PhaseSegment phase) {
    final safeCycleLength = math.max(1, widget.cycleLength);
    final middleDay = phase.startDay + (phase.dayCount - 1) / 2;

    final angle = -math.pi / 2 +
        ((middleDay - 1) / safeCycleLength) * math.pi * 2;

    final iconRadius = _ringRadius + 26;

    return Offset(
      _ringCenter.dx + math.cos(angle) * iconRadius,
      _ringCenter.dy + math.sin(angle) * iconRadius,
    );
  }

  void _selectPhase(_PhaseSegment phase) {
    _tooltipTimer?.cancel();

    setState(() {
      _selectedPhase = phase;
      _selectedIconCenter = _iconCenterForPhase(phase);
    });

    // The callback is intentionally not triggered here. The phase information
    // is now displayed inside CycleRing, so the HomeScreen status card remains
    // unchanged when a ring segment is tapped.

    _tooltipTimer = Timer(_tooltipDuration, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedPhase = null;
        _selectedIconCenter = null;
      });
    });
  }

  void _handleRingTap(Offset localPosition) {
    final distanceFromCenter = (localPosition - _ringCenter).distance;

    // Ignore taps on the illustration in the middle or far outside the ring.
    if (distanceFromCenter < _ringRadius - 24 ||
        distanceFromCenter > _ringRadius + 28) {
      return;
    }

    final angle = math.atan2(
      localPosition.dy - _ringCenter.dy,
      localPosition.dx - _ringCenter.dx,
    );

    double normalizedAngle = (angle + math.pi / 2) % (math.pi * 2);

    if (normalizedAngle < 0) {
      normalizedAngle += math.pi * 2;
    }

    final safeCycleLength = math.max(1, widget.cycleLength);
    final tappedDay =
        ((normalizedAngle / (math.pi * 2)) * safeCycleLength).floor() + 1;

    final phases = _phaseSegments();
    final selectedPhase = phases.firstWhere(
      (phase) {
        final endDay = phase.startDay + phase.dayCount - 1;
        return tappedDay >= phase.startDay && tappedDay <= endDay;
      },
      orElse: () => phases.last,
    );

    _selectPhase(selectedPhase);
  }

  Rect _tooltipRect(Offset iconCenter) {
    const gap = 8.0;
    const edgePadding = 4.0;

    final isOnRight = iconCenter.dx >= _ringCenter.dx;
    final isOnBottom = iconCenter.dy >= _ringCenter.dy;

    double left = isOnRight
        ? iconCenter.dx - _tooltipWidth - gap
        : iconCenter.dx + gap;

    double top = isOnBottom
        ? iconCenter.dy - _tooltipHeight - gap
        : iconCenter.dy + gap;

    left = left.clamp(
      edgePadding,
      _widgetSize - _tooltipWidth - edgePadding,
    );

    top = top.clamp(
      edgePadding,
      _widgetSize - _tooltipHeight - edgePadding,
    );

    return Rect.fromLTWH(
      left,
      top,
      _tooltipWidth,
      _tooltipHeight,
    );
  }

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phases = _phaseSegments();
    final tooltipRect = _selectedIconCenter == null
        ? null
        : _tooltipRect(_selectedIconCenter!);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        _handleRingTap(details.localPosition);
      },
      child: SizedBox(
        width: _widgetSize,
        height: _widgetSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _ringCenter.dx - _paintSize / 2,
              top: _ringCenter.dy - _paintSize / 2,
              child: CustomPaint(
                size: const Size(
                  _paintSize,
                  _paintSize,
                ),
                painter: _CycleRingPainter(
                  cycleDay: widget.cycleDay,
                  cycleLength: widget.cycleLength,
                  periodLength: widget.periodLength,
                ),
              ),
            ),
            Positioned(
              left: _ringCenter.dx - 92,
              top: _ringCenter.dy - 92,
              width: 184,
              height: 184,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            ...phases.map(
              (phase) {
                final iconCenter = _iconCenterForPhase(phase);
                return Positioned(
                  left: iconCenter.dx - 17,
                  top: iconCenter.dy - 17,
                  width: 34,
                  height: 34,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _selectPhase(phase),
                    child: Center(
                      child: Icon(
                        phase.materialIcon,
                        size: 26,
                        color: phase.color,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_selectedPhase != null && tooltipRect != null)
              Positioned(
                left: tooltipRect.left,
                top: tooltipRect.top,
                width: tooltipRect.width,
                height: tooltipRect.height,
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey(_selectedPhase!.title),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPhase!.color.withValues(alpha: 0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.11),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _selectedPhase!.materialIcon,
                            size: 17,
                            color: _selectedPhase!.color,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              _selectedPhase!.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                                color: Color(0xFF493B5D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhaseSegment {
  final String title;
  final String description;
  final String emoji;
  final IconData materialIcon;
  final Color color;
  final int startDay;
  final int dayCount;

  const _PhaseSegment({
    required this.title,
    required this.description,
    required this.emoji,
    required this.materialIcon,
    required this.color,
    required this.startDay,
    required this.dayCount,
  });
}

class _CycleRingPainter extends CustomPainter {
  final int cycleDay;
  final int cycleLength;
  final int periodLength;

  _CycleRingPainter({
    required this.cycleDay,
    required this.cycleLength,
    required this.periodLength,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final safeCycleLength = math.max(1, cycleLength);
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = math.min(
          size.width,
          size.height,
        ) /
        2 -
        12;

    const stroke = 14.0;
    const gap = 0.04;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    const menstruationColor = Color(0xFFE56B8A);
    const renewalColor = Color(0xFF8BCF9B);
    const fertileColor = Color(0xFFF4C95D);
    const restColor = Color(0xFFB9A6E8);

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF1EDF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    final menstruationDays = periodLength.clamp(1, safeCycleLength);
    const fertileDays = 6;

    final renewalDays = math.max(
      1,
      safeCycleLength - menstruationDays - fertileDays - 10,
    ).toInt();

    final restDays = math.max(
      1,
      safeCycleLength - menstruationDays - fertileDays - renewalDays,
    ).toInt();

    double start = -math.pi / 2;

    void drawPhase(
      int days,
      Color color,
    ) {
      if (days <= 0) {
        return;
      }

      final sweep = (days / safeCycleLength) * math.pi * 2;

      final phasePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        start + gap,
        math.max(
          0,
          sweep - gap * 2,
        ),
        false,
        phasePaint,
      );

      start += sweep;
    }

    drawPhase(
      menstruationDays,
      menstruationColor,
    );

    drawPhase(
      renewalDays,
      renewalColor,
    );

    drawPhase(
      fertileDays,
      fertileColor,
    );

    drawPhase(
      restDays,
      restColor,
    );

    final safeCycleDay = cycleDay.clamp(1, safeCycleLength);

    final markerAngle = -math.pi / 2 +
        ((safeCycleDay - 1) / safeCycleLength) * math.pi * 2;

    final markerCenter = Offset(
      center.dx + math.cos(markerAngle) * radius,
      center.dy + math.sin(markerAngle) * radius,
    );

    canvas.drawCircle(
      markerCenter,
      9,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      markerCenter,
      6,
      Paint()..color = const Color(0xFF7657A8),
    );
  }

  @override
  bool shouldRepaint(
    covariant _CycleRingPainter oldDelegate,
  ) {
    return oldDelegate.cycleDay != cycleDay ||
        oldDelegate.cycleLength != cycleLength ||
        oldDelegate.periodLength != periodLength;
  }
}
