import 'dart:math' as math;

import 'package:flutter/material.dart';

class CycleRing extends StatelessWidget {
  final int cycleDay;
  final int cycleLength;
  final int periodLength;
  final String phaseName;
  final String phaseIcon;

  const CycleRing({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    required this.periodLength,
    required this.phaseName,
    required this.phaseIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 310,
      height: 310,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: _CycleRingPainter(
              cycleDay: cycleDay,
              cycleLength: cycleLength,
              periodLength: periodLength,
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$cycleDay',
                  style: const TextStyle(
                    fontSize: 58,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7657A8),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Döngü günü',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B8490),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  phaseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2733),
                  ),
                ),
              ],
            ),
          ),

          const Positioned(
            top: -10,
            child: Text(
              '🩸',
              style: TextStyle(fontSize: 24),
            ),
          ),

          const Positioned(
            right: -12,
            top: 143,
            child: Text(
              '🌱',
              style: TextStyle(fontSize: 24),
            ),
          ),

          const Positioned(
            bottom: -10,
            child: Text(
              '🌸',
              style: TextStyle(fontSize: 24),
            ),
          ),

          const Positioned(
            left: -12,
            top: 143,
            child: Text(
              '💤',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
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
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        math.min(size.width, size.height) / 2 - 12;

    const stroke = 14.0;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    const gap = 0.04;

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

    final int menstruationDays = periodLength;
    const int fertileDays = 6;

    final int renewalDays = math
        .max(
          1,
          cycleLength -
              menstruationDays -
              fertileDays -
              10,
        )
        .toInt();

    final int restDays =
        cycleLength -
        menstruationDays -
        fertileDays -
        renewalDays;

    double start = -math.pi / 2;

    void drawPhase(int days, Color color) {
      if (days <= 0) {
        return;
      }

      final sweep =
          (days / cycleLength) * math.pi * 2;

      final phasePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        start + gap,
        math.max(0, sweep - gap * 2),
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

    final safeCycleDay = cycleDay.clamp(
      1,
      cycleLength,
    );

    final markerAngle =
        -math.pi / 2 +
        ((safeCycleDay - 1) / cycleLength) *
            math.pi *
            2;

    final markerCenter = Offset(
      center.dx +
          math.cos(markerAngle) * radius,
      center.dy +
          math.sin(markerAngle) * radius,
    );

    canvas.drawCircle(
      markerCenter,
      7,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      markerCenter,
      4,
      Paint()
        ..color = const Color(0xFF7657A8),
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