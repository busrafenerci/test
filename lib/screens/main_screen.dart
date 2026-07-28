import 'package:flutter/material.dart';
import 'package:within/screens/calendar_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'package:within/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _homeRefreshVersion = 0;
  int _calendarRefreshVersion = 0;

  static const Color _primaryPurple = Color(0xFF7657A8);
  static const Color _inactiveColor = Color(0xFF9B94A3);
  static const Color _backgroundColor = Color(0xFFF9F7FC);

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        _homeRefreshVersion++;
      }

      if (index == 1) {
        _calendarRefreshVersion++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        refreshVersion: _homeRefreshVersion,
      ),
      CalendarScreen(
        refreshVersion: _calendarRefreshVersion,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: _primaryPurple.withValues(
          alpha: 0.14,
        ),
        height: 72,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _inactiveColor,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: _primaryPurple,
            ),
            label: AppLocalizations.of(context)!.navHome,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
              color: _inactiveColor,
            ),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: _primaryPurple,
            ),
            label: AppLocalizations.of(context)!.navCalendar,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: _inactiveColor,
            ),
            selectedIcon: Icon(
              Icons.settings_rounded,
              color: _primaryPurple,
            ),
            label: AppLocalizations.of(context)!.navSettings,
          ),
        ],
      ),
    );
  }
}