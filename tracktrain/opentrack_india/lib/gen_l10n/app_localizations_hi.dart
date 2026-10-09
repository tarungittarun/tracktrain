// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'ओपनट्रैक इंडिया';

  @override
  String get tagline => 'ऑफ़लाइन-फ़र्स्ट रेल ट्रैकिंग';

  @override
  String get tabTrack => 'ट्रैक';

  @override
  String get tabLiveStation => 'लाइव स्टेशन';

  @override
  String get tabTimetable => 'समय-सारणी';

  @override
  String get tabDashboard => 'डैशबोर्ड';

  @override
  String get searchHint => 'ट्रेन या स्टेशन खोजें (टाइपो चलेगा)';

  @override
  String get startTracking => 'ट्रैकिंग शुरू करें';

  @override
  String get stopTracking => 'ट्रैकिंग रोकें';

  @override
  String get statusIdle => 'ट्रैक करने के लिए तैयार';

  @override
  String get statusAcquiring => 'GPS सिग्नल मिल रहा है…';

  @override
  String get statusTracking => 'यात्रा ट्रैक हो रही है';

  @override
  String get statusDenied => 'लोकेशन की अनुमति नहीं मिली';

  @override
  String get statusServiceOff => 'लोकेशन सेवा बंद है';

  @override
  String get modeAuto => 'ऑटो';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'सेल टावर';

  @override
  String get nearestStation => 'नज़दीकी स्टेशन';

  @override
  String get eta => 'पहुँचने का समय';

  @override
  String get remaining => 'बची दूरी';

  @override
  String get speed => 'गति';

  @override
  String get destinationAlarm => 'गंतव्य अलार्म';

  @override
  String get chooseDestination => 'गंतव्य स्टेशन चुनें';

  @override
  String get armAlarm => 'अलार्म लगाएँ';

  @override
  String get disarmAlarm => 'अलार्म हटाएँ';

  @override
  String get alarmArmed => 'अलार्म सक्रिय';

  @override
  String get alertLead => 'सूचना दूरी';

  @override
  String get liveStation => 'लाइव स्टेशन';

  @override
  String get nearbyStations => 'आस-पास के स्टेशन';

  @override
  String get trainsHaltHere => 'यहाँ रुकने वाली ट्रेनें';

  @override
  String get cellFix => 'सेल टावर लोकेशन';

  @override
  String get towerMatched => 'टावर रूट से मेल खाया';

  @override
  String get noTowerMatch => 'सेल टावर का ऑफ़लाइन मेल नहीं मिला';

  @override
  String get timetable => 'ऑफ़लाइन समय-सारणी';

  @override
  String get trainSchedule => 'ट्रेन अनुसूची';

  @override
  String get searchStations => 'स्टेशन';

  @override
  String get searchTrains => 'ट्रेनें';

  @override
  String get noResults => 'कोई परिणाम नहीं मिला';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'ऑफ़लाइन डेटासेट: $stations स्टेशन · $trains ट्रेनें';
  }

  @override
  String get dashboard => 'मेरी यात्रा और उपयोग';

  @override
  String get localOnlyNote =>
      'सभी आँकड़े इसी फ़ोन पर संग्रहीत हैं। कुछ भी बाहर नहीं भेजा जाता।';

  @override
  String get totalDistance => 'तय की गई दूरी';

  @override
  String get avgSpeed => 'औसत गति';

  @override
  String get topSpeed => 'अधिकतम गति';

  @override
  String get travelTime => 'यात्रा समय';

  @override
  String get sessions => 'सत्र';

  @override
  String get screenTime => 'स्क्रीन समय';

  @override
  String get dataSaved => 'बचाया गया मोबाइल डेटा';

  @override
  String get offlineUsage => 'ऑफ़लाइन उपयोग';

  @override
  String get onlineUsage => 'ऑनलाइन उपयोग';

  @override
  String get tripHistory => 'यात्रा इतिहास';

  @override
  String get noTrips => 'अभी तक कोई यात्रा ट्रैक नहीं हुई';

  @override
  String get weeklyTravel => 'पिछले 7 दिन';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeOled => 'OLED पूरा काला';

  @override
  String get highContrast => 'उच्च-कंट्रास्ट आउटडोर मोड';

  @override
  String get language => 'भाषा';

  @override
  String get trackingMode => 'डिफ़ॉल्ट ट्रैकिंग मोड';

  @override
  String get speedUnit => 'गति इकाई';

  @override
  String get compactTimeline => 'संक्षिप्त स्टेशन टाइमलाइन';

  @override
  String get liveEndpoint => 'लाइव डेटा एंडपॉइंट (वैकल्पिक)';

  @override
  String get liveEndpointHint =>
      'JSON विलंब/प्लेटफ़ॉर्म डेटा देने वाला बेस URL। खाली = केवल ऑफ़लाइन।';

  @override
  String get aboutTitle => 'ओपनट्रैक इंडिया के बारे में';

  @override
  String get aboutBody =>
      'ओपनट्रैक इंडिया एक मुफ़्त, ऑफ़लाइन-फ़र्स्ट रेल साथी है। समय-सारणी खोज, ट्रैकिंग और अलार्म पूरी तरह आपके फ़ोन पर चलते हैं — न पेड की, न विज्ञापन, न टेलीमेट्री।';

  @override
  String get gpsCorrection => 'GPS घड़ी सुधार सक्रिय';

  @override
  String get offlineMode => 'ऑफ़लाइन मोड';

  @override
  String get onlineMode => 'ऑनलाइन मोड';

  @override
  String get homeStation => 'होम स्टेशन';

  @override
  String get frequentTrain => 'नियमित ट्रेन';

  @override
  String get savedRoute => 'सहेजा गया रूट';
}
