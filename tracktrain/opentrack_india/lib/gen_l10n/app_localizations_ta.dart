// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'ஓபன்ட்ராக் இந்தியா';

  @override
  String get tagline => 'ஆஃப்லைன்-ஃபர்ஸ்ட் ரயில் கண்காணிப்பு';

  @override
  String get tabTrack => 'டிராக்';

  @override
  String get tabLiveStation => 'நேரலை நிலையம்';

  @override
  String get tabTimetable => 'கால அட்டவணை';

  @override
  String get tabDashboard => 'டாஷ்போர்டு';

  @override
  String get searchHint =>
      'ரயில்கள் அல்லது நிலையங்களைத் தேடுங்கள் (எழுத்துப்பிழை பரவாயில்லை)';

  @override
  String get startTracking => 'கண்காணிப்பைத் தொடங்கு';

  @override
  String get stopTracking => 'கண்காணிப்பை நிறுத்து';

  @override
  String get statusIdle => 'கண்காணிக்கத் தயார்';

  @override
  String get statusAcquiring => 'GPS சிக்னல் பெறப்படுகிறது…';

  @override
  String get statusTracking => 'பயணம் கண்காணிக்கப்படுகிறது';

  @override
  String get statusDenied => 'இருப்பிட அனுமதி மறுக்கப்பட்டது';

  @override
  String get statusServiceOff => 'இருப்பிட சேவைகள் முடக்கப்பட்டுள்ளன';

  @override
  String get modeAuto => 'ஆட்டோ';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'செல் கோபுரம்';

  @override
  String get nearestStation => 'அருகிலுள்ள நிலையம்';

  @override
  String get eta => 'வந்தடையும் நேரம்';

  @override
  String get remaining => 'மீதமுள்ள தூரம்';

  @override
  String get speed => 'வேகம்';

  @override
  String get destinationAlarm => 'இலக்கு அலாரம்';

  @override
  String get chooseDestination => 'இலக்கு நிலையத்தைத் தேர்வுசெய்க';

  @override
  String get armAlarm => 'அலாரம் அமை';

  @override
  String get disarmAlarm => 'அலாரம் நீக்கு';

  @override
  String get alarmArmed => 'அலாரம் செயலில்';

  @override
  String get alertLead => 'எச்சரிக்கை தூரம்';

  @override
  String get liveStation => 'நேரலை நிலையம்';

  @override
  String get nearbyStations => 'அருகிலுள்ள நிலையங்கள்';

  @override
  String get trainsHaltHere => 'இங்கு நிற்கும் ரயில்கள்';

  @override
  String get cellFix => 'செல் கோபுர இருப்பிடம்';

  @override
  String get towerMatched => 'கோபுரம் வழித்தடத்துடன் பொருந்தியது';

  @override
  String get noTowerMatch => 'செல் கோபுரத்திற்கு ஆஃப்லைன் பொருத்தம் இல்லை';

  @override
  String get timetable => 'ஆஃப்லைன் கால அட்டவணை';

  @override
  String get trainSchedule => 'ரயில் அட்டவணை';

  @override
  String get searchStations => 'நிலையங்கள்';

  @override
  String get searchTrains => 'ரயில்கள்';

  @override
  String get noResults => 'முடிவுகள் இல்லை';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'ஆஃப்லைன் தரவு: $stations நிலையங்கள் · $trains ரயில்கள்';
  }

  @override
  String get dashboard => 'என் பயணம் & பயன்பாடு';

  @override
  String get localOnlyNote =>
      'அனைத்து அளவீடுகளும் இந்த ஃபோனிலேயே சேமிக்கப்படுகின்றன. எங்கும் அனுப்பப்படுவதில்லை.';

  @override
  String get totalDistance => 'கடந்த தூரம்';

  @override
  String get avgSpeed => 'சராசரி வேகம்';

  @override
  String get topSpeed => 'அதிகபட்ச வேகம்';

  @override
  String get travelTime => 'பயண நேரம்';

  @override
  String get sessions => 'அமர்வுகள்';

  @override
  String get screenTime => 'திரை நேரம்';

  @override
  String get dataSaved => 'சேமிக்கப்பட்ட மொபைல் டேட்டா';

  @override
  String get offlineUsage => 'ஆஃப்லைன் பயன்பாடு';

  @override
  String get onlineUsage => 'ஆன்லைன் பயன்பாடு';

  @override
  String get tripHistory => 'பயண வரலாறு';

  @override
  String get noTrips => 'இன்னும் பயணங்கள் கண்காணிக்கப்படவில்லை';

  @override
  String get weeklyTravel => 'கடந்த 7 நாட்கள்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get theme => 'தீம்';

  @override
  String get themeSystem => 'சிஸ்டம்';

  @override
  String get themeLight => 'லைட்';

  @override
  String get themeDark => 'டார்க்';

  @override
  String get themeOled => 'OLED முழு கருப்பு';

  @override
  String get highContrast => 'அதிக-மாறுபாடு வெளிப்புற முறை';

  @override
  String get language => 'மொழி';

  @override
  String get trackingMode => 'இயல்புநிலை கண்காணிப்பு முறை';

  @override
  String get speedUnit => 'வேக அலகு';

  @override
  String get compactTimeline => 'சுருக்கமான நிலைய காலவரிசை';

  @override
  String get liveEndpoint => 'நேரலை தரவு முனை (விருப்பம்)';

  @override
  String get liveEndpointHint =>
      'JSON தாமதம்/மேடை தரவைத் தரும் அடிப்படை URL. காலி = ஆஃப்லைன் மட்டும்.';

  @override
  String get aboutTitle => 'ஓபென்ட்ராக் இந்தியா பற்றி';

  @override
  String get aboutBody =>
      'ஓபென்ட்ராக் இந்தியா ஒரு இலவச, ஆஃப்லைன்-ஃபர்ஸ்ட் ரயில் துணை. அட்டவணை தேடல், கண்காணிப்பு, அலாரங்கள் அனைத்தும் உங்கள் ஃபோனிலேயே இயங்கும் — கட்டண கீகள், விளம்பரங்கள், டெலிமெட்ரி இல்லை.';

  @override
  String get gpsCorrection => 'GPS கடிகாரத் திருத்தம் செயலில்';

  @override
  String get offlineMode => 'ஆஃப்லைன் முறை';

  @override
  String get onlineMode => 'ஆன்லைன் முறை';

  @override
  String get homeStation => 'முகப்பு நிலையம்';

  @override
  String get frequentTrain => 'அடிக்கடி பயன்படுத்தும் ரயில்';

  @override
  String get savedRoute => 'சேமிக்கப்பட்ட வழித்தடம்';
}
