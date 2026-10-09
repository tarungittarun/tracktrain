import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../data/db/app_database.dart';
import '../data/models/hive_records.dart';
import '../data/repositories/cell_tower_repository.dart';
import '../data/repositories/station_repository.dart';
import '../data/repositories/train_repository.dart';
import '../services/cell_info_service.dart';
import '../services/connectivity_service.dart';
import '../services/foreground_service.dart';
import '../services/geofence_alarm_service.dart';
import '../services/live_data_service.dart';
import '../services/location_tracker_service.dart';
import '../services/settings_service.dart';
import '../services/tracking_controller.dart';
import '../services/usage_analytics_service.dart';

/// Composition root. Constructed once in `main()` before `runApp` so every
/// provider can resolve services synchronously.
class AppServices {
  AppServices._({
    required this.settings,
    required this.analytics,
    required this.connectivity,
    required this.tracker,
    required this.alarms,
    required this.cellInfo,
    required this.foreground,
    required this.liveRail,
    required this.stations,
    required this.trains,
    required this.towers,
    required this.quickCardsBox,
    required this.trackingController,
  });

  static AppServices? _instance;

  /// Guaranteed non-null after [bootstrap] completes in `main()`.
  static AppServices get instance {
    final services = _instance;
    assert(services != null, 'AppServices.bootstrap() must run first');
    return services!;
  }

  final SettingsService settings;
  final UsageAnalyticsService analytics;
  final ConnectivityService connectivity;
  final LocationTrackerService tracker;
  final GeofenceAlarmService alarms;
  final CellInfoService cellInfo;
  final ForegroundService foreground;
  final LiveRailService liveRail;
  final StationRepository stations;
  final TrainRepository trains;
  final CellTowerRepository towers;
  final Box<QuickCard> quickCardsBox;
  final TrackingController trackingController;

  static Future<AppServices> bootstrap() async {
    final settingsBox = await Hive.openBox<dynamic>(SettingsService.boxName);
    final usageBox =
        await Hive.openBox<DailyUsage>(UsageAnalyticsService.usageBoxName);
    final tripsBox =
        await Hive.openBox<TripRecord>(UsageAnalyticsService.tripsBoxName);
    final quickCardsBox = await Hive.openBox<QuickCard>('quick_cards');

    final settings = SettingsService(settingsBox);
    final analytics = UsageAnalyticsService(usageBox, tripsBox);
    final connectivity = ConnectivityService();
    final tracker = LocationTrackerService();
    final alarms = GeofenceAlarmService();
    final cellInfo = CellInfoService();
    final foreground = ForegroundService();
    final liveRail = LiveRailService();
    const stations = StationRepository();
    const trains = TrainRepository();
    const towers = CellTowerRepository();

    final trackingController = TrackingController(
      tracker: tracker,
      alarms: alarms,
      analytics: analytics,
      connectivity: connectivity,
      settings: settings,
      stations: stations,
      towers: towers,
      cellInfo: cellInfo,
      foreground: foreground,
    );

    final services = AppServices._(
      settings: settings,
      analytics: analytics,
      connectivity: connectivity,
      tracker: tracker,
      alarms: alarms,
      cellInfo: cellInfo,
      foreground: foreground,
      liveRail: liveRail,
      stations: stations,
      trains: trains,
      towers: towers,
      quickCardsBox: quickCardsBox,
      trackingController: trackingController,
    );

    analytics.setOnlineMode(connectivity.isOnline);
    analytics.beginSession();

    // Warm the bundled SQLite database off the critical path.
    unawaited(AppDatabase.instance.ensureReady());

    _instance = services;
    return services;
  }
}
