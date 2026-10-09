import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The production timetable ships as a prebuilt SQLite database asset
/// (~29 MB: 8,736 stations, 5,207 trains, 416,629 stops) which is copied
/// verbatim on first launch. Bump the generation in [_dbFileName] whenever
/// the bundled data or schema changes — the app then swaps in the new file.
class AppDatabase {
  static const String _dbFileName = 'opentrack_timetable_v1.db';
  static const String _assetPath = 'assets/db/opentrack_timetable.db';
  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();
  AppDatabase._();

  Database? _db;

  /// Cached row counts (set in [_open]) for the typo-scan fallback.
  int stationCount = 0;
  int trainCount = 0;

  /// The bundled DB always carries FTS5 indexes.
  bool get ftsAvailable => true;

  /// Test hooks.
  String? debugPathOverride;
  Future<Uint8List> Function(String assetPath)? debugAssetBytes;

  /// Reset (test only): close + force re-open.
  Future<void> debugReset() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> get database async => _db ??= await _open();

  /// Ensure the database is copied and readable before first use.
  Future<void> ensureReady() async {
    await database;
  }

  Future<Database> _open() async {
    if (debugPathOverride != null) {
      final db = await openDatabase(debugPathOverride!,
          onConfigure: _configure);
      await _refreshCounts(db);
      return db;
    }

    final path = p.join(await getDatabasesPath(), _dbFileName);
    if (!await File(path).exists()) {
      await _copyAssetTo(path);
    }

    var db = await openDatabase(path, onConfigure: _configure);

    // Self-heal: if the bundled file is missing/empty (corrupt copy),
    // re-copy the pristine asset and reopen.
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM stations'));
    if ((count ?? 0) == 0) {
      await db.close();
      await File(path).delete();
      await _copyAssetTo(path);
      db = await openDatabase(path, onConfigure: _configure);
    }
    await _refreshCounts(db);
    return db;
  }

  Future<void> _refreshCounts(Database db) async {
    stationCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM stations')) ??
        0;
    trainCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM trains')) ??
        0;
  }

  Future<void> _copyAssetTo(String path) async {
    final Future<Uint8List> Function(String) loader = debugAssetBytes ??
        (String a) async {
          final data = await rootBundle.load(a);
          return data.buffer.asUint8List(
              data.offsetInBytes, data.lengthInBytes);
        };
    final bytes = await loader(_assetPath);
    final file = File(path);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> _configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
