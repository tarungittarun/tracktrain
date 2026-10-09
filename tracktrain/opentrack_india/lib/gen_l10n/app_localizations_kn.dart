// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appName => 'ಓಪನ್‌ಟ್ರ್ಯಾಕ್ ಇಂಡಿಯಾ';

  @override
  String get tagline => 'ಆಫ್‌ಲೈನ್-ಫಸ್ಟ್ ರೈಲು ಟ್ರ್ಯಾಕಿಂಗ್';

  @override
  String get tabTrack => 'ಟ್ರ್ಯಾಕ್';

  @override
  String get tabLiveStation => 'ಲೈವ್ ನಿಲ್ದಾಣ';

  @override
  String get tabTimetable => 'ಸಮಯಪಟ್ಟಿ';

  @override
  String get tabDashboard => 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';

  @override
  String get searchHint =>
      'ರೈಲುಗಳು ಅಥವಾ ನಿಲ್ದಾಣಗಳನ್ನು ಹುಡುಕಿ (ಕಾಗುಣಿತ ತಪ್ಪಾದರೂ ಪರವಾಗಿಲ್ಲ)';

  @override
  String get startTracking => 'ಟ್ರ್ಯಾಕಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get stopTracking => 'ಟ್ರ್ಯಾಕಿಂಗ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get statusIdle => 'ಟ್ರ್ಯಾಕ್ ಮಾಡಲು ಸಿದ್ಧ';

  @override
  String get statusAcquiring => 'GPS ಸಿಗ್ನಲ್ ಬರುತ್ತಿದೆ…';

  @override
  String get statusTracking => 'ಪ್ರಯಾಣ ಟ್ರ್ಯಾಕ್ ಆಗುತ್ತಿದೆ';

  @override
  String get statusDenied => 'ಸ್ಥಳ ಅನುಮತಿ ನಿರಾಕರಿಸಲಾಗಿದೆ';

  @override
  String get statusServiceOff => 'ಸ್ಥಳ ಸೇವೆಗಳು ಆಫ್ ಆಗಿವೆ';

  @override
  String get modeAuto => 'ಆಟೋ';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'ಸೆಲ್ ಟವರ್';

  @override
  String get nearestStation => 'ಹತ್ತಿರದ ನಿಲ್ದಾಣ';

  @override
  String get eta => 'ತಲುಪುವ ಸಮಯ';

  @override
  String get remaining => 'ಉಳಿದ ದೂರ';

  @override
  String get speed => 'ವೇಗ';

  @override
  String get destinationAlarm => 'ಗಮ್ಯ ಅಲಾರಂ';

  @override
  String get chooseDestination => 'ಗಮ್ಯ ನಿಲ್ದಾಣ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get armAlarm => 'ಅಲಾರಂ ಹಾಕಿ';

  @override
  String get disarmAlarm => 'ಅಲಾರಂ ತೆಗೆಯಿರಿ';

  @override
  String get alarmArmed => 'ಅಲಾರಂ ಸಕ್ರಿಯ';

  @override
  String get alertLead => 'ಎಚ್ಚರಿಕೆ ದೂರ';

  @override
  String get liveStation => 'ಲೈವ್ ನಿಲ್ದಾಣ';

  @override
  String get nearbyStations => 'ಸಮೀಪದ ನಿಲ್ದಾಣಗಳು';

  @override
  String get trainsHaltHere => 'ಇಲ್ಲಿ ನಿಲ್ಲುವ ರೈಲುಗಳು';

  @override
  String get cellFix => 'ಸೆಲ್ ಟವರ್ ಸ್ಥಳ';

  @override
  String get towerMatched => 'ಟವರ್ ಮಾರ್ಗಕ್ಕೆ ಹೊಂದಿಕೆಯಾಗಿದೆ';

  @override
  String get noTowerMatch => 'ಸೆಲ್ ಟವರ್‌ಗೆ ಆಫ್‌ಲೈನ್ ಹೊಂದಾಣಿಕೆ ಇಲ್ಲ';

  @override
  String get timetable => 'ಆಫ್‌ಲೈನ್ ಸಮಯಪಟ್ಟಿ';

  @override
  String get trainSchedule => 'ರೈಲು ವೇಳಾಪಟ್ಟಿ';

  @override
  String get searchStations => 'ನಿಲ್ದಾಣಗಳು';

  @override
  String get searchTrains => 'ರೈಲುಗಳು';

  @override
  String get noResults => 'ಫಲಿತಾಂಶಗಳಿಲ್ಲ';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'ಆಫ್‌ಲೈನ್ ಡೇಟಾಸೆಟ್: $stations ನಿಲ್ದಾಣಗಳು · $trains ರೈಲುಗಳು';
  }

  @override
  String get dashboard => 'ನನ್ನ ಪ್ರಯಾಣ & ಬಳಕೆ';

  @override
  String get localOnlyNote =>
      'ಎಲ್ಲಾ ಅಳತೆಗಳು ಈ ಫೋನ್‌ನಲ್ಲೇ ಸಂಗ್ರಹವಾಗಿವೆ. ಎಲ್ಲಿಗೂ ಕಳುಹಿಸಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get totalDistance => 'ಕ್ರಮಿಸಿದ ದೂರ';

  @override
  String get avgSpeed => 'ಸರಾಸರಿ ವೇಗ';

  @override
  String get topSpeed => 'ಗರಿಷ್ಠ ವೇಗ';

  @override
  String get travelTime => 'ಪ್ರಯಾಣ ಸಮಯ';

  @override
  String get sessions => 'ಸೆಶನ್‌ಗಳು';

  @override
  String get screenTime => 'ಸ್ಕ್ರೀನ್ ಸಮಯ';

  @override
  String get dataSaved => 'ಉಳಿಸಿದ ಮೊಬೈಲ್ ಡೇಟಾ';

  @override
  String get offlineUsage => 'ಆಫ್‌ಲೈನ್ ಬಳಕೆ';

  @override
  String get onlineUsage => 'ಆನ್‌ಲೈನ್ ಬಳಕೆ';

  @override
  String get tripHistory => 'ಪ್ರಯಾಣ ಇತಿಹಾಸ';

  @override
  String get noTrips => 'ಇನ್ನೂ ಯಾವ ಪ್ರಯಾಣವೂ ಟ್ರ್ಯಾಕ್ ಆಗಿಲ್ಲ';

  @override
  String get weeklyTravel => 'ಕಳೆದ 7 ದಿನಗಳು';

  @override
  String get settings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get theme => 'ಥೀಮ್';

  @override
  String get themeSystem => 'ಸಿಸ್ಟಮ್';

  @override
  String get themeLight => 'ಲೈಟ್';

  @override
  String get themeDark => 'ಡಾರ್ಕ್';

  @override
  String get themeOled => 'OLED ಸಂಪೂರ್ಣ ಕಪ್ಪು';

  @override
  String get highContrast => 'ಹೈ-ಕಾಂಟ್ರಾಸ್ಟ್ ಔಟ್‌ಡೋರ್ ಮೋಡ್';

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String get trackingMode => 'ಡೀಫಾಲ್ಟ್ ಟ್ರ್ಯಾಕಿಂಗ್ ಮೋಡ್';

  @override
  String get speedUnit => 'ವೇಗ ಘಟಕ';

  @override
  String get compactTimeline => 'ಕಾಂಪ್ಯಾಕ್ಟ್ ನಿಲ್ದಾಣ ಟೈಮ್‌ಲೈನ್';

  @override
  String get liveEndpoint => 'ಲೈವ್ ಡೇಟಾ ಎಂಡ್‌ಪಾಯಿಂಟ್ (ಐಚ್ಛಿಕ)';

  @override
  String get liveEndpointHint =>
      'JSON ವಿಳಂಬ/ಪ್ಲಾಟ್‌ಫಾರ್ಮ ಡೇಟಾ ನೀಡುವ ಬೇಸ್ URL. ಖಾಲಿ = ಆಫ್‌ಲೈನ್ ಮಾತ್ರ.';

  @override
  String get aboutTitle => 'ಓಪನ್‌ಟ್ರ್ಯಾಕ್ ಇಂಡಿಯಾ ಬಗ್ಗೆ';

  @override
  String get aboutBody =>
      'ಓಪನ್‌ಟ್ರ್ಯಾಕ್ ಇಂಡಿಯಾ ಉಚಿತ, ಆಫ್‌ಲೈನ್-ಫಸ್ಟ್ ರೈಲು ಸಂಗಾತಿ. ಸಮಯಪಟ್ಟಿ ಹುಡುಕಾಟ, ಟ್ರ್ಯಾಕಿಂಗ್ ಮತ್ತು ಅಲಾರಂಗಳು ಸಂಪೂರ್ಣವಾಗಿ ನಿಮ್ಮ ಫೋನ್‌ನಲ್ಲಿಯೇ ನಡೆಯುತ್ತವೆ — ಪೇಯ್ಡ್ ಕೀಗಳು, ಜಾಹೀರಾತು, ಟೆಲಿಮೆಟ್ರಿ ಇಲ್ಲ.';

  @override
  String get gpsCorrection => 'GPS ಗಡಿಯಾರ ತಿದ್ದುಪಡಿ ಸಕ್ರಿಯ';

  @override
  String get offlineMode => 'ಆಫ್‌ಲೈನ್ ಮೋಡ್';

  @override
  String get onlineMode => 'ಆನ್‌ಲೈನ್ ಮೋಡ್';

  @override
  String get homeStation => 'ಹೋಮ್ ನಿಲ್ದಾಣ';

  @override
  String get frequentTrain => 'ನಿಯಮಿತ ರೈಲು';

  @override
  String get savedRoute => 'ಉಳಿಸಿದ ಮಾರ್ಗ';
}
