import 'package:flutter/services.dart';

/// Thin wrapper over the native `in.opentrack/tracking` channel which starts
/// and stops the Kotlin foreground service. The service keeps the process
/// alive (partial wake lock + persistent notification) so the Dart-side
/// geofence evaluation keeps running while the screen is off, and it is
/// declared with `foregroundServiceType="location"` as required by
/// Android 14/15.
class ForegroundService {
  static const MethodChannel _channel =
      MethodChannel('in.opentrack/tracking');

  bool _running = false;

  bool get isRunning => _running;

  Future<void> start() async {
    if (_running) return;
    try {
      await _channel.invokeMethod<void>('startForeground');
      _running = true;
    } on MissingPluginException {
      _running = false;
    } on PlatformException {
      _running = false;
    }
  }

  Future<void> stop() async {
    if (!_running) return;
    try {
      await _channel.invokeMethod<void>('stopForeground');
    } on MissingPluginException {
      // Already gone.
    } on PlatformException {
      // Best effort; Android will reap the service on task removal anyway.
    }
    _running = false;
  }
}
