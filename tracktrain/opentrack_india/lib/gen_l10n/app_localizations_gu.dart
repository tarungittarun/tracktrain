// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'ઓપનટ્રેક ઇન્ડિયા';

  @override
  String get tagline => 'ઓફલાઇન-ફર્સ્ટ રેલ્વે ટ્રેકિંગ';

  @override
  String get tabTrack => 'ટ્રેક';

  @override
  String get tabLiveStation => 'લાઇવ સ્ટેશન';

  @override
  String get tabTimetable => 'સમયપત્રક';

  @override
  String get tabDashboard => 'ડેશબોર્ડ';

  @override
  String get searchHint => 'ટ્રેનો અથવા સ્ટેશનો શોધો (જોડણી ભૂલ ચાલશે)';

  @override
  String get startTracking => 'ટ્રેકિંગ શરૂ કરો';

  @override
  String get stopTracking => 'ટ્રેકિંગ બંધ કરો';

  @override
  String get statusIdle => 'ટ્રેક કરવા તૈયાર';

  @override
  String get statusAcquiring => 'GPS સિગ્નલ મળી રહ્યું છે…';

  @override
  String get statusTracking => 'મુસાફરી ટ્રેક થાય છે';

  @override
  String get statusDenied => 'લોકેશનની પરવાનગી નકારાઈ';

  @override
  String get statusServiceOff => 'લોકેશન સેવાઓ બંધ છે';

  @override
  String get modeAuto => 'ઓટો';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'સેલ ટાવર';

  @override
  String get nearestStation => 'નજીકનું સ્ટેશન';

  @override
  String get eta => 'પહોંચવાનો સમય';

  @override
  String get remaining => 'બાકી અંતર';

  @override
  String get speed => 'ઝડપ';

  @override
  String get destinationAlarm => 'મુકામ એલાર્મ';

  @override
  String get chooseDestination => 'મુકામ સ્ટેશન પસંદ કરો';

  @override
  String get armAlarm => 'એલાર્મ લગાવો';

  @override
  String get disarmAlarm => 'એલાર્મ દૂર કરો';

  @override
  String get alarmArmed => 'એલાર્મ સક્રિય';

  @override
  String get alertLead => 'સૂચના અંતર';

  @override
  String get liveStation => 'લાઇવ સ્ટેશન';

  @override
  String get nearbyStations => 'નજીકનાં સ્ટેશનો';

  @override
  String get trainsHaltHere => 'અહીં ઊભી રહેતી ટ્રેનો';

  @override
  String get cellFix => 'સેલ ટાવર લોકેશન';

  @override
  String get towerMatched => 'ટાવર માર્ગ સાથે મેચ થયો';

  @override
  String get noTowerMatch => 'સેલ ટાવર માટે ઓફલાઇન મેચ નથી';

  @override
  String get timetable => 'ઓફલાઇન સમયપત્રક';

  @override
  String get trainSchedule => 'ટ્રેન સમયપત્રક';

  @override
  String get searchStations => 'સ્ટેશનો';

  @override
  String get searchTrains => 'ટ્રેનો';

  @override
  String get noResults => 'કોઈ પરિણામ મળ્યું નથી';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'ઓફલાઇન ડેટાસેટ: $stations સ્ટેશનો · $trains ટ્રેનો';
  }

  @override
  String get dashboard => 'મારી મુસાફરી અને ઉપયોગ';

  @override
  String get localOnlyNote =>
      'બધા આંકડા આ ફોનમાં જ સંગ્રહાય છે. કંઈ પણ બહાર મોકલાતું નથી.';

  @override
  String get totalDistance => 'કાપેલું અંતર';

  @override
  String get avgSpeed => 'સરેરાશ ઝડપ';

  @override
  String get topSpeed => 'મહત્તમ ઝડપ';

  @override
  String get travelTime => 'મુસાફરી સમય';

  @override
  String get sessions => 'સત્રો';

  @override
  String get screenTime => 'સ્ક્રીન સમય';

  @override
  String get dataSaved => 'બચાવેલો મોબાઇલ ડેટા';

  @override
  String get offlineUsage => 'ઓફલાઇન ઉપયોગ';

  @override
  String get onlineUsage => 'ઓનલાઇન ઉપયોગ';

  @override
  String get tripHistory => 'મુસાફરી ઇતિહાસ';

  @override
  String get noTrips => 'હજી સુધી કોઈ મુસાફરી ટ્રેક થઈ નથી';

  @override
  String get weeklyTravel => 'છેલ્લા 7 દિવસ';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get theme => 'થીમ';

  @override
  String get themeSystem => 'સિસ્ટમ';

  @override
  String get themeLight => 'લાઇટ';

  @override
  String get themeDark => 'ડાર્ક';

  @override
  String get themeOled => 'OLED સંપૂર્ણ કાળું';

  @override
  String get highContrast => 'હાઇ-કોન્ટ્રાસ્ટ આઉટડોર મોડ';

  @override
  String get language => 'ભાષા';

  @override
  String get trackingMode => 'ડિફૉલ્ટ ટ્રેકિંગ મોડ';

  @override
  String get speedUnit => 'ઝડપ એકમ';

  @override
  String get compactTimeline => 'કોમ્પેક્ટ સ્ટેશન ટાઇમલાઇન';

  @override
  String get liveEndpoint => 'લાઇવ ડેટા એન્ડપોઇન્ટ (વૈકલ્પિક)';

  @override
  String get liveEndpointHint =>
      'JSON વિલંબ/પ્લેટફોર્મ ડેટા આપતો બેઝ URL. ખાલી = ફક્ત ઓફલાઇન.';

  @override
  String get aboutTitle => 'ઓપનટ્રેક ઇન્ડિયા વિશે';

  @override
  String get aboutBody =>
      'ઓપનટ્રેક ઇન્ડિયા એ મફત, ઓફલાઇન-ફર્સ્ટ રેલ્વે સાથી છે. સમયપત્રક શોધ, ટ્રેકિંગ અને એલાર્મ સંપૂર્ણપણે તમારા ફોન પર ચાલે છે — કોઈ પેઇડ કી, જાહેરાતો કે ટેલિમેટ્રી નથી.';

  @override
  String get gpsCorrection => 'GPS ઘડિયાળ સુધારણા સક્રિય';

  @override
  String get offlineMode => 'ઓફલાઇન મોડ';

  @override
  String get onlineMode => 'ઓનલાઇન મોડ';

  @override
  String get homeStation => 'હોમ સ્ટેશન';

  @override
  String get frequentTrain => 'નિયમિત ટ્રેન';

  @override
  String get savedRoute => 'સાચવેલો માર્ગ';
}
