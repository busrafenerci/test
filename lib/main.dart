import 'package:flutter/material.dart';
import 'package:within/l10n/app_localizations.dart';

import 'screens/app_start_screen.dart';
import 'services/locale_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocaleService.initialize();

  runApp(const WithinApp());
}

class WithinApp extends StatelessWidget {
  const WithinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Within',
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppStartScreen(),
        );
      },
    );
  }
}
