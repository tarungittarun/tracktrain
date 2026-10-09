import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/ist_clock.dart';

/// Destination wake-up alarms.
///
/// Two layers keep the alarm reliable:
///  1. A scheduled notification fired via AlarmManager (`zonedSchedule` with
///     exact-while-idle semantics) at the projected arrival time — survives
///     the app being in the background and device doze.
///  2. A proximity check inside the tracking loop that fires a full-screen
///     intent the moment the remaining rail distance drops under the user's
///     chosen lead (5 km / 10 km), even earlier than the ETA backup.
///
/// All scheduling is computed in IST.
class GeofenceAlarmService {
  static const String channelId = 'destination_alarm';
  static const String channelName = 'Destination arrival alarms';
  static const String channelDescription =
      'High-priority wake-up alarms fired as your train approaches the '
      'selected destination station.';
  static const int scheduledAlarmId = 4001;
  static const int proximityAlarmId = 4002;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
      ),
    );
    _initialized = true;
  }

  /// Asks for POST_NOTIFICATIONS on Android 13+; returns true when allowed.
  Future<bool> ensurePermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    try {
      return await android.requestNotificationsPermission() ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Schedules the ETA-based backup alarm at [eta] (converted to IST).
  Future<void> armEtaBackup({
    required String destinationName,
    required DateTime eta,
  }) async {
    await init();
    final fireAt = IstClock.toIst(eta);
    if (!fireAt.isAfter(IstClock.correctedNow())) return;
    await _plugin.zonedSchedule(
      scheduledAlarmId,
      'Approaching $destinationName',
      'Wake up — your destination is near. Please check your belongings.',
      fireAt,
      _alarmDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Fires the immediate proximity alarm (full-screen intent).
  Future<void> fireProximityAlarm({
    required String destinationName,
    required String leadDescription,
  }) async {
    await init();
    await _plugin.show(
      proximityAlarmId,
      'Arriving at $destinationName',
      'Less than $leadDescription to go. Time to pack up and move to the '
          'door.',
      _alarmDetails(),
    );
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancel(scheduledAlarmId);
    await _plugin.cancel(proximityAlarmId);
  }

  NotificationDetails _alarmDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          autoCancel: false,
          ongoing: true,
          playSound: true,
          enableVibration: true,
        ),
      );
}
