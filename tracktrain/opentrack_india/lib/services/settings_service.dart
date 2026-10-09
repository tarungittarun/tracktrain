import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/enums.dart';

/// Hive-backed user preferences. All keys have safe defaults so a fresh
/// install is immediately usable.
class SettingsService extends ChangeNotifier {
  SettingsService(this._box);

  static const String boxName = 'settings';

  static const String _kTheme = 'theme';
  static const String _kHighContrast = 'highContrast';
  static const String _kTrackingMode = 'trackingMode';
  static const String _kSpeedUnit = 'speedUnit';
  static const String _kCompactTimeline = 'compactTimeline';
  static const String _kLanguage = 'language';
  static const String _kLiveEndpoint = 'liveEndpoint';

  final Box<dynamic> _box;

  AppThemeChoice get theme {
    final index = (_box.get(_kTheme) as int?) ?? AppThemeChoice.system.index;
    return AppThemeChoice
        .values[index.clamp(0, AppThemeChoice.values.length - 1)];
  }

  set theme(AppThemeChoice value) {
    _box.put(_kTheme, value.index);
    notifyListeners();
  }

  bool get highContrast => (_box.get(_kHighContrast) as bool?) ?? false;

  set highContrast(bool value) {
    _box.put(_kHighContrast, value);
    notifyListeners();
  }

  TrackingModeChoice get trackingMode {
    final index =
        (_box.get(_kTrackingMode) as int?) ?? TrackingModeChoice.auto.index;
    return TrackingModeChoice.values[
        index.clamp(0, TrackingModeChoice.values.length - 1)];
  }

  set trackingMode(TrackingModeChoice value) {
    _box.put(_kTrackingMode, value.index);
    notifyListeners();
  }

  SpeedUnitChoice get speedUnit {
    final index = (_box.get(_kSpeedUnit) as int?) ?? SpeedUnitChoice.kmh.index;
    return SpeedUnitChoice
        .values[index.clamp(0, SpeedUnitChoice.values.length - 1)];
  }

  set speedUnit(SpeedUnitChoice value) {
    _box.put(_kSpeedUnit, value.index);
    notifyListeners();
  }

  bool get compactTimeline =>
      (_box.get(_kCompactTimeline) as bool?) ?? false;

  set compactTimeline(bool value) {
    _box.put(_kCompactTimeline, value);
    notifyListeners();
  }

  /// BCP-47 style code or `system` to follow the device locale.
  String get language => (_box.get(_kLanguage) as String?) ?? 'system';

  set language(String value) {
    _box.put(_kLanguage, value);
    notifyListeners();
  }

  Locale? get locale =>
      language == 'system' ? null : Locale(language);

  /// Optional user-supplied endpoint for the live hybrid mode. Empty means
  /// live mode is disabled and offline estimates are used everywhere.
  String get liveEndpoint => (_box.get(_kLiveEndpoint) as String?) ?? '';

  set liveEndpoint(String value) {
    _box.put(_kLiveEndpoint, value);
    notifyListeners();
  }
}
