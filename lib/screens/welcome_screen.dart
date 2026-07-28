import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:within/l10n/app_localizations.dart';
import 'setup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sparkleController;

  bool _isLeaving = false;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();

    // Only the background sparkles are animated.
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();
  }

  Future<void> _openSetupScreen() async {
    if (_isLeaving) {
      return;
    }
    await HapticFeedback.lightImpact();


    setState(() {
      _isLeaving = true;
      _isButtonPressed = false;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 250),
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
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.40),
            radius: 1.22,
            colors: [
              Color(0xFFE4D3FF),
              Color(0xFFF0E5FF),
              Color(0xFFFFFAFF),
            ],
            stops: [0, 0.53, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WelcomeSparklesPainter(
                        progress: _sparkleController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isShortScreen = constraints.maxHeight < 700;
                  final isVeryShortScreen = constraints.maxHeight < 580;

                  final imageAreaHeight = (constraints.maxHeight -
                          (isShortScreen ? 220 : 205))
                      .clamp(
                    isVeryShortScreen ? 210.0 : 245.0,
                    520.0,
                  );

                  return SingleChildScrollView(
                    physics: isShortScreen
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      isShortScreen ? 2 : 6,
                      20,
                      isShortScreen ? 12 : 22,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            (isShortScreen ? 14 : 28),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedOpacity(
                            opacity: _isLeaving ? 0 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: _buildWithinArea(
                              height: imageAreaHeight,
                              imageErrorText: l10n.welcomeImageError,
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: _isLeaving ? 0 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              'Within',
                              style: TextStyle(
                                fontSize: isShortScreen ? 26 : 29,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).colorScheme.primary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 8 : 12),
                          AnimatedOpacity(
                            opacity: _isLeaving ? 0 : 1,
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              l10n.welcomeSlogan,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isShortScreen ? 16 : 18,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF514A59),
                              ),
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 18 : 30),
                          AnimatedOpacity(
                            opacity: _isLeaving ? 0.92 : 1,
                            duration: const Duration(milliseconds: 180),
                            child: Listener(
                              onPointerDown: (_) {
                                if (_isLeaving) {
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
                                    : _isLeaving
                                        ? 0.98
                                        : 1,
                                duration:
                                    const Duration(milliseconds: 100),
                                curve: Curves.easeOutCubic,
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 150),
                                  width: double.infinity,
                                  height: isShortScreen ? 54 : 58,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            _isButtonPressed || _isLeaving
                                                ? const Color(0x356842A5)
                                                : const Color(0x596842A5),
                                        blurRadius:
                                            _isButtonPressed || _isLeaving
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
                                    onPressed: _isLeaving
                                        ? null
                                        : _openSetupScreen,
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
                                          WidgetStateProperty.resolveWith<
                                              Color>(
                                        (states) {
                                          if (_isLeaving) {
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
                                          WidgetStateProperty.resolveWith<
                                              Color?>(
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeIn,
                                      child: _isLeaving
                                          ? Row(
                                              key: const ValueKey(
                                                'loading',
                                              ),
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
                                                Flexible(
                                                  child: Text(
                                                    l10n.welcomeContinue,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              l10n.welcomeStart,
                                              key: const ValueKey(
                                                'buttonText',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight:
                                                    FontWeight.w700,
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithinArea({
    required double height,
    required String imageErrorText,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Large soft purple aura behind Within.
          Positioned(
            top: height * 0.04,
            child: Container(
              width: height * 0.92,
              height: height * 0.92,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x596E45C2),
                    Color(0x356E45C2),
                    Color(0x1C9B72D3),
                    Colors.transparent,
                  ],
                  stops: [0, 0.36, 0.67, 1],
                ),
              ),
            ),
          ),

          // Secondary glow around the center of the character.
          Positioned(
            top: height * 0.15,
            child: Container(
              width: height * 0.60,
              height: height * 0.60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x486842A5),
                    blurRadius: 90,
                    spreadRadius: 22,
                  ),
                ],
              ),
            ),
          ),

          // Within remains completely still.
          Positioned.fill(
            child: ClipRect(
              child: Transform.scale(
                scale: 1.48,
                alignment: const Alignment(0, 0.08),
                child: Image.asset(
                  'assets/images/Within_default.png',
                  fit: BoxFit.contain,
                  alignment: const Alignment(0, 0.08),
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Center(
                      child: Text(
                        imageErrorText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF6842A5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeSparklesPainter extends CustomPainter {
  final double progress;

  const WelcomeSparklesPainter({
    required this.progress,
  });

  static const List<_SparkleData> _sparkles = [
    // Top area
    _SparkleData(
      position: Offset(0.07, 0.07),
      radius: 2.2,
      phase: 0.2,
      speed: 0.85,
    ),
    _SparkleData(
      position: Offset(0.16, 0.11),
      radius: 7.5,
      phase: 1.0,
      speed: 1.10,
    ),
    _SparkleData(
      position: Offset(0.26, 0.06),
      radius: 2.4,
      phase: 2.2,
      speed: 0.75,
    ),
    _SparkleData(
      position: Offset(0.38, 0.12),
      radius: 4.5,
      phase: 3.1,
      speed: 1.20,
    ),
    _SparkleData(
      position: Offset(0.50, 0.07),
      radius: 2.0,
      phase: 4.0,
      speed: 0.90,
    ),
    _SparkleData(
      position: Offset(0.62, 0.11),
      radius: 5.5,
      phase: 5.0,
      speed: 1.15,
    ),
    _SparkleData(
      position: Offset(0.75, 0.07),
      radius: 2.5,
      phase: 5.8,
      speed: 0.82,
    ),
    _SparkleData(
      position: Offset(0.84, 0.12),
      radius: 9.0,
      phase: 1.7,
      speed: 1.05,
    ),
    _SparkleData(
      position: Offset(0.94, 0.08),
      radius: 2.0,
      phase: 2.8,
      speed: 0.72,
    ),

    // Around the globe
    _SparkleData(
      position: Offset(0.06, 0.18),
      radius: 4.0,
      phase: 0.7,
      speed: 1.25,
    ),
    _SparkleData(
      position: Offset(0.14, 0.22),
      radius: 8.0,
      phase: 1.9,
      speed: 0.95,
    ),
    _SparkleData(
      position: Offset(0.23, 0.18),
      radius: 2.2,
      phase: 3.4,
      speed: 1.30,
    ),
    _SparkleData(
      position: Offset(0.31, 0.24),
      radius: 5.0,
      phase: 4.2,
      speed: 0.80,
    ),
    _SparkleData(
      position: Offset(0.42, 0.19),
      radius: 2.5,
      phase: 5.5,
      speed: 1.10,
    ),
    _SparkleData(
      position: Offset(0.53, 0.23),
      radius: 3.2,
      phase: 0.4,
      speed: 0.76,
    ),
    _SparkleData(
      position: Offset(0.66, 0.18),
      radius: 6.5,
      phase: 1.5,
      speed: 1.22,
    ),
    _SparkleData(
      position: Offset(0.76, 0.24),
      radius: 2.1,
      phase: 2.6,
      speed: 0.88,
    ),
    _SparkleData(
      position: Offset(0.87, 0.20),
      radius: 5.5,
      phase: 3.8,
      speed: 1.18,
    ),
    _SparkleData(
      position: Offset(0.95, 0.26),
      radius: 2.3,
      phase: 5.1,
      speed: 0.78,
    ),

    // Around Within's upper body and hair
    _SparkleData(
      position: Offset(0.07, 0.31),
      radius: 2.5,
      phase: 0.9,
      speed: 0.80,
    ),
    _SparkleData(
      position: Offset(0.16, 0.35),
      radius: 5.5,
      phase: 2.0,
      speed: 1.26,
    ),
    _SparkleData(
      position: Offset(0.27, 0.30),
      radius: 2.0,
      phase: 3.0,
      speed: 0.72,
    ),
    _SparkleData(
      position: Offset(0.37, 0.37),
      radius: 3.5,
      phase: 4.1,
      speed: 1.14,
    ),
    _SparkleData(
      position: Offset(0.48, 0.31),
      radius: 2.2,
      phase: 5.2,
      speed: 0.84,
    ),
    _SparkleData(
      position: Offset(0.59, 0.36),
      radius: 4.5,
      phase: 0.5,
      speed: 1.28,
    ),
    _SparkleData(
      position: Offset(0.70, 0.30),
      radius: 2.0,
      phase: 1.6,
      speed: 0.74,
    ),
    _SparkleData(
      position: Offset(0.80, 0.35),
      radius: 8.5,
      phase: 2.7,
      speed: 1.05,
    ),
    _SparkleData(
      position: Offset(0.92, 0.31),
      radius: 3.0,
      phase: 3.9,
      speed: 0.92,
    ),

    // Middle area
    _SparkleData(
      position: Offset(0.08, 0.44),
      radius: 5.0,
      phase: 0.3,
      speed: 1.20,
    ),
    _SparkleData(
      position: Offset(0.19, 0.47),
      radius: 2.2,
      phase: 1.4,
      speed: 0.75,
    ),
    _SparkleData(
      position: Offset(0.30, 0.42),
      radius: 6.5,
      phase: 2.5,
      speed: 1.12,
    ),
    _SparkleData(
      position: Offset(0.41, 0.49),
      radius: 2.0,
      phase: 3.6,
      speed: 0.82,
    ),
    _SparkleData(
      position: Offset(0.53, 0.43),
      radius: 3.0,
      phase: 4.7,
      speed: 1.30,
    ),
    _SparkleData(
      position: Offset(0.64, 0.48),
      radius: 2.4,
      phase: 5.8,
      speed: 0.70,
    ),
    _SparkleData(
      position: Offset(0.76, 0.43),
      radius: 5.5,
      phase: 0.8,
      speed: 1.18,
    ),
    _SparkleData(
      position: Offset(0.87, 0.49),
      radius: 2.2,
      phase: 1.9,
      speed: 0.86,
    ),
    _SparkleData(
      position: Offset(0.95, 0.42),
      radius: 7.5,
      phase: 3.0,
      speed: 1.08,
    ),

    // Lower part of the character
    _SparkleData(
      position: Offset(0.07, 0.57),
      radius: 2.3,
      phase: 0.6,
      speed: 0.76,
    ),
    _SparkleData(
      position: Offset(0.16, 0.62),
      radius: 6.5,
      phase: 1.7,
      speed: 1.20,
    ),
    _SparkleData(
      position: Offset(0.28, 0.56),
      radius: 2.0,
      phase: 2.8,
      speed: 0.84,
    ),
    _SparkleData(
      position: Offset(0.39, 0.63),
      radius: 4.0,
      phase: 3.9,
      speed: 1.15,
    ),
    _SparkleData(
      position: Offset(0.51, 0.58),
      radius: 2.4,
      phase: 5.0,
      speed: 0.72,
    ),
    _SparkleData(
      position: Offset(0.62, 0.63),
      radius: 3.0,
      phase: 6.0,
      speed: 1.25,
    ),
    _SparkleData(
      position: Offset(0.73, 0.57),
      radius: 2.0,
      phase: 0.9,
      speed: 0.80,
    ),
    _SparkleData(
      position: Offset(0.84, 0.62),
      radius: 7.0,
      phase: 2.0,
      speed: 1.10,
    ),
    _SparkleData(
      position: Offset(0.94, 0.56),
      radius: 2.5,
      phase: 3.1,
      speed: 0.88,
    ),

    // Sparse lower background
    _SparkleData(
      position: Offset(0.10, 0.71),
      radius: 3.0,
      phase: 0.4,
      speed: 1.15,
    ),
    _SparkleData(
      position: Offset(0.25, 0.75),
      radius: 2.0,
      phase: 1.8,
      speed: 0.72,
    ),
    _SparkleData(
      position: Offset(0.76, 0.74),
      radius: 4.5,
      phase: 3.2,
      speed: 1.18,
    ),
    _SparkleData(
      position: Offset(0.91, 0.70),
      radius: 2.2,
      phase: 4.6,
      speed: 0.80,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in _sparkles) {
      final angle =
          progress *
              2 *
              math.pi *
              sparkle.speed +
          sparkle.phase;

      final rawValue =
          (math.sin(angle) + 1) / 2;

      // Stars reach full brightness quickly and remain bright longer.
      final brightnessValue =
          Curves.easeOutCubic.transform(rawValue);

      final opacity =
          0.08 + brightnessValue * 0.92;

      final radius =
          sparkle.radius *
          (0.72 + brightnessValue * 0.38);

      final center = Offset(
        size.width * sparkle.position.dx,
        size.height * sparkle.position.dy,
      );

      _drawSparkle(
        canvas: canvas,
        center: center,
        radius: radius,
        opacity: opacity,
        isLarge: sparkle.radius >= 6,
      );
    }
  }

  void _drawSparkle({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double opacity,
    required bool isLarge,
  }) {
    if (isLarge && opacity > 0.45) {
      canvas.drawCircle(
        center,
        radius * 1.8,
        Paint()
          ..color = Color.fromRGBO(
            255,
            255,
            255,
            opacity * 0.13,
          )
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            radius * 0.85,
          ),
      );
    }

    final sparkleColor = isLarge
        ? const Color(0xFFFFF0B8)
        : const Color(0xFFFFFCF1);

    final sparklePaint = Paint()
      ..color = sparkleColor.withValues(
        alpha: opacity,
      )
      ..style = PaintingStyle.fill;

    final horizontalRadius =
        isLarge ? radius * 0.82 : radius;

    final path = Path()
      ..moveTo(
        center.dx,
        center.dy - radius,
      )
      ..quadraticBezierTo(
        center.dx + horizontalRadius * 0.16,
        center.dy - radius * 0.16,
        center.dx + horizontalRadius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + horizontalRadius * 0.16,
        center.dy + radius * 0.16,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - horizontalRadius * 0.16,
        center.dy + radius * 0.16,
        center.dx - horizontalRadius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - horizontalRadius * 0.16,
        center.dy - radius * 0.16,
        center.dx,
        center.dy - radius,
      )
      ..close();

    canvas.drawPath(
      path,
      sparklePaint,
    );

    canvas.drawCircle(
      center,
      radius * 0.13,
      Paint()
        ..color = Color.fromRGBO(
          255,
          255,
          255,
          opacity,
        ),
    );
  }

  @override
  bool shouldRepaint(
    covariant WelcomeSparklesPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}

class _SparkleData {
  final Offset position;
  final double radius;
  final double phase;
  final double speed;

  const _SparkleData({
    required this.position,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}