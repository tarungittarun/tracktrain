import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../core/ist_clock.dart';
import '../data/models/hive_records.dart';

/// Aggregate roll-up consumed by the dashboard screen.
class DashboardTotals {
  const DashboardTotals({
    required this.totalDistanceKm,
    required this.averageSpeedKmh,
    required this.topSpeedKmh,
    required this.travelMinutes,
    required this.sessions,
    required this.screenSeconds,
    required this.offlineSeconds,
    required this.onlineSeconds,
    required this.searches,
    required this.dataSavedBytes,
    required this.tripCount,
  });

  final double totalDistanceKm;
  final double averageSpeedKmh;
  final double topSpeedKmh;
  final int travelMinutes;
  final int sessions;
  final int screenSeconds;
  final int offlineSeconds;
  final int onlineSeconds;
  final int searches;
  final int dataSavedBytes;
  final int tripCount;

  String get dataSavedDisplay {
    final mb = dataSavedBytes / (1024 * 1024);
    if (mb < 1) return '${(dataSavedBytes / 1024).round()} KB';
    return mb >= 100 ? '${mb.round()} MB' : '${mb.toStringAsFixed(1)} MB';
  }

  Duration get screenTime => Duration(seconds: screenSeconds);
}

/// 100% on-device analytics. Every metric lives in Hive boxes on the phone;
/// nothing is ever transmitted anywhere — this class has no network imports
/// at all.
class UsageAnalyticsService {
  UsageAnalyticsService(this._usageBox, this._tripsBox);

  static const String usageBoxName = 'usage_daily';
  static const String tripsBoxName = 'trips';

  /// Heuristic costs avoided by staying offline (documented in README).
  static const int bytesPerOfflineSearch = 8 * 1024;
  static const int bytesPerOfflineFix = 25 * 1024;

  static const Duration _heartbeatInterval = Duration(seconds: 15);

  final Box<DailyUsage> _usageBox;
  final Box<TripRecord> _tripsBox;

  Timer? _heartbeat;
  DateTime? _sessionStart;
  bool _currentlyOnline = false;

  /// Bumped after every mutation so dashboard providers can rebuild.
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  String get _todayKey => DateFormat('yyyy-MM-dd').format(IstClock.now());

  DailyUsage _today() {
    var usage = _usageBox.get(_todayKey);
    if (usage == null) {
      usage = DailyUsage(dateKey: _todayKey);
      _usageBox.put(_todayKey, usage);
    }
    return usage;
  }

  void _save(DailyUsage usage) {
    _usageBox.put(usage.dateKey, usage);
    version.value++;
  }

  void beginSession() {
    _sessionStart = DateTime.now();
    final usage = _today();
    usage.sessions++;
    _save(usage);
    _heartbeat ??= Timer.periodic(_heartbeatInterval, _onHeartbeat);
  }

  void setOnlineMode(bool online) => _currentlyOnline = online;

  void _onHeartbeat(Timer timer) {
    if (_sessionStart == null) return;
    final usage = _today();
    usage.screenSeconds += _heartbeatInterval.inSeconds;
    if (_currentlyOnline) {
      usage.onlineSeconds += _heartbeatInterval.inSeconds;
    } else {
      usage.offlineSeconds += _heartbeatInterval.inSeconds;
    }
    _save(usage);
  }

  void endSession() {
    _sessionStart = null;
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  void recordSearch() {
    final usage = _today();
    usage.searches++;
    usage.dataSavedBytes += bytesPerOfflineSearch;
    _save(usage);
  }

  void recordOfflineFix() {
    final usage = _today();
    usage.dataSavedBytes += bytesPerOfflineFix;
    _save(usage);
  }

  void recordTravelSample({
    required double distanceKm,
    required double speedKmh,
  }) {
    final usage = _today();
    usage.distanceKm += distanceKm;
    if (speedKmh > usage.topSpeedKmh) usage.topSpeedKmh = speedKmh;
    _save(usage);
  }

  void addTrip(TripRecord trip) {
    _tripsBox.put(trip.id, trip);
    version.value++;
  }

  void deleteTrip(String id) {
    _tripsBox.delete(id);
    version.value++;
  }

  List<TripRecord> trips() {
    final list = _tripsBox.values.toList()
      ..sort((a, b) => b.startedAtMillis.compareTo(a.startedAtMillis));
    return list;
  }

  /// Distance per day for the last [days] days (oldest first) for the bar
  /// chart. Keys are `dd MMM`.
  List<(String label, double km)> weeklyDistance({int days = 7}) {
    final result = <(String, double)>[];
    final now = IstClock.now();
    for (var i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(day);
      final usage = _usageBox.get(key);
      result.add((DateFormat('dd MMM').format(day), usage?.distanceKm ?? 0));
    }
    return result;
  }

  DashboardTotals totals() {
    var screenSeconds = 0;
    var offlineSeconds = 0;
    var onlineSeconds = 0;
    var sessions = 0;
    var searches = 0;
    var dataSavedBytes = 0;
    var distanceKm = 0.0;
    var topSpeedKmh = 0.0;

    for (final usage in _usageBox.values) {
      screenSeconds += usage.screenSeconds;
      offlineSeconds += usage.offlineSeconds;
      onlineSeconds += usage.onlineSeconds;
      sessions += usage.sessions;
      searches += usage.searches;
      dataSavedBytes += usage.dataSavedBytes;
      distanceKm += usage.distanceKm;
      if (usage.topSpeedKmh > topSpeedKmh) {
        topSpeedKmh = usage.topSpeedKmh;
      }
    }

    var travelMinutes = 0;
    var weightedSpeed = 0.0;
    final trips = _tripsBox.values;
    for (final trip in trips) {
      travelMinutes += trip.durationMinutes;
      weightedSpeed += trip.averageSpeedKmh * trip.distanceKm;
    }
    final averageSpeedKmh =
        distanceKm > 0 ? weightedSpeed / distanceKm.clamp(0.1, double.infinity) : 0.0;

    return DashboardTotals(
      totalDistanceKm: distanceKm,
      averageSpeedKmh: averageSpeedKmh,
      topSpeedKmh: topSpeedKmh,
      travelMinutes: travelMinutes,
      sessions: sessions,
      screenSeconds: screenSeconds,
      offlineSeconds: offlineSeconds,
      onlineSeconds: onlineSeconds,
      searches: searches,
      dataSavedBytes: dataSavedBytes,
      tripCount: trips.length,
    );
  }
}
