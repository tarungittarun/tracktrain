import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../core/enums.dart';
import '../core/geo_utils.dart';
import '../core/ist_clock.dart';
import '../data/models/cell_tower.dart';
import '../data/models/hive_records.dart';
import '../data/models/station.dart';
import '../data/repositories/cell_tower_repository.dart';
import '../data/repositories/station_repository.dart';
import 'cell_info_service.dart';
import 'connectivity_service.dart';
import 'foreground_service.dart';
import 'geofence_alarm_service.dart';
import 'location_tracker_service.dart';
import 'settings_service.dart';
import 'usage_analytics_service.dart';

/// Destination alarm configuration chosen on the home screen.
class DestinationAlarmConfig {
  const DestinationAlarmConfig({
    required this.destination,
    required this.leadKm,
    required this.armedAt,
  });

  final Station destination;
  final double leadKm;
  final DateTime armedAt;

  String get leadLabel => '${leadKm.toStringAsFixed(0)} km';
}

/// Orchestrates one tracking session: dual-mode positioning, trip metrics,
/// nearest-station projection, ETA, and the destination geofence alarm.
class TrackingController extends ChangeNotifier {
  TrackingController({
    required LocationTrackerService tracker,
    required GeofenceAlarmService alarms,
    required UsageAnalyticsService analytics,
    required ConnectivityService connectivity,
    required SettingsService settings,
    required StationRepository stations,
    required CellTowerRepository towers,
    required CellInfoService cellInfo,
    required ForegroundService foreground,
  })  : _tracker = tracker,
        _alarms = alarms,
        _analytics = analytics,
        _connectivity = connectivity,
        _settings = settings,
        _stations = stations,
        _towers = towers,
        _cellInfo = cellInfo,
        _foreground = foreground;

  final LocationTrackerService _tracker;
  final GeofenceAlarmService _alarms;
  final UsageAnalyticsService _analytics;
  final ConnectivityService _connectivity;
  final SettingsService _settings;
  final StationRepository _stations;
  final CellTowerRepository _towers;
  final CellInfoService _cellInfo;
  final ForegroundService _foreground;

  Position? _previousFix;
  PositionSampleListener? _sampleListener;
  DateTime? _tripStart;
  DateTime? _lastNearestProbe;

  double _distanceKm = 0;
  double _topSpeedKmh = 0;
  double _speedSum = 0;
  int _movingSamples = 0;

  Station? _nearestStation;
  double? _nearestDistanceMeters;
  CellTowerRecord? _towerMatch;
  DestinationAlarmConfig? _alarmConfig;
  bool _proximityFired = false;

  bool get isSessionActive => _tripStart != null;
  double get distanceKm => _distanceKm;
  double get topSpeedKmh => _topSpeedKmh;

  double get averageSpeedKmh =>
      _movingSamples == 0 ? 0 : _speedSum / _movingSamples;

  Station? get nearestStation => _nearestStation;
  double? get nearestDistanceMeters => _nearestDistanceMeters;
  CellTowerRecord? get towerMatch => _towerMatch;
  DestinationAlarmConfig? get alarmConfig => _alarmConfig;

  /// Remaining rail distance to the armed destination, or null.
  double? get remainingMeters {
    final config = _alarmConfig;
    final fix = _tracker.lastPosition;
    if (config == null || fix == null) return null;
    final straight = GeoUtils.haversineMeters(
      fix.latitude,
      fix.longitude,
      config.destination.latitude,
      config.destination.longitude,
    );
    return GeoUtils.railDistanceMeters(straight);
  }

  /// Projected arrival time at the armed destination, or null.
  DateTime? get eta {
    final remaining = remainingMeters;
    if (remaining == null) return null;
    final duration = GeoUtils.etaForDistance(
      remaining,
      speedKmh: _tracker.speedKmh > 5 ? _tracker.speedKmh : averageSpeedKmh,
    );
    return IstClock.correctedNow().add(duration);
  }

  double get speedKmh => _tracker.speedKmh;

  Future<bool> startSession() async {
    if (isSessionActive) return true;

    final started = await _tracker.start();
    if (!started) {
      notifyListeners();
      return false;
    }

    _tripStart = DateTime.now();
    _previousFix = null;
    _distanceKm = 0;
    _topSpeedKmh = 0;
    _speedSum = 0;
    _movingSamples = 0;
    _proximityFired = false;

    _sampleListener = _onSample;
    _tracker.addSampleListener(_sampleListener!);

    unawaited(_foreground.start());

    if (_settings.trackingMode != TrackingModeChoice.gpsOnly) {
      unawaited(_probeCellTower());
    }
    notifyListeners();
    return true;
  }

