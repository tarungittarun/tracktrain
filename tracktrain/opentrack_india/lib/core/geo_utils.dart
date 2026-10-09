import 'dart:math' as math;

/// Geodesic helpers used by the tracking engine and the UI.
class GeoUtils {
  GeoUtils._();

  static const double earthRadiusMeters = 6371000.0;

  /// Indian railways rarely run straight between two points; this factor is
  /// applied to great-circle distances when estimating remaining track
  /// distance for ETAs.
  static const double railRouteFactor = 1.2;

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;

  /// Great-circle distance in meters (haversine formula).
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Initial great-circle bearing from point 1 to point 2, in degrees [0,360).
  static double bearingDegrees(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final p1 = _toRadians(lat1);
    final p2 = _toRadians(lat2);
    final dLon = _toRadians(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(p2);
    final x = math.cos(p1) * math.sin(p2) -
        math.sin(p1) * math.cos(p2) * math.cos(dLon);
    final theta = math.atan2(y, x);
    return (theta * 180.0 / math.pi + 360.0) % 360.0;
  }

  /// Cardinal direction label for a bearing.
  static String cardinal(double bearing) {
    const names = [
      'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW',
    ];
    final index = ((bearing + 22.5) % 360 / 45).floor();
    return names[index % 8];
  }

  /// Straight-line meters adjusted to approximate real rail track length.
  static double railDistanceMeters(double straightMeters) =>
      straightMeters * railRouteFactor;

  /// ETA for a remaining rail distance at the given speed, floored at
  /// [minSpeedKmh] so a stopped train never projects an infinite arrival.
  static Duration etaForDistance(
    double meters, {
    required double speedKmh,
    double minSpeedKmh = 25.0,
  }) {
    final effective = math.max(speedKmh, minSpeedKmh);
    final hours = meters / 1000.0 / effective;
    return Duration(seconds: (hours * 3600).round());
  }

  /// "12.4 km" / "850 m" style rendering.
  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    final km = meters / 1000;
    return km >= 100 ? '${km.round()} km' : '${km.toStringAsFixed(1)} km';
  }

  /// Exponential moving average helper for smoothing speed samples.
  static double ema(double previous, double sample, double alpha) =>
      previous + alpha * (sample - previous);
}
