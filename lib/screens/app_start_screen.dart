import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  late Future<bool> _setupCompletedFuture;

  @override
  void initState() {
    super.initState();
    _setupCompletedFuture = StorageService.isSetupCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _setupCompletedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen();
        }

        final setupCompleted = snapshot.data ?? false;

        if (setupCompleted) {
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Uygulama başlatılırken bir hata oluştu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _setupCompletedFuture = StorageService.isSetupCompleted();
                    });
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9F7FC),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7657A8),
        ),
      ),
    );
  }
}