  Future<void> stopSession() async {
    if (!isSessionActive) return;

    if (_sampleListener != null) {
      _tracker.removeSampleListener(_sampleListener!);
      _sampleListener = null;
    }

    // Capture the armed destination before clearing alarm state.
    final armedDestination = _alarmConfig?.destination;

    await _tracker.stop();
    await _foreground.stop();
    await _alarms.cancelAll();
    _alarmConfig = null;

    final started = _tripStart ?? DateTime.now();
    final duration = DateTime.now().difference(started);
    final trip = TripRecord(
      id: started.millisecondsSinceEpoch.toString(),
      startedAtMillis: started.millisecondsSinceEpoch,
      originCode: _nearestStation?.code ?? '',
      originName: _nearestStation?.name ?? 'Unknown origin',
      destinationCode: armedDestination?.code ?? '',
      destinationName: armedDestination?.name ?? 'Open journey',
      distanceKm: _distanceKm,
      durationMinutes: duration.inMinutes,
      averageSpeedKmh: averageSpeedKmh,
      topSpeedKmh: _topSpeedKmh,
      trackedOnline: _connectivity.isOnline,
    );
    _analytics.addTrip(trip);

    _tripStart = null;
    notifyListeners();
  }

  /// Arms the destination wake-up alarm with a lead distance of [leadKm].
  Future<void> armDestinationAlarm(
    Station destination, {
    required double leadKm,
  }) async {
    final permitted = await _alarms.ensurePermission();
    if (!permitted) return;

    _alarmConfig = DestinationAlarmConfig(
      destination: destination,
      leadKm: leadKm,
      armedAt: DateTime.now(),
    );
    _proximityFired = false;

    final projectedEta = eta;
    if (projectedEta != null) {
      await _alarms.armEtaBackup(
        destinationName: destination.name,
        eta: projectedEta,
      );
    }
    notifyListeners();
  }

  Future<void> disarmDestinationAlarm() async {
    _alarmConfig = null;
    _proximityFired = false;
    await _alarms.cancelAll();
    notifyListeners();
  }

  /// Cell Tower Mode: match the serving tower against the compressed local
  /// lookup table to estimate position without GPS.
  Future<void> _probeCellTower() async {
    final tower = await _cellInfo.getPrimaryTower();
    if (tower == null) {
      _towerMatch = null;
      notifyListeners();
      return;
    }
    final match = await _towers.findMatch(
      mcc: tower.mcc!,
      mnc: tower.mnc!,
      lac: tower.lac!,
      cid: tower.cid!,
    );
    _towerMatch = match ??
        await _towers.findLooseMatch(
          mcc: tower.mcc!,
          mnc: tower.mnc!,
          cid: tower.cid!,
        );
    notifyListeners();
  }

  void _onSample(Position position, double speedKmh) {
    var legMeters = 0.0;
    if (_previousFix != null) {
      legMeters = GeoUtils.haversineMeters(
        _previousFix!.latitude,
        _previousFix!.longitude,
        position.latitude,
        position.longitude,
      );
      // Discard GPS jumps larger than a physically impossible move.
      if (legMeters >= 5000) legMeters = 0.0;
      _distanceKm += legMeters / 1000.0;
    }
    _previousFix = position;

    if (speedKmh > 0.5) {
      _speedSum += speedKmh;
      _movingSamples++;
    }
    if (speedKmh > _topSpeedKmh) _topSpeedKmh = speedKmh;

    _analytics.recordTravelSample(
      distanceKm: legMeters / 1000.0,
      speedKmh: speedKmh,
    );
    if (_connectivity.isOffline) {
      _analytics.recordOfflineFix();
    }

    final now = DateTime.now();
    if (_lastNearestProbe == null ||
        now.difference(_lastNearestProbe!) > const Duration(seconds: 5)) {
      _lastNearestProbe = now;
      unawaited(_probeNearestStation(position));
    }

    _evaluateGeofence();
    notifyListeners();
  }

  Future<void> _probeNearestStation(Position position) async {
    final nearby =
        await _stations.nearestTo(position.latitude, position.longitude, limit: 1);
    if (nearby.isNotEmpty) {
      _nearestStation = nearby.first;
      _nearestDistanceMeters = GeoUtils.haversineMeters(
        position.latitude,
        position.longitude,
        nearby.first.latitude,
        nearby.first.longitude,
      );
      notifyListeners();
    }
  }

  /// Fires the proximity alarm once remaining distance drops under the lead.
  void _evaluateGeofence() {
    final config = _alarmConfig;
    if (config == null || _proximityFired) return;
    final remaining = remainingMeters;
    if (remaining == null) return;
    if (remaining <= config.leadKm * 1000) {
      _proximityFired = true;
      unawaited(
        _alarms.fireProximityAlarm(
          destinationName: config.destination.name,
          leadDescription: config.leadLabel,
        ),
      );
    }
  }
}
