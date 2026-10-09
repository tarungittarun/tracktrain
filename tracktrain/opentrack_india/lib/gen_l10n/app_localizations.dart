import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'OpenTrack India'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Offline-first railway tracking'**
  String get tagline;

  /// No description provided for @tabTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get tabTrack;

  /// No description provided for @tabLiveStation.
  ///
  /// In en, this message translates to:
  /// **'Live Station'**
  String get tabLiveStation;

  /// No description provided for @tabTimetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get tabTimetable;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search trains or stations (typos OK)'**
  String get searchHint;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get startTracking;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop tracking'**
  String get stopTracking;

  /// No description provided for @statusIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready to track'**
  String get statusIdle;

  /// No description provided for @statusAcquiring.
  ///
  /// In en, this message translates to:
  /// **'Acquiring GPS fix…'**
  String get statusAcquiring;

  /// No description provided for @statusTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking journey'**
  String get statusTracking;

  /// No description provided for @statusDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get statusDenied;

  /// No description provided for @statusServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off'**
  String get statusServiceOff;

  /// No description provided for @modeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get modeAuto;

  /// No description provided for @modeGps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get modeGps;

  /// No description provided for @modeCell.
  ///
  /// In en, this message translates to:
  /// **'Cell tower'**
  String get modeCell;

  /// No description provided for @nearestStation.
  ///
  /// In en, this message translates to:
  /// **'Nearest station'**
  String get nearestStation;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @destinationAlarm.
  ///
  /// In en, this message translates to:
  /// **'Destination alarm'**
  String get destinationAlarm;

  /// No description provided for @chooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination station'**
  String get chooseDestination;

  /// No description provided for @armAlarm.
  ///
  /// In en, this message translates to:
  /// **'Arm alarm'**
  String get armAlarm;

  /// No description provided for @disarmAlarm.
  ///
  /// In en, this message translates to:
  /// **'Disarm alarm'**
  String get disarmAlarm;

  /// No description provided for @alarmArmed.
  ///
  /// In en, this message translates to:
  /// **'Alarm armed'**
  String get alarmArmed;

  /// No description provided for @alertLead.
  ///
  /// In en, this message translates to:
  /// **'Alert distance'**
  String get alertLead;

  /// No description provided for @liveStation.
  ///
  /// In en, this message translates to:
  /// **'Live station'**
  String get liveStation;

  /// No description provided for @nearbyStations.
  ///
  /// In en, this message translates to:
  /// **'Nearby stations'**
  String get nearbyStations;

  /// No description provided for @trainsHaltHere.
  ///
  /// In en, this message translates to:
  /// **'Trains halting here'**
  String get trainsHaltHere;

  /// No description provided for @cellFix.
  ///
  /// In en, this message translates to:
  /// **'Cell tower fix'**
  String get cellFix;

  /// No description provided for @towerMatched.
  ///
  /// In en, this message translates to:
  /// **'Tower matched to route segment'**
  String get towerMatched;

  /// No description provided for @noTowerMatch.
  ///
  /// In en, this message translates to:
  /// **'No offline match for serving tower'**
  String get noTowerMatch;

  /// No description provided for @timetable.
  ///
  /// In en, this message translates to:
  /// **'Offline timetable'**
  String get timetable;

  /// No description provided for @trainSchedule.
  ///
  /// In en, this message translates to:
  /// **'Train schedule'**
  String get trainSchedule;

  /// No description provided for @searchStations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get searchStations;

  /// No description provided for @searchTrains.
  ///
  /// In en, this message translates to:
  /// **'Trains'**
  String get searchTrains;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noResults;

  /// No description provided for @datasetInfo.
  ///
  /// In en, this message translates to:
  /// **'Offline dataset: {stations} stations · {trains} trains'**
  String datasetInfo(Object stations, Object trains);

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'My travel & usage'**
  String get dashboard;

  /// No description provided for @localOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'All metrics are stored on this device. Nothing is ever sent anywhere.'**
  String get localOnlyNote;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance tracked'**
  String get totalDistance;

  /// No description provided for @avgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average speed'**
  String get avgSpeed;

  /// No description provided for @topSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get topSpeed;

  /// No description provided for @travelTime.
  ///
  /// In en, this message translates to:
  /// **'Travel time'**
  String get travelTime;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @screenTime.
  ///
  /// In en, this message translates to:
  /// **'Screen time'**
  String get screenTime;

  /// No description provided for @dataSaved.
  ///
  /// In en, this message translates to:
  /// **'Mobile data saved'**
  String get dataSaved;

  /// No description provided for @offlineUsage.
  ///
  /// In en, this message translates to:
  /// **'Offline usage'**
  String get offlineUsage;

  /// No description provided for @onlineUsage.
  ///
  /// In en, this message translates to:
  /// **'Online usage'**
  String get onlineUsage;

  /// No description provided for @tripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip history'**
  String get tripHistory;

  /// No description provided for @noTrips.
  ///
  /// In en, this message translates to:
  /// **'No journeys tracked yet'**
  String get noTrips;

  /// No description provided for @weeklyTravel.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get weeklyTravel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeOled.
  ///
  /// In en, this message translates to:
  /// **'OLED pure black'**
  String get themeOled;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High-contrast outdoor mode'**
  String get highContrast;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @trackingMode.
  ///
  /// In en, this message translates to:
  /// **'Default tracking mode'**
  String get trackingMode;

  /// No description provided for @speedUnit.
  ///
  /// In en, this message translates to:
  /// **'Speed unit'**
  String get speedUnit;

  /// No description provided for @compactTimeline.
  ///
  /// In en, this message translates to:
  /// **'Compact station timeline'**
  String get compactTimeline;

  /// No description provided for @liveEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Live data endpoint (optional)'**
  String get liveEndpoint;

  /// No description provided for @liveEndpointHint.
  ///
  /// In en, this message translates to:
  /// **'Base URL returning JSON delay/platform data. Empty means offline-only.'**
  String get liveEndpointHint;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About OpenTrack India'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'OpenTrack India is a free, offline-first railway companion. Timetable searches, tracking and alarms run entirely on your phone — no paid keys, no ads, no telemetry.'**
  String get aboutBody;

  /// No description provided for @gpsCorrection.
  ///
  /// In en, this message translates to:
  /// **'GPS clock correction active'**
  String get gpsCorrection;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @onlineMode.
  ///
  /// In en, this message translates to:
  /// **'Online mode'**
  String get onlineMode;

  /// No description provided for @homeStation.
  ///
  /// In en, this message translates to:
  /// **'Home station'**
  String get homeStation;

  /// No description provided for @frequentTrain.
  ///
  /// In en, this message translates to:
  /// **'Frequent train'**
  String get frequentTrain;

  /// No description provided for @savedRoute.
  ///
  /// In en, this message translates to:
  /// **'Saved route'**
  String get savedRoute;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'en',
        'gu',
        'hi',
        'kn',
        'mr',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
