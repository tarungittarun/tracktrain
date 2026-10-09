import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Every timetable, delay and scheduling computation in the app is locked to
/// Asia/Kolkata (IST, UTC+5:30) through this clock.
///
/// It also implements GPS-time correction: whenever a satellite fix arrives
/// the delta between the device wall clock and the satellite timestamp is
/// tracked as an exponential moving average. If the user manually altered the
/// phone clock (or it drifted), [correctedNow] exposes the true IST time.
class IstClock {
  IstClock._();

  /// The single source of truth for the Indian time zone.
  static final tz.Location kolkata = tz.getLocation('Asia/Kolkata');

  static Duration _gpsSkew = Duration.zero;
  static bool _hasGpsObservation = false;

  /// Current IST time according to the device clock.
  static tz.TZDateTime now() => tz.TZDateTime.now(kolkata);

  /// Current IST time corrected against GPS satellite timestamps.
  static tz.TZDateTime correctedNow() {
    final correctedDevice = DateTime.now().add(_gpsSkew);
    return tz.TZDateTime.from(correctedDevice, kolkata);
  }

  /// Estimated offset between the device clock and true satellite time.
  static Duration get gpsSkew => _gpsSkew;

  /// True when GPS correction is active and the device clock is off by more
  /// than 30 seconds (i.e. the correction actually matters).
  static bool get hasGpsCorrection =>
      _hasGpsObservation && _gpsSkew.abs() > const Duration(seconds: 30);

  /// Feeds a raw GPS fix timestamp into the skew estimator.
  static void observeGpsTimestamp(DateTime fixTime) {
    final sample = fixTime.toUtc().difference(DateTime.now().toUtc());
    if (!_hasGpsObservation) {
      _gpsSkew = sample;
      _hasGpsObservation = true;
      return;
    }
    final blended =
        _gpsSkew.inMicroseconds * 0.7 + sample.inMicroseconds * 0.3;
    _gpsSkew = Duration(microseconds: blended.round());
  }

  /// Converts any [DateTime] into IST for display or comparison.
  static tz.TZDateTime toIst(DateTime value) =>
      tz.TZDateTime.from(value, kolkata);

  static String formatTime(DateTime value) =>
      DateFormat.Hm().format(toIst(value));

  static String formatDate(DateTime value) =>
      DateFormat.yMMMd().format(toIst(value));

  static String formatDateTime(DateTime value) =>
      DateFormat('d MMM yyyy, HH:mm').format(toIst(value));

  /// "2h 15m" style rendering for durations.
  static String formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}
