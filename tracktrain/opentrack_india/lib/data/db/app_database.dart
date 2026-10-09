import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/csv.dart';

/// Owns the bundled offline timetable database.
///
/// Tables:
///  * `stations`     – ~8,500 production station codes (sample set bundled)
///  * `trains`       – ~12,000 production trains (sample set bundled)
///  * `train_stops`  – scheduled halts per train
///  * `cell_towers`  – compressed OpenCelliD-style tower → location table
///
/// Full-text search runs through SQLite FTS5 virtual tables mirrored with
/// triggers. Devices whose system SQLite lacks FTS5 fall back to indexed
/// LIKE queries transparently; repositories check [ftsAvailable].
///
/// Self-healing: if the first-launch seeding was ever interrupted (app
/// force-stopped, install glitch, missing asset at that moment), the next
/// open detects empty tables and rebuilds the whole database.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const _fileName = 'opentrack_timetable.db';

  Future<Database>? _opening;
  bool _ftsAvailable = false;
  int _stationCount = 0;
  int _trainCount = 0;

  /// Asset reader; tests swap this for direct file access.
  Future<String> Function(String assetPath) assetLoader = rootBundle.loadString;

  /// Database file path override for tests; null uses the platform path.
  String? debugPathOverride;

  /// Drops the cached connection so the next [database] access re-opens the
  /// file (used by tests to simulate an app relaunch).
  void debugReset() {
    _opening = null;
    _ftsAvailable = false;
    _stationCount = 0;
    _trainCount = 0;
  }

  /// True when FTS5 virtual tables were created on this device.
  bool get ftsAvailable => _ftsAvailable;

  int get stationCount => _stationCount;
  int get trainCount => _trainCount;

  Future<Database> get database => _opening ??= _open();

  /// Warms the database on app start; safe to call repeatedly.
  Future<void> ensureReady() => database;

  Future<Database> _open() async {
    final path = debugPathOverride ??
        p.join(await getDatabasesPath(), _fileName);
    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
    await _repairIfEmpty(db);
    await _refreshCounts(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSchema(db);
    await _createFts(db);
    await _seed(db);
  }

  /// If a previous seeding was interrupted the tables exist but are empty;
  /// drop everything and build again so search never faces a hollow DB.
  Future<void> _repairIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) AS c FROM stations'),
    );
    if ((count ?? 0) > 0) return;

    await db.execute('DROP TABLE IF EXISTS stations_fts');
    await db.execute('DROP TABLE IF EXISTS trains_fts');
    await db.execute('DROP TRIGGER IF EXISTS stations_fts_ai');
    await db.execute('DROP TRIGGER IF EXISTS trains_fts_ai');
    await db.execute('DROP TABLE IF EXISTS train_stops');
    await db.execute('DROP TABLE IF EXISTS cell_towers');
    await db.execute('DROP TABLE IF EXISTS trains');
    await db.execute('DROP TABLE IF EXISTS stations');

    _ftsAvailable = false;
    await _createSchema(db);
    await _createFts(db);
    await _seed(db);
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        name_local TEXT NOT NULL DEFAULT '',
        city TEXT NOT NULL DEFAULT '',
        state TEXT NOT NULL DEFAULT '',
        lat REAL NOT NULL DEFAULT 0,
        lon REAL NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trains (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        src TEXT NOT NULL,
        dst TEXT NOT NULL,
        days TEXT NOT NULL DEFAULT '1111111',
        type TEXT NOT NULL DEFAULT 'Express'
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS train_stops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        train_number TEXT NOT NULL,
        seq INTEGER NOT NULL,
        station_code TEXT NOT NULL,
        arrival TEXT NOT NULL DEFAULT '',
        departure TEXT NOT NULL DEFAULT '',
        distance_km REAL NOT NULL DEFAULT 0,
        day_offset INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cell_towers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mcc INTEGER NOT NULL,
        mnc INTEGER NOT NULL,
        lac INTEGER NOT NULL,
        cid INTEGER NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        station_code TEXT NOT NULL DEFAULT '',
        accuracy_m REAL NOT NULL DEFAULT 3000,
        UNIQUE (mcc, mnc, lac, cid)
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_stations_name ON stations (name)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_stations_local ON stations (name_local)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_trains_name ON trains (name)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_stops_train ON train_stops (train_number, seq)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_stops_station ON train_stops (station_code)',
    );
  }

  /// Attempts to create FTS5 mirrors. Older Android SQLite builds without
  /// FTS5 simply flip the fallback flag; nothing else breaks.
  Future<void> _createFts(Database db) async {
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE stations_fts USING fts5(
          name, name_local, code, city,
          content='stations', content_rowid='id'
        )
      ''');
      await db.execute('''
        CREATE TRIGGER stations_fts_ai AFTER INSERT ON stations BEGIN
          INSERT INTO stations_fts(rowid, name, name_local, code, city)
          VALUES (new.id, new.name, new.name_local, new.code, new.city);
        END
      ''');
      await db.execute('''
        CREATE VIRTUAL TABLE trains_fts USING fts5(
          name, number, content='trains', content_rowid='id'
        )
      ''');
      await db.execute('''
        CREATE TRIGGER trains_fts_ai AFTER INSERT ON trains BEGIN
          INSERT INTO trains_fts(rowid, name, number)
          VALUES (new.id, new.name, new.number);
        END
      ''');
      _ftsAvailable = true;
    } on DatabaseException {
      _ftsAvailable = false;
    } catch (_) {
      _ftsAvailable = false;
    }
  }

  Future<void> _seed(Database db) async {
    final stationsCsv = await assetLoader('assets/data/stations.csv');
    final trainsCsv = await assetLoader('assets/data/trains.csv');
    final stopsCsv = await assetLoader('assets/data/train_stops.csv');
    final towersCsv = await assetLoader('assets/data/cell_towers.csv');

    final batch = db.batch();

    final (_, stationRows) = Csv.parse(stationsCsv);
    for (final row in stationRows) {
      batch.insert('stations', {
        'code': row['code'] ?? '',
        'name': row['name'] ?? '',
        'name_local': row['name_local'] ?? '',
        'city': row['city'] ?? '',
        'state': row['state'] ?? '',
        'lat': double.tryParse(row['lat'] ?? '') ?? 0.0,
        'lon': double.tryParse(row['lon'] ?? '') ?? 0.0,
      });
    }

    final (_, trainRows) = Csv.parse(trainsCsv);
    for (final row in trainRows) {
      batch.insert('trains', {
        'number': row['number'] ?? '',
        'name': row['name'] ?? '',
        'src': row['src'] ?? '',
        'dst': row['dst'] ?? '',
        'days': row['days'] ?? '1111111',
        'type': row['type'] ?? 'Express',
      });
    }

    final (_, stopRows) = Csv.parse(stopsCsv);
    for (final row in stopRows) {
      batch.insert('train_stops', {
        'train_number': row['train_number'] ?? '',
        'seq': int.tryParse(row['seq'] ?? '') ?? 0,
        'station_code': row['station_code'] ?? '',
        'arrival': row['arrival'] ?? '',
        'departure': row['departure'] ?? '',
        'distance_km': double.tryParse(row['distance_km'] ?? '') ?? 0.0,
        'day_offset': int.tryParse(row['day_offset'] ?? '') ?? 0,
      });
    }

    final (_, towerRows) = Csv.parse(towersCsv);
    for (final row in towerRows) {
      batch.insert('cell_towers', {
        'mcc': int.tryParse(row['mcc'] ?? '') ?? 0,
        'mnc': int.tryParse(row['mnc'] ?? '') ?? 0,
        'lac': int.tryParse(row['lac'] ?? '') ?? 0,
        'cid': int.tryParse(row['cid'] ?? '') ?? 0,
        'lat': double.tryParse(row['lat'] ?? '') ?? 0.0,
        'lon': double.tryParse(row['lon'] ?? '') ?? 0.0,
        'station_code': row['station_code'] ?? '',
        'accuracy_m': double.tryParse(row['accuracy_m'] ?? '') ?? 3000.0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }

  Future<void> _refreshCounts(Database db) async {
    final stations = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM stations'),
    );
    final trains = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM trains'),
    );
    _stationCount = stations ?? 0;
    _trainCount = trains ?? 0;
  }
}
