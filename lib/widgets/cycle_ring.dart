import 'dart:math' as math;

import 'package:flutter/material.dart';

class CycleRing extends StatefulWidget {
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
  State<CycleRing> createState() => _CycleRingState();
}

class _CycleRingState extends State<CycleRing> {
  String? _activeTooltipTitle;
  String? _activeTooltipDescription;

  void _handlePhaseTap(double angle) {
    double normalizedAngle = (angle + math.pi / 2) % (math.pi * 2);
    if (normalizedAngle < 0) normalizedAngle += math.pi * 2;

    double progress = normalizedAngle / (math.pi * 2);
    int tappedDay = (progress * widget.cycleLength).round() + 1;
    if (tappedDay > widget.cycleLength) tappedDay = 1;

    String title;
    String desc;

    if (tappedDay <= widget.periodLength) {
      title = 'Regl Dönemi';
      desc = 'Kanama ve vücudun yenilenme sürecinin başlangıcı.';
    } else if (tappedDay <= widget.periodLength + math.max(1, widget.cycleLength - widget.periodLength - 6 - 10)) {
      title = 'Yenilenme / Foliküler';
      desc = 'Enerjinin ve östrojenin yükseldiği, dinamik dönem.';
    } else if (tappedDay <= widget.cycleLength - 10) {
      title = 'Yumurtlama / Ovulasyon';
      desc = 'Doğurganlığın en yüksek olduğu, enerjik zaman.';
    } else {
      title = 'Dinlenme / Luteal';
      desc = 'Regl öncesi sakinleşme, vücudun dinlenme evresi.';
    }

    setState(() {
      _activeTooltipTitle = title;
      _activeTooltipDescription = desc;
    });
  }

  void _clearTooltip() {
    setState(() {
      _activeTooltipTitle = null;
      _activeTooltipDescription = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        final center = const Offset(155, 155);
        final localPos = details.localPosition;
        final dx = localPos.dx - center.dx;
        final dy = localPos.dy - center.dy;
        final angle = math.atan2(dy, dx);
        _handlePhaseTap(angle);
      },
      onPanEnd: (_) => _clearTooltip(),
      onPanCancel: _clearTooltip,
      child: SizedBox(
        width: 310,
        height: 310,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: const Size(260, 260),
              painter: _CycleRingPainter(
                cycleDay: widget.cycleDay,
                cycleLength: widget.cycleLength,
                periodLength: widget.periodLength,
              ),
            ),
            Center(
              child: Padding(
                // Sağdan ve soldan boşluğu artırarak halkaya taşmayı tamamen engelliyoruz
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_activeTooltipTitle != null) ...[
                      Text(
                        _activeTooltipTitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7657A8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _activeTooltipDescription!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF77707E),
                          height: 1.25,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '${widget.cycleDay}',
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
                        widget.phaseName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2733),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              top: -10,
              child: GestureDetector(
                onLongPressStart: (_) => setState(() {
                  _activeTooltipTitle = 'Regl Dönemi';
                  _activeTooltipDescription = 'Vücudun temizlenme ve yeni döngüye başlama evresi.';
                }),
                onLongPressEnd: (_) => _clearTooltip(),
                child: const Text('🩸', style: TextStyle(fontSize: 24)),
              ),
            ),
            Positioned(
              right: -12,
              top: 143,
              child: GestureDetector(
                onLongPressStart: (_) => setState(() {
                  _activeTooltipTitle = 'Yenilenme Dönemi';
                  _activeTooltipDescription = 'Östrojenin arttığı, fiziksel enerjinin toplandığı evre.';
                }),
                onLongPressEnd: (_) => _clearTooltip(),
                child: const Text('🌱', style: TextStyle(fontSize: 24)),
              ),
            ),
            Positioned(
              bottom: -10,
              child: GestureDetector(
                onLongPressStart: (_) => setState(() {
                  _activeTooltipTitle = 'Yumurtlama Dönemi';
                  _activeTooltipDescription = 'Doğurganlığın en yüksek seviyede olduğu zaman dilimi.';
                }),
                onLongPressEnd: (_) => _clearTooltip(),
                child: const Text('🌸', style: TextStyle(fontSize: 24)),
              ),
            ),
            Positioned(
              left: -12,
              top: 143,
              child: GestureDetector(
                onLongPressStart: (_) => setState(() {
                  _activeTooltipTitle = 'Dinlenme Dönemi';
                  _activeTooltipDescription = 'Regl öncesi sakinleşme, yavaşlama ve içe dönme evresi.';
                }),
                onLongPressEnd: (_) => _clearTooltip(),
                child: const Text('💤', style: TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const stroke = 14.0;
    final rect = Rect.fromCircle(center: center, radius: radius);
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

    canvas.drawCircle(center, radius, backgroundPaint);

    final int menstruationDays = periodLength;
    const int fertileDays = 6;
    final int renewalDays = math.max(1, cycleLength - menstruationDays - fertileDays - 10).toInt();
    final int restDays = cycleLength - menstruationDays - fertileDays - renewalDays;

    double start = -math.pi / 2;

    void drawPhase(int days, Color color) {
      if (days <= 0) return;
      final sweep = (days / cycleLength) * math.pi * 2;
      final phasePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, start + gap, math.max(0, sweep - gap * 2), false, phasePaint);
      start += sweep;
    }

    drawPhase(menstruationDays, menstruationColor);
    drawPhase(renewalDays, renewalColor);
    drawPhase(fertileDays, fertileColor);
    drawPhase(restDays, restColor);

    final safeCycleDay = cycleDay.clamp(1, cycleLength);
    final markerAngle = -math.pi / 2 + ((safeCycleDay - 1) / cycleLength) * math.pi * 2;

    final markerCenter = Offset(
      center.dx + math.cos(markerAngle) * radius,
      center.dy + math.sin(markerAngle) * radius,
    );

    canvas.drawCircle(markerCenter, 8, Paint()..color = Colors.white);
    canvas.drawCircle(markerCenter, 5, Paint()..color = const Color(0xFF7657A8));
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.cycleDay != cycleDay ||
        oldDelegate.cycleLength != cycleLength ||
        oldDelegate.periodLength != periodLength;
  }
}