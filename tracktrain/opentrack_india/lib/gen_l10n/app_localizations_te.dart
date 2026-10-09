// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'ఓపెన్‌ట్రాక్ ఇండియా';

  @override
  String get tagline => 'ఆఫ్‌లైన్-ఫస్ట్ రైలు ట్రాకింగ్';

  @override
  String get tabTrack => 'ట్రాక్';

  @override
  String get tabLiveStation => 'లైవ్ స్టేషన్';

  @override
  String get tabTimetable => 'సమయ పట్టిక';

  @override
  String get tabDashboard => 'డాష్‌బోర్డ్';

  @override
  String get searchHint =>
      'రైళ్లు లేదా స్టేషన్లు వెతకండి (స్పెల్లింగ్ తప్పులైనా పర్వాలేదు)';

  @override
  String get startTracking => 'ట్రాకింగ్ ప్రారంభించండి';

  @override
  String get stopTracking => 'ట్రాకింగ్ ఆపండి';

  @override
  String get statusIdle => 'ట్రాక్ చేయడానికి సిద్ధం';

  @override
  String get statusAcquiring => 'GPS సిగ్నల్ వస్తోంది…';

  @override
  String get statusTracking => 'ప్రయాణం ట్రాక్ అవుతోంది';

  @override
  String get statusDenied => 'లొకేషన్ అనుమతి నిరాకరించబడింది';

  @override
  String get statusServiceOff => 'లొకేషన్ సేవలు ఆఫ్‌లో ఉన్నాయి';

  @override
  String get modeAuto => 'ఆటో';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'సెల్ టవర్';

  @override
  String get nearestStation => 'సమీప స్టేషన్';

  @override
  String get eta => 'చేరే సమయం';

  @override
  String get remaining => 'మిగిలిన దూరం';

  @override
  String get speed => 'వేగం';

  @override
  String get destinationAlarm => 'గమ్య అలారం';

  @override
  String get chooseDestination => 'గమ్య స్టేషన్ ఎంచుకోండి';

  @override
  String get armAlarm => 'అలారం పెట్టండి';

  @override
  String get disarmAlarm => 'అలారం తీసేయండి';

  @override
  String get alarmArmed => 'అలారం సక్రియం';

  @override
  String get alertLead => 'హెచ్చరిక దూరం';

  @override
  String get liveStation => 'లైవ్ స్టేషన్';

  @override
  String get nearbyStations => 'దగ్గరి స్టేషన్లు';

  @override
  String get trainsHaltHere => 'ఇక్కడ ఆగే రైళ్లు';

  @override
  String get cellFix => 'సెల్ టవర్ లొకేషన్';

  @override
  String get towerMatched => 'టవర్ మార్గంతో సరిపోలింది';

  @override
  String get noTowerMatch => 'సెల్ టవర్‌కు ఆఫ్‌లైన్ మ్యాచ్ లేదు';

  @override
  String get timetable => 'ఆఫ్‌లైన్ సమయ పట్టిక';

  @override
  String get trainSchedule => 'రైలు షెడ్యూల్';

  @override
  String get searchStations => 'స్టేషన్లు';

  @override
  String get searchTrains => 'రైళ్లు';

  @override
  String get noResults => 'ఫలితాలు లేవు';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'ఆఫ్‌లైన్ డేటాసెట్: $stations స్టేషన్లు · $trains రైళ్లు';
  }

  @override
  String get dashboard => 'నా ప్రయాణం & వినియోగం';

  @override
  String get localOnlyNote =>
      'అన్ని కొలతలు ఈ ఫోన్‌లోనే నిల్వ ఉంటాయి. ఎక్కడికీ పంపబడవు.';

  @override
  String get totalDistance => 'ప్రయాణించిన దూరం';

  @override
  String get avgSpeed => 'సగటు వేగం';

  @override
  String get topSpeed => 'గరిష్ఠ వేగం';

  @override
  String get travelTime => 'ప్రయాణ సమయం';

  @override
  String get sessions => 'సెషన్లు';

  @override
  String get screenTime => 'స్క్రీన్ సమయం';

  @override
  String get dataSaved => 'ఆదా అయిన మొబైల్ డేటా';

  @override
  String get offlineUsage => 'ఆఫ్‌లైన్ వినియోగం';

  @override
  String get onlineUsage => 'ఆన్‌లైన్ వినియోగం';

  @override
  String get tripHistory => 'ప్రయాణ చరిత్ర';

  @override
  String get noTrips => 'ఇంకా ప్రయాణాలు ట్రాక్ కాలేదు';

  @override
  String get weeklyTravel => 'గత 7 రోజులు';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get theme => 'థీమ్';

  @override
  String get themeSystem => 'సిస్టమ్';

  @override
  String get themeLight => 'లైట్';

  @override
  String get themeDark => 'డార్క్';

  @override
  String get themeOled => 'OLED పూర్తి నలుపు';

  @override
  String get highContrast => 'హై-కాంట్రాస్ట్ అవుట్‌డోర్ మోడ్';

  @override
  String get language => 'భాష';

  @override
  String get trackingMode => 'డిఫాల్ట్ ట్రాకింగ్ మోడ్';

  @override
  String get speedUnit => 'వేగ యూనిట్';

  @override
  String get compactTimeline => 'కాంపాక్ట్ స్టేషన్ టైమ్‌లైన్';

  @override
  String get liveEndpoint => 'లైవ్ డేటా ఎండ్‌పాయింట్ (ఐచ్ఛికం)';

  @override
  String get liveEndpointHint =>
      'JSON ఆలస్యం/ప్లాట్‌ఫారమ్ డేటా ఇచ్చే బేస్ URL. ఖాళీ = ఆఫ్‌లైన్ మాత్రమే.';

  @override
  String get aboutTitle => 'ఓపెన్‌ట్రాక్ ఇండియా గురించి';

  @override
  String get aboutBody =>
      'ఓపెన్‌ట్రాక్ ఇండియా ఉచిత, ఆఫ్‌లైన్-ఫస్ట్ రైలు తోడు. సమయ పట్టిక శోధన, ట్రాకింగ్, అలారాలు పూర్తిగా మీ ఫోన్‌లోనే నడుస్తాయి — పెయిడ్ కీలు, ప్రకటనలు, టెలిమెట్రీ లేవు.';

  @override
  String get gpsCorrection => 'GPS గడియార సవరణ సక్రియం';

  @override
  String get offlineMode => 'ఆఫ్‌లైన్ మోడ్';

  @override
  String get onlineMode => 'ఆన్‌లైన్ మోడ్';

  @override
  String get homeStation => 'హోమ్ స్టేషన్';

  @override
  String get frequentTrain => 'తరచు రైలు';

  @override
  String get savedRoute => 'సేవ్ చేసిన మార్గం';
}
