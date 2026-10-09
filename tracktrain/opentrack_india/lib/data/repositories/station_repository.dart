import 'package:sqflite/sqflite.dart';

import '../../core/fuzzy_match.dart';
import '../db/app_database.dart';
import '../models/station.dart';

/// Typo-tolerant station search:
///  1. SQLite FTS5 prefix matching (fast path, includes `name_local` so
///     vernacular scripts are searchable)
///  2. Indexed LIKE substring matching
///  3. Full-dataset Levenshtein scan — the typo net that catches queries
///     like "bopal" → Bhopal which neither FTS nor LIKE can see.
class StationRepository {
  const StationRepository();

  /// Cached station list for the fuzzy scan (rebuilt automatically after a
  /// database self-heal thanks to the count check).
  static List<Station>? _fuzzyCache;
  static int _fuzzyCacheCount = -1;

  Future<List<Station>> search(String query, {int limit = 15}) async {
    final db = await AppDatabase.instance.database;
    final q = query.trim();
    if (q.isEmpty) {
      return _popularStations(db, limit);
    }

    final candidates = <int, Station>{};

    if (AppDatabase.instance.ftsAvailable) {
      for (final station in await _ftsSearch(db, q, limit * 4)) {
        candidates[station.id] = station;
      }
    }
    for (final station in await _likeSearch(db, q, limit * 3)) {
      candidates[station.id] = station;
    }

    // Typo net: when the fast paths barely matched, score every station.
    if (candidates.length < 3 && q.length >= 3) {
      for (final station in await _fuzzyScan(db, q, limit)) {
        candidates[station.id] = station;
      }
    }

    final ranked = candidates.values.toList()
      ..sort((a, b) => _score(q, b).compareTo(_score(q, a)));
    return ranked.take(limit).toList(growable: false);
  }

  Future<List<Station>> _fuzzyScan(Database db, String query, int limit) async {
    final stationTotal = AppDatabase.instance.stationCount;
    if (_fuzzyCache == null || _fuzzyCacheCount != stationTotal) {
      _fuzzyCache = (await db.query('stations'))
          .map(Station.fromRow)
          .toList(growable: false);
      _fuzzyCacheCount = stationTotal;
    }

    final scored = <(double, Station)>[];
    for (final station in _fuzzyCache!) {
      final score = _score(query, station);
      if (score >= 0.55) scored.add((score, station));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.take(limit).map((e) => e.$2).toList(growable: false);
  }

  Future<Station?> getByCode(String code) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'stations',
      where: 'code = ?',
      whereArgs: [code.toUpperCase()],
      limit: 1,
    );
    return rows.isEmpty ? null : Station.fromRow(rows.first);
  }

  /// Nearest stations to a coordinate using squared-delta ordering (exact
  /// haversine is applied by callers when they need real distances).
  Future<List<Station>> nearestTo(
    double lat,
    double lon, {
    int limit = 8,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT *,
        ((lat - ?) * (lat - ?) + (lon - ?) * (lon - ?)) AS d
      FROM stations
      ORDER BY d ASC
      LIMIT ?
    ''', [lat, lat, lon, lon, limit]);
    return rows.map(Station.fromRow).toList(growable: false);
  }

  Future<List<Station>> popular({int limit = 8}) async {
    final db = await AppDatabase.instance.database;
    return _popularStations(db, limit);
  }

  Future<List<Station>> _popularStations(Database db, int limit) async {
    final rows = await db.query('stations', orderBy: 'id', limit: limit);
    return rows.map(Station.fromRow).toList(growable: false);
  }

  Future<List<Station>> _ftsSearch(Database db, String query, int limit) async {
    final match = _buildFtsMatch(query);
    if (match.isEmpty) return const [];
    try {
      final rows = await db.rawQuery('''
        SELECT s.* FROM stations_fts f
        JOIN stations s ON s.id = f.rowid
        WHERE stations_fts MATCH ?
        ORDER BY rank
        LIMIT ?
      ''', [match, limit]);
      return rows.map(Station.fromRow).toList(growable: false);
    } catch (_) {
      // Malformed MATCH expressions (rare with exotic scripts) degrade to the
      // LIKE path instead of crashing the search field.
      return const [];
    }
  }

  Future<List<Station>> _likeSearch(Database db, String query, int limit) async {
    final like = '%$query%';
    final rows = await db.query(
      'stations',
      where: 'name LIKE ? OR name_local LIKE ? OR code LIKE ? OR city LIKE ?',
      whereArgs: [like, like, '${query.toUpperCase()}%', like],
      limit: limit,
    );
    return rows.map(Station.fromRow).toList(growable: false);
  }

  /// Builds an FTS5 MATCH expression with per-token prefix matching,
  /// e.g. `chen cent` → `"chen"* "cent"*`.
  String _buildFtsMatch(String query) {
    final tokens = query
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '"${t.replaceAll('"', '')}"*')
        .toList();
    return tokens.join(' ');
  }

  double _score(String query, Station station) {
    final nameScore = FuzzyMatch.combinedScore(query, station.name);
    final localScore = FuzzyMatch.combinedScore(query, station.nameLocal);
    final codeScore = station.code.toLowerCase() == query.toLowerCase()
        ? 1.0
        : station.code.toLowerCase().startsWith(query.toLowerCase())
            ? 0.9
            : FuzzyMatch.similarity(query, station.code) * 0.6;
    return [nameScore, localScore, codeScore].reduce((a, b) => a > b ? a : b);
  }
}
