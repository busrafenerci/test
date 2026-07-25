import 'package:flutter/material.dart';

import 'setup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _floatingAnimation;

  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _floatingAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  Future<void> _openSetupScreen() async {
    if (_isLeaving) return;

    setState(() {
      _isLeaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
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
                begin: const Offset(0, 0.05),
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 350),
                        opacity: _isLeaving ? 0 : 1,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          offset: _isLeaving
                              ? const Offset(0, -0.12)
                              : Offset.zero,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      _floatingAnimation.value,
                                    ),
                                    child: child,
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/luna_home.png',
                                  height: 280, // Küçük ekranlar için boyutu biraz optimize ettik
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Luna',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6842A5),
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _openSetupScreen,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6842A5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
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
    );
  }
}