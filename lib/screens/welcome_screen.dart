import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'setup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _handRotation;
  late final Animation<double> _handLift;
  late final Animation<double> _worldBounce;
  late final Animation<double> _glowPulse;

  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Only the hand/forearm layer moves.
    _handRotation = const AlwaysStoppedAnimation<double>(0);

    _handLift = Tween<double>(
      begin: 1,
      end: -2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    // The world starts closer to the hand and rises gently.
    _worldBounce = Tween<double>(
      begin: 0,
      end: -4,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _glowPulse = Tween<double>(
      begin: 0.82,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _openSetupScreen() async {
    if (_isLeaving) {
      return;
    }

    setState(() {
      _isLeaving = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const SetupScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.10, -0.35),
            radius: 1.18,
            colors: [
              Color(0xFFE8D9FF),
              Color(0xFFF3EAFF),
              Color(0xFFFFFBFF),
            ],
            stops: [0, 0.48, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final characterSize =
                  (constraints.maxWidth * 0.94).clamp(300.0, 410.0);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      12,
                      24,
                      24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: _isLeaving ? 0 : 1,
                          duration:
                              const Duration(milliseconds: 300),
                          child: LunaCharacter(
                            size: characterSize,
                            animation: _controller,
                            handRotation: _handRotation,
                            handLift: _handLift,
                            worldBounce: _worldBounce,
                            glowPulse: _glowPulse,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Luna',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6842A5),
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Döngünü tanı.\nGücünü keşfet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E2933),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed:
                                _isLeaving ? null : _openSetupScreen,
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF6842A5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Başlayalım',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LunaCharacter extends StatelessWidget {
  final double size;
  final Animation<double> animation;
  final Animation<double> handRotation;
  final Animation<double> handLift;
  final Animation<double> worldBounce;
  final Animation<double> glowPulse;

  const LunaCharacter({
    super.key,
    required this.size,
    required this.animation,
    required this.handRotation,
    required this.handLift,
    required this.worldBounce,
    required this.glowPulse,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _fullCanvasAsset(
            'assets/images/luna_legs.png',
          ),
          _fullCanvasAsset(
            'assets/images/luna_body.png',
          ),

          // Only the skin hand/forearm layer is animated.
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, handLift.value),
                child: Transform.rotate(
                  angle: handRotation.value,
                  alignment: const FractionalOffset(
                    0.44,
                    0.47,
                  ),
                  child: child,
                ),
              );
            },
            child: _fullCanvasAsset(
              'assets/images/luna_right_arm.png',
            ),
          ),

          _fullCanvasAsset(
            'assets/images/luna_head.png',
          ),

          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  worldBounce.value,
                ),
                child: child,
              );
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: WorldGlowPainter(
                      progress: animation.value,
                      pulse: glowPulse.value,
                    ),
                  ),
                ),
                _fullCanvasAsset(
                  'assets/images/luna_world.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fullCanvasAsset(String path) {
    return Positioned.fill(
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }
}

class WorldGlowPainter extends CustomPainter {
  final double progress;
  final double pulse;

  const WorldGlowPainter({
    required this.progress,
    required this.pulse,
  });

  static const List<Offset> _sparklePositions = [
    Offset(-1.12, -0.48),
    Offset(-0.72, -1.02),
    Offset(0.02, -1.18),
    Offset(0.76, -0.94),
    Offset(1.16, -0.36),
    Offset(1.08, 0.42),
    Offset(0.52, 0.96),
    Offset(-0.34, 1.10),
    Offset(-1.02, 0.62),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * 0.325,
      size.height * 0.385,
    );

    final worldRadius = size.width * 0.115;
    final glowRadius = worldRadius * 1.42 * pulse;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x776F45C2),
          const Color(0x334F2CA6),
          Colors.transparent,
        ],
        stops: const [0, 0.55, 1],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: glowRadius,
        ),
      );

    canvas.drawCircle(
      center,
      glowRadius,
      glowPaint,
    );

    for (
      int index = 0;
      index < _sparklePositions.length;
      index++
    ) {
      final position = _sparklePositions[index];
      final phase =
          progress * 2 * math.pi + index * 0.83;
      final opacity =
          0.35 + 0.65 * ((math.sin(phase) + 1) / 2);

      final sparkleCenter = center +
          Offset(
            position.dx * worldRadius,
            position.dy * worldRadius,
          );

      final sparkleSize =
          worldRadius *
          (index.isEven ? 0.13 : 0.09) *
          (0.75 + opacity * 0.35);

      _drawSparkle(
        canvas,
        sparkleCenter,
        sparkleSize,
        opacity,
      );
    }
  }

  void _drawSparkle(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final paint = Paint()
      ..color = Color.fromRGBO(
        255,
        245,
        204,
        opacity,
      )
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy - radius * 0.18,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy + radius * 0.18,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy + radius * 0.18,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy - radius * 0.18,
        center.dx,
        center.dy - radius,
      )
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawCircle(
      center,
      radius * 0.16,
      Paint()
        ..color = Colors.white.withValues(
          alpha: opacity,
        ),
    );
  }

  @override
  bool shouldRepaint(
    covariant WorldGlowPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse;
  }
}
