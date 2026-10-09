// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'ওপেনট্র্যাক ইন্ডিয়া';

  @override
  String get tagline => 'অফলাইন-ফার্স্ট রেল ট্র্যাকিং';

  @override
  String get tabTrack => 'ট্র্যাক';

  @override
  String get tabLiveStation => 'লাইভ স্টেশন';

  @override
  String get tabTimetable => 'সময়সূচি';

  @override
  String get tabDashboard => 'ড্যাশবোর্ড';

  @override
  String get searchHint => 'ট্রেন বা স্টেশন খুঁজুন (বানান ভুল চলবে)';

  @override
  String get startTracking => 'ট্র্যাকিং শুরু করুন';

  @override
  String get stopTracking => 'ট্র্যাকিং বন্ধ করুন';

  @override
  String get statusIdle => 'ট্র্যাক করার জন্য প্রস্তুত';

  @override
  String get statusAcquiring => 'GPS সিগন্যাল আনা হচ্ছে…';

  @override
  String get statusTracking => 'যাত্রা ট্র্যাক হচ্ছে';

  @override
  String get statusDenied => 'লোকেশনের অনুমতি দেওয়া হয়নি';

  @override
  String get statusServiceOff => 'লোকেশন পরিষেবা বন্ধ';

  @override
  String get modeAuto => 'অটো';

  @override
  String get modeGps => 'GPS';

  @override
  String get modeCell => 'সেল টাওয়ার';

  @override
  String get nearestStation => 'নিকটতম স্টেশন';

  @override
  String get eta => 'পৌঁছানোর সময়';

  @override
  String get remaining => 'অবশিষ্ট দূরত্ব';

  @override
  String get speed => 'গতি';

  @override
  String get destinationAlarm => 'গন্তব্য অ্যালার্ম';

  @override
  String get chooseDestination => 'গন্তব্য স্টেশন বেছে নিন';

  @override
  String get armAlarm => 'অ্যালার্ম দিন';

  @override
  String get disarmAlarm => 'অ্যালার্ম সরান';

  @override
  String get alarmArmed => 'অ্যালার্ম সক্রিয়';

  @override
  String get alertLead => 'সতর্কতার দূরত্ব';

  @override
  String get liveStation => 'লাইভ স্টেশন';

  @override
  String get nearbyStations => 'কাছের স্টেশন';

  @override
  String get trainsHaltHere => 'এখানে থামা ট্রেন';

  @override
  String get cellFix => 'সেল টাওয়ার লোকেশন';

  @override
  String get towerMatched => 'টাওয়ার রুটের সঙ্গে মিলেছে';

  @override
  String get noTowerMatch => 'সেল টাওয়ারের অফলাইন মেল নেই';

  @override
  String get timetable => 'অফলাইন সময়সূচি';

  @override
  String get trainSchedule => 'ট্রেনের সূচি';

  @override
  String get searchStations => 'স্টেশন';

  @override
  String get searchTrains => 'ট্রেন';

  @override
  String get noResults => 'কোনো ফলাফল পাওয়া যায়নি';

  @override
  String datasetInfo(Object stations, Object trains) {
    return 'অফলাইন ডেটাসেট: $stations স্টেশন · $trains ট্রেন';
  }

  @override
  String get dashboard => 'আমার যাত্রা ও ব্যবহার';

  @override
  String get localOnlyNote =>
      'সব তথ্য এই ফোনেই সংরক্ষিত। কোথাও কিছু পাঠানো হয় না।';

  @override
  String get totalDistance => 'অতিক্রান্ত দূরত্ব';

  @override
  String get avgSpeed => 'গড় গতি';

  @override
  String get topSpeed => 'সর্বোচ্চ গতি';

  @override
  String get travelTime => 'ভ্রমণ সময়';

  @override
  String get sessions => 'সেশন';

  @override
  String get screenTime => 'স্ক্রিন সময়';

  @override
  String get dataSaved => 'সাশ্রয় করা মোবাইল ডেটা';

  @override
  String get offlineUsage => 'অফলাইন ব্যবহার';

  @override
  String get onlineUsage => 'অনলাইন ব্যবহার';

  @override
  String get tripHistory => 'যাত্রার ইতিহাস';

  @override
  String get noTrips => 'এখনও কোনো যাত্রা ট্র্যাক হয়নি';

  @override
  String get weeklyTravel => 'শেষ ৭ দিন';

  @override
  String get settings => 'সেটিংস';

  @override
  String get theme => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get themeOled => 'OLED সম্পূর্ণ কালো';

  @override
  String get highContrast => 'উচ্চ-কনট্রাস্ট আউটডোর মোড';

  @override
  String get language => 'ভাষা';

  @override
  String get trackingMode => 'ডিফল্ট ট্র্যাকিং মোড';

  @override
  String get speedUnit => 'গতির একক';

  @override
  String get compactTimeline => 'কমপ্যাক্ট স্টেশন টাইমলাইন';

  @override
  String get liveEndpoint => 'লাইভ ডেটা এন্ডপয়েন্ট (ঐচ্ছিক)';

  @override
  String get liveEndpointHint =>
      'JSON ডিলে/প্ল্যাটফর্ম ডেটা দেওয়া বেস URL। খালি = শুধু অফলাইন।';

  @override
  String get aboutTitle => 'ওপেনট্র্যাক ইন্ডিয়া সম্পর্কে';

  @override
  String get aboutBody =>
      'ওপেনট্র্যাক ইন্ডিয়া একটি বিনামূল্যের, অফলাইন-ফার্স্ট রেল সঙ্গী। সময়সূচি অনুসন্ধান, ট্র্যাকিং ও অ্যালার্ম সম্পূর্ণ আপনার ফোনে চলে — কোনো পেড কি, বিজ্ঞাপন বা টেলিমেট্রি নেই।';

  @override
  String get gpsCorrection => 'GPS ঘড়ি সংশোধন সক্রিয়';

  @override
  String get offlineMode => 'অফলাইন মোড';

  @override
  String get onlineMode => 'অনলাইন মোড';

  @override
  String get homeStation => 'হোম স্টেশন';

  @override
  String get frequentTrain => 'নিয়মিত ট্রেন';

  @override
  String get savedRoute => 'সংরক্ষিত রুট';
}
