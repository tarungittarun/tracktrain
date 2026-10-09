import '../../core/fuzzy_match.dart';
import '../db/app_database.dart';
import '../models/station.dart';

/// Typo-tolerant station search backed by SQLite FTS5 prefix matching with a
/// Dart-side Levenshtein re-rank, plus indexed LIKE fallback. Vernacular
/// names are searchable because `name_local` is part of the FTS index.
class StationRepository {
  const StationRepository();

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

    final ranked = candidates.values.toList()
      ..sort((a, b) => _score(q, b).compareTo(_score(q, a)));
    return ranked.take(limit).toList(growable: false);
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

  Future<List<Station>> _popularStations(dynamic db, int limit) async {
    final rows = await db.query('stations', orderBy: 'id', limit: limit);
    return rows.map(Station.fromRow).toList(growable: false);
  }

  Future<List<Station>> _ftsSearch(dynamic db, String query, int limit) async {
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

  Future<List<Station>> _likeSearch(dynamic db, String query, int limit) async {
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
