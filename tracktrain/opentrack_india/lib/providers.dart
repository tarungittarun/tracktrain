import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme/app_theme.dart';
import 'core/app_services.dart';
import 'core/enums.dart';
import 'data/models/hive_records.dart';
import 'data/models/station.dart';
import 'data/models/train.dart';
import 'services/settings_service.dart';
import 'services/tracking_controller.dart';
import 'services/usage_analytics_service.dart';

/// Root access to the bootstrapped service graph.
final appServicesProvider = Provider<AppServices>((ref) {
  return AppServices.instance;
});

final settingsProvider = ChangeNotifierProvider<SettingsService>((ref) {
  return ref.watch(appServicesProvider).settings;
});

final trackingControllerProvider =
    ChangeNotifierProvider<TrackingController>((ref) {
  return ref.watch(appServicesProvider).trackingController;
});

/// Emits whenever connectivity changes so online/offline badges rebuild.
final isOnlineProvider = Provider<bool>((ref) {
  final services = ref.watch(appServicesProvider);
  final connectivity = services.connectivity;

  void listener() => ref.state = connectivity.isOnline;
  connectivity.addListener(listener);
  ref.onDispose(() => connectivity.removeListener(listener));
  return connectivity.isOnline;
});

/// Rebuilt on every analytics mutation (Hive write).
final analyticsTickProvider = Provider<int>((ref) {
  final services = ref.watch(appServicesProvider);
  void listener() => ref.state = services.analytics.version.value;
  services.analytics.version.addListener(listener);
  ref.onDispose(() => services.analytics.version.removeListener(listener));
  return services.analytics.version.value;
});

final dashboardTotalsProvider = Provider<DashboardTotals>((ref) {
  ref.watch(analyticsTickProvider);
  return ref.watch(appServicesProvider).analytics.totals();
});

final weeklyDistanceProvider =
    Provider<List<(String, double)>>((ref) {
  ref.watch(analyticsTickProvider);
  return ref.watch(appServicesProvider).analytics.weeklyDistance();
});

final tripsProvider = Provider<List<TripRecord>>((ref) {
  ref.watch(analyticsTickProvider);
  return ref.watch(appServicesProvider).analytics.trips();
});

/// Debounce-free typo-tolerant station search keyed by raw query.
final stationSearchProvider =
    FutureProvider.family<List<Station>, String>((ref, query) {
  return ref.watch(appServicesProvider).stations.search(query);
});

final trainSearchProvider =
    FutureProvider.family<List<Train>, String>((ref, query) {
  return ref.watch(appServicesProvider).trains.search(query);
});

/// Resolved theme set for the current settings.
class ThemeBundle {
  const ThemeBundle({
    required this.mode,
    required this.light,
    required this.dark,
  });

  final ThemeMode mode;
  final ThemeData light;
  final ThemeData dark;
}

final themeBundleProvider = Provider<ThemeBundle>((ref) {
  final settings = ref.watch(settingsProvider);
  final highContrast = settings.highContrast;

  switch (settings.theme) {
    case AppThemeChoice.system:
      return ThemeBundle(
        mode: ThemeMode.system,
        light: AppTheme.light(highContrast: highContrast),
        dark: AppTheme.dark(highContrast: highContrast, oled: false),
      );
    case AppThemeChoice.light:
      return ThemeBundle(
        mode: ThemeMode.light,
        light: AppTheme.light(highContrast: highContrast),
        dark: AppTheme.dark(highContrast: highContrast, oled: false),
      );
    case AppThemeChoice.dark:
      return ThemeBundle(
        mode: ThemeMode.dark,
        light: AppTheme.light(highContrast: highContrast),
        dark: AppTheme.dark(highContrast: highContrast, oled: false),
      );
    case AppThemeChoice.oled:
      return ThemeBundle(
        mode: ThemeMode.dark,
        light: AppTheme.light(highContrast: highContrast),
        dark: AppTheme.dark(highContrast: highContrast, oled: true),
      );
  }
});
