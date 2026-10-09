/// App-wide enumeration types shared across services and UI.
library;

/// Theme choices surfaced in the settings screen.
enum AppThemeChoice {
  system,
  light,
  dark,

  /// Pure-black dark theme for AMOLED panels.
  oled,
}

/// How the dual tracking engine picks its position source.
enum TrackingModeChoice {
  /// GPS when moving, cell-tower fallback when stationary / battery saver.
  auto,
  gpsOnly,
  cellOnly,
}

/// Speedometer display unit.
enum SpeedUnitChoice {
  kmh,
  mph;

  double convertFromKmh(double value) =>
      this == SpeedUnitChoice.kmh ? value : value * 0.621371;

  String get label => this == SpeedUnitChoice.kmh ? 'km/h' : 'mph';
}

/// Lifecycle of the location tracking engine.
enum TrackingStatus {
  idle,
  acquiring,
  tracking,
  permissionDenied,
  serviceDisabled,
}

/// Quick-access card types on the home screen.
enum QuickCardType {
  homeStation,
  frequentTrain,
  savedRoute,
}
