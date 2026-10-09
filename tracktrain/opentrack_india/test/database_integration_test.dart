import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opentrack_india/data/db/app_database.dart';
import 'package:opentrack_india/data/repositories/station_repository.dart';
import 'package:opentrack_india/data/repositories/train_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Reads the real bundled CSVs from disk instead of rootBundle so the exact
/// on-device pipeline (schema → FTS5 → seed → search) can be verified in CI.
Future<String> _fileAssetLoader(String path) => File(path).readAsString();

void main() {
  const stations = StationRepository();
  const trains = TrainRepository();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.instance.debugPathOverride =
        '${Directory.systemTemp.path}/opentrack_test_'
        '${DateTime.now().microsecondsSinceEpoch}.db';
    AppDatabase.instance.assetLoader = _fileAssetLoader;
  });

  tearDownAll(() async {
    final path = AppDatabase.instance.debugPathOverride;
    await databaseFactory.deleteDatabase(path!);
  });

  test('database seeds the bundled dataset with FTS5 enabled', () async {
    final db = await AppDatabase.instance.database;
    expect(db, isNotNull);
    expect(AppDatabase.instance.stationCount, 43);
    expect(AppDatabase.instance.trainCount, 8);
    expect(AppDatabase.instance.ftsAvailable, isTrue);
  });

  test('empty query returns popular stations (picker initial state)',
      () async {
    final results = await stations.search('');
    expect(results, isNotEmpty);
  });

  test('station search: exact and typo queries', () async {
    final exact = await stations.search('chennai');
    expect(exact.map((s) => s.code), contains('MAS'));

    final typo = await stations.search('bopal');
    expect(typo.map((s) => s.code), contains('BPL'));

    final byCode = await stations.search('ndls');
    expect(byCode.map((s) => s.code), contains('NDLS'));
  });

  test('station search works with vernacular (Devanagari) input', () async {
    final results = await stations.search('नई दिल्ली');
    expect(results, isNotEmpty);
    expect(results.first.code, 'NDLS');
  });

  test('train search: typo, number and name queries', () async {
    final typo = await trains.search('rajdhni');
    expect(typo.map((t) => t.number), contains('12951'));

    final byNumber = await trains.search('12951');
    expect(byNumber, isNotEmpty);
    expect(byNumber.first.number, '12951');

    final byName = await trains.search('tamil nadu');
    expect(byName.map((t) => t.number), contains('12621'));
  });

  test('train schedule returns ordered stops with station names', () async {
    final schedule = await trains.getSchedule('12951');
    expect(schedule.length, 5);
    expect(schedule.first.stationCode, 'MMCT');
    expect(schedule.last.stationCode, 'NDLS');
    expect(schedule.last.stationName, 'New Delhi');
    expect(schedule.first.isOrigin, isTrue);
  });

  test('trains halting at a station are listed', () async {
    final halting = await trains.trainsStoppingAt('BPL');
    expect(halting.map((t) => t.number), containsAll(['12621', '12001']));
  });

  test('self-healing rebuilds an emptied database on relaunch', () async {
    final db = await AppDatabase.instance.database;
    await db.execute('DELETE FROM stations');
    await db.execute('DELETE FROM stations_fts');
    await db.execute('DELETE FROM trains');
    await db.close();

    // Simulate the next app launch opening the same hollow file.
    AppDatabase.instance.debugReset();
    await AppDatabase.instance.database;
    expect(AppDatabase.instance.stationCount, 43);
    expect(AppDatabase.instance.trainCount, 8);

    final healed = await stations.search('chennai');
    expect(healed.map((s) => s.code), contains('MAS'));
  });
}
