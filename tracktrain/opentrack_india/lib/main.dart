import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'app.dart';
import 'core/app_services.dart';
import 'data/models/hive_records.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // IST handling is locked app-wide before any clock reads occur.
  tzdata.initializeTimeZones();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  registerHiveAdapters();
  await AppServices.bootstrap();

  runApp(const ProviderScope(child: OpenTrackApp()));
}
