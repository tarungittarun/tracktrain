import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opentrack_india/data/db/app_database.dart';
import 'package:opentrack_india/data/repositories/station_repository.dart';
import 'package:opentrack_india/data/repositories/train_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// End-to-end tests against the real bundled railway dataset
/// (8,736 stations / 5,207 trains / 416,629 stops).
void main() {
  late File dbCopy;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestWidgetsFlutterBinding.ensureInitialized();

    // Work on a scratch copy so the asset itself is never mutated.
    // sqflite_common_ffi needs an absolute path, or it resolves the file
    // inside its own sandbox directory.
    final dir = Directory.current.absolute.path;
    dbCopy = File('$dir/test/.scratch_railway.db');
    dbCopy.writeAsBytesSync(File('$dir/assets/db/opentrack_timetable.db')
        .readAsBytesSync());

    AppDatabase.instance.debugPathOverride = dbCopy.path;
  });

  tearDownAll(() async {
    await AppDatabase.instance.debugReset();
    if (dbCopy.existsSync()) dbCopy.deleteSync();
  });

  test('dataset is the full Indian Railways bundle', () async {
    final db = await AppDatabase.instance.database;
    Future<int> count(String table) async =>
        (await db.rawQuery('SELECT COUNT(*) AS n FROM $table')).first['n'] as int;
    final stations = await count('stations');
    final trains = await count('trains');
    final stops = await count('train_stops');
    expect(stations, greaterThan(8000));
    expect(trains, greaterThan(5000));
    expect(stops, greaterThan(400000));
  });

  test('exact + partial station search works on the full dataset', () async {
    final stations = await const StationRepository().search('chennai central');
    expect(stations, isNotEmpty);
    expect(stations.first.code, 'MAS');

    final partial = await const StationRepository().search('secund');
    expect(partial.any((s) => s.code == 'SC'), isTrue,
        reason: 'partial name match should find Secunderabad');

    final byCode = await const StationRepository().search('ndls');
    expect(byCode.first.code, 'NDLS');
  });

  test('typo-tolerant station search recovers from misspellings', () async {
    expect((await const StationRepository().search('howrah')).first.code, 'HWH');
    final typo = await const StationRepository().search('howra');
    expect(typo.map((s) => s.code), contains('HWH'));
    final typo2 = await const StationRepository().search('benaras');
    expect(typo2.map((s) => s.name), isNotEmpty);
  });

  test('train search finds real trains by number and name', () async {
    final byNumber = await const TrainRepository().search('12301');
    expect(byNumber, isNotEmpty);
    expect(byNumber.first.number, '12301');

    final rajdhani = await const TrainRepository().search('rajdhani');
    expect(rajdhani.length, greaterThan(5));
  });

  test('schedule stops are ordered with times', () async {
    final stops = await const TrainRepository().getSchedule('12301');
    expect(stops.length, greaterThan(150));
    expect(stops.first.stationCode, 'HWH');
    expect(stops.last.stationCode, 'NDLS');
    expect(stops.first.departure, '16:55');
    expect(stops.last.arrival, isNotEmpty);
    for (var i = 1; i < stops.length; i++) {
      expect(stops[i].sequence, greaterThan(stops[i - 1].sequence));
    }
  });

  test('between-stations lookup works offline', () async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT t.number FROM train_stops a
      JOIN train_stops b ON a.train_number = b.train_number
      JOIN trains t ON t.number = a.train_number
      WHERE a.station_code = ? AND b.station_code = ? AND a.seq < b.seq
      LIMIT 20
    ''', ['NDLS', 'HWH']);
    expect(rows.length, greaterThanOrEqualTo(5));
  });
}
