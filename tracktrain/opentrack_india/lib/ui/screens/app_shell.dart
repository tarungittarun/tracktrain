import 'package:flutter/material.dart';

import '../../gen_l10n/app_localizations.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';
import 'home_track_screen.dart';
import 'live_station_screen.dart';
import 'settings_screen.dart';
import 'timetable_screen.dart';

/// Root scaffold with the four-tab bottom navigation.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<Widget> _screens = [
    HomeTrackScreen(),
    LiveStationScreen(),
    TimetableScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final titles = [
      l10n.appName,
      l10n.liveStation,
      l10n.timetable,
      l10n.dashboard,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          const ConnectivityBadge(),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.route_outlined),
            selectedIcon: const Icon(Icons.route),
            label: l10n.tabTrack,
          ),
          NavigationDestination(
            icon: const Icon(Icons.radar_outlined),
            selectedIcon: const Icon(Icons.radar),
            label: l10n.tabLiveStation,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.tabTimetable,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.tabDashboard,
          ),
        ],
      ),
    );
  }
}
