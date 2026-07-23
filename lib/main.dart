import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/app_start_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LunaApp());
}

class LunaApp extends StatelessWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luna',
      theme: AppTheme.lightTheme,
      localizationsDelegates:
          GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      home: const AppStartScreen(),
    );
  }
}