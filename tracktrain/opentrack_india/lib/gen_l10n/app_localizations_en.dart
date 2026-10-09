// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OpenTrack India';

  @override
  String get tagline => 'Offline-first railway tracking';

  @override
  String get tabTrack => 'Track';

  @override
  String get tabLiveStation => 'Live Station';

  @override
  String get tabTimetable => 'Timetable';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get searchHint => 'Search trains or stations (typos OK)';

  @override
  String get startTracking => 'Start tracking';

  @override
  String get stopTracking => 'Stop tracking';

  @override
  String get statusIdle => 'Ready to track';

  @override
  String get statusAcquiring => 'Acquiring GPS fix…';

  @override
  String get statusTracking => 'Tracking journey';

  @override
  String get statusDenied => 'Location permission denied';

  @override
  String get statusServiceOff => 'Location services are off';

  @override
  String get modeAuto => 'Auto';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'Cell tower';

  @override
  String get nearestStation => 'Nearest station';

  @override
  String get eta => 'ETA';

  @override
  String get remaining => 'Remaining';

  @override
  String get speed => 'Speed';

  @override
  String get destinationAlarm => 'Destination alarm';

  @override
  String get chooseDestination => 'Choose destination station';

  @override
  String get armAlarm => 'Arm alarm';

  @override
  String get disarmAlarm => 'Disarm alarm';

  @override
  String get alarmArmed => 'Alarm armed';

  @override
  String get alertLead => 'Alert distance';

  @override
  String get liveStation => 'Live station';

  @override
  String get nearbyStations => 'Nearby stations';

  @override
  String get trainsHaltHere => 'Trains halting here';

  @override
  String get cellFix => 'Cell tower fix';

  @override
  String get towerMatched => 'Tower matched to route segment';

  @override
  String get noTowerMatch => 'No offline match for serving tower';

  @override
  String get timetable => 'Offline timetable';

  @override
  String get trainSchedule => 'Train schedule';

  @override
  String get searchStations => 'Stations';

  @override
  String get searchTrains => 'Trains';

  @override
  String get noResults => 'No matches found';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'Offline dataset: $stations stations · $trains trains';
  }

  @override
  String get dashboard => 'My travel & usage';

  @override
  String get localOnlyNote =>
      'All metrics are stored on this device. Nothing is ever sent anywhere.';

  @override
  String get totalDistance => 'Distance tracked';

  @override
  String get avgSpeed => 'Average speed';

  @override
  String get topSpeed => 'Top speed';

  @override
  String get travelTime => 'Travel time';

  @override
  String get sessions => 'Sessions';

  @override
  String get screenTime => 'Screen time';

  @override
  String get dataSaved => 'Mobile data saved';

  @override
  String get offlineUsage => 'Offline usage';

  @override
  String get onlineUsage => 'Online usage';

  @override
  String get tripHistory => 'Trip history';

  @override
  String get noTrips => 'No journeys tracked yet';

  @override
  String get weeklyTravel => 'Last 7 days';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED pure black';

  @override
  String get highContrast => 'High-contrast outdoor mode';

  @override
  String get language => 'Language';

  @override
  String get trackingMode => 'Default tracking mode';

  @override
  String get speedUnit => 'Speed unit';

  @override
  String get compactTimeline => 'Compact station timeline';

  @override
  String get liveEndpoint => 'Live data endpoint (optional)';

  @override
  String get liveEndpointHint =>
      'Base URL returning JSON delay/platform data. Empty means offline-only.';

  @override
  String get aboutTitle => 'About OpenTrack India';

  @override
  String get aboutBody =>
      'OpenTrack India is a free, offline-first railway companion. Timetable searches, tracking and alarms run entirely on your phone — no paid keys, no ads, no telemetry.';

  @override
  String get gpsCorrection => 'GPS clock correction active';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get onlineMode => 'Online mode';

  @override
  String get homeStation => 'Home station';

  @override
  String get frequentTrain => 'Frequent train';

  @override
  String get savedRoute => 'Saved route';
}
