// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'ओपनट्रॅक इंडिया';

  @override
  String get tagline => 'ऑफलाइन-फर्स्ट रेल्वे ट्रॅकिंग';

  @override
  String get tabTrack => 'ट्रॅक';

  @override
  String get tabLiveStation => 'लाइव्ह स्टेशन';

  @override
  String get tabTimetable => 'वेळापत्रक';

  @override
  String get tabDashboard => 'डॅशबोर्ड';

  @override
  String get searchHint =>
      'गाड्या किंवा स्थानके शोधा (स्पेलिंग चुकीचे असले तरी चालेल)';

  @override
  String get startTracking => 'ट्रॅकिंग सुरू करा';

  @override
  String get stopTracking => 'ट्रॅकिंग थांबवा';

  @override
  String get statusIdle => 'ट्रॅक करण्यास तयार';

  @override
  String get statusAcquiring => 'GPS सिग्नल मिळत आहे…';

  @override
  String get statusTracking => 'प्रवास ट्रॅक होत आहे';

  @override
  String get statusDenied => 'लोकेशन परवानगी नाकारली';

  @override
  String get statusServiceOff => 'लोकेशन सेवा बंद आहेत';

  @override
  String get modeAuto => 'ऑटो';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'सेल टॉवर';

  @override
  String get nearestStation => 'जवळचे स्थानक';

  @override
  String get eta => 'पोहोचण्याची वेळ';

  @override
  String get remaining => 'उरलेले अंतर';

  @override
  String get speed => 'वेग';

  @override
  String get destinationAlarm => 'गंतव्य अलार्म';

  @override
  String get chooseDestination => 'गंतव्य स्थानक निवडा';

  @override
  String get armAlarm => 'अलार्म लावा';

  @override
  String get disarmAlarm => 'अलार्म काढा';

  @override
  String get alarmArmed => 'अलार्म सक्रिय';

  @override
  String get alertLead => 'सूचना अंतर';

  @override
  String get liveStation => 'लाइव्ह स्टेशन';

  @override
  String get nearbyStations => 'जवळची स्थानके';

  @override
  String get trainsHaltHere => 'येथे थांबणाऱ्या गाड्या';

  @override
  String get cellFix => 'सेल टॉवर लोकेशन';

  @override
  String get towerMatched => 'टॉवर मार्गाशी जुळला';

  @override
  String get noTowerMatch => 'सेल टॉवरसाठी ऑफलाइन जुळणी नाही';

  @override
  String get timetable => 'ऑफलाइन वेळापत्रक';

  @override
  String get trainSchedule => 'गाडीचे वेळापत्रक';

  @override
  String get searchStations => 'स्थानके';

  @override
  String get searchTrains => 'गाड्या';

  @override
  String get noResults => 'काहीही सापडले नाही';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'ऑफलाइन डेटासेट: $stations स्थानके · $trains गाड्या';
  }

  @override
  String get dashboard => 'माझा प्रवास आणि वापर';

  @override
  String get localOnlyNote =>
      'सर्व आकडेवारी या फोनवरच साठवली जाते. काहीही बाहेर पाठवले जात नाही.';

  @override
  String get totalDistance => 'कापलेले अंतर';

  @override
  String get avgSpeed => 'सरासरी वेग';

  @override
  String get topSpeed => 'कमाल वेग';

  @override
  String get travelTime => 'प्रवास वेळ';

  @override
  String get sessions => 'सत्रे';

  @override
  String get screenTime => 'स्क्रीन वेळ';

  @override
  String get dataSaved => 'वाचवलेला मोबाईल डेटा';

  @override
  String get offlineUsage => 'ऑफलाइन वापर';

  @override
  String get onlineUsage => 'ऑनलाइन वापर';

  @override
  String get tripHistory => 'प्रवास इतिहास';

  @override
  String get noTrips => 'अजून कोणताही प्रवास ट्रॅक झालेला नाही';

  @override
  String get weeklyTravel => 'मागील ७ दिवस';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeOled => 'OLED पूर्ण काळा';

  @override
  String get highContrast => 'हाय-कॉन्ट्रास्ट आउटडोअर मोड';

  @override
  String get language => 'भाषा';

  @override
  String get trackingMode => 'डीफॉल्ट ट्रॅकिंग मोड';

  @override
  String get speedUnit => 'वेग एकक';

  @override
  String get compactTimeline => 'संक्षिप्त स्थानक टाइमलाइन';

  @override
  String get liveEndpoint => 'लाइव्ह डेटा एंडपॉइंट (ऐच्छिक)';

  @override
  String get liveEndpointHint =>
      'JSON विलंब/फलाट डेटा देणारा बेस URL. रिकामे = फक्त ऑफलाइन.';

  @override
  String get aboutTitle => 'ओपनट्रॅक इंडिया बद्दल';

  @override
  String get aboutBody =>
      'ओपनट्रॅक इंडिया हा मोफत, ऑफलाइन-फर्स्ट रेल्वे सोबती आहे. वेळापत्रक शोध, ट्रॅकिंग आणि अलार्म पूर्णपणे तुमच्या फोनवर चालतात — पेड कीज, जाहिराती, टेलिमेट्री नाही.';

  @override
  String get gpsCorrection => 'GPS घड्याळ दुरुस्ती सक्रिय';

  @override
  String get offlineMode => 'ऑफलाइन मोड';

  @override
  String get onlineMode => 'ऑनलाइन मोड';

  @override
  String get homeStation => 'होम स्टेशन';

  @override
  String get frequentTrain => 'नेहमीची गाडी';

  @override
  String get savedRoute => 'जतन केलेला मार्ग';
}
