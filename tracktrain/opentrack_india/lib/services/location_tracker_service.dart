import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../core/enums.dart';
import '../core/geo_utils.dart';
import '../core/ist_clock.dart';

typedef PositionSampleListener = void Function(
  Position position,
  double speedKmh,
);

/// GPS tracking engine with a live speedometer feed.
///
/// Battery optimization: the distance filter adapts to movement — 40 m while
/// the train is standing at a platform, 15 m in normal motion, 5 m above
/// 40 km/h — so the radio is never polled faster than the journey demands.
class LocationTrackerService extends ChangeNotifier {
  static const double _emaAlpha = 0.35;

  Position? _lastPosition;
  double _smoothedKmh = 0;
  TrackingStatus _status = TrackingStatus.idle;
  int _distanceFilterMeters = 15;
  DateTime _lastSampleAt = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<Position>? _subscription;
  final List<PositionSampleListener> _sampleListeners = [];

  Position? get lastPosition => _lastPosition;
  double get speedKmh => _smoothedKmh;
  TrackingStatus get status => _status;
  bool get isTracking => _status == TrackingStatus.tracking;
  int get distanceFilterMeters => _distanceFilterMeters;

  void addSampleListener(PositionSampleListener listener) =>
      _sampleListeners.add(listener);

  void removeSampleListener(PositionSampleListener listener) =>
      _sampleListeners.remove(listener);

  /// Requests permissions and starts streaming. Returns true when the stream
  /// is live.
  Future<bool> start() async {
    if (_subscription != null) return true;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _status = TrackingStatus.serviceDisabled;
      notifyListeners();
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _status = TrackingStatus.permissionDenied;
      notifyListeners();
      return false;
    }

    _status = TrackingStatus.acquiring;
    notifyListeners();
    await _restartStream();
    return true;
  }

  Future<void> _restartStream() async {
    await _subscription?.cancel();
    _subscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: _distanceFilterMeters,
      ),
    ).listen(
      _onPosition,
      onError: (Object error) {
        _status = TrackingStatus.serviceDisabled;
        notifyListeners();
      },
    );
  }

  void _onPosition(Position position) {
    final now = DateTime.now();
    if (now.difference(_lastSampleAt) < const Duration(milliseconds: 800)) {
      return;
    }
    _lastSampleAt = now;

    IstClock.observeGpsTimestamp(position.timestamp);

    final rawKmh = position.speed.isNegative ? 0.0 : position.speed * 3.6;
    _smoothedKmh = GeoUtils.ema(_smoothedKmh, rawKmh, _emaAlpha);
    if (_smoothedKmh < 1.5) _smoothedKmh = 0.0;

    _lastPosition = position;
    if (_status != TrackingStatus.tracking) {
      _status = TrackingStatus.tracking;
    }
    _adaptPollingRate();

    for (final listener in List<PositionSampleListener>.of(_sampleListeners)) {
      listener(position, _smoothedKmh);
    }
    notifyListeners();
  }

  /// Throttled sensor polling: relax the GPS distance filter while the train
  /// is stationary, tighten it once the train exceeds 40 km/h.
  void _adaptPollingRate() {
    final desired = _smoothedKmh > 40
        ? 5
        : _smoothedKmh > 2
            ? 15
            : 40;
    if (desired != _distanceFilterMeters) {
      _distanceFilterMeters = desired;
      unawaited(_restartStream());
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _smoothedKmh = 0.0;
    _status = TrackingStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _sampleListeners.clear();
    super.dispose();
  }
}
