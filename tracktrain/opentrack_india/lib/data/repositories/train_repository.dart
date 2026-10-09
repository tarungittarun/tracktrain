import '../../core/fuzzy_match.dart';
import '../db/app_database.dart';
import '../models/train.dart';
import '../models/train_stop.dart';

/// Train search and schedule access with the same typo-tolerant pipeline as
/// [StationRepository].
class TrainRepository {
  const TrainRepository();

  Future<List<Train>> search(String query, {int limit = 15}) async {
    final db = await AppDatabase.instance.database;
    final q = query.trim();
    if (q.isEmpty) return const [];

    final candidates = <int, Train>{};

    // Exact/prefix train-number hits first: users frequently type numbers.
    if (RegExp(r'^[0-9]+$').hasMatch(q)) {
      final rows = await db.query(
        'trains',
        where: 'number LIKE ?',
        whereArgs: ['$q%'],
        limit: limit,
      );
      for (final row in rows) {
        final train = Train.fromRow(row);
        candidates[train.id] = train;
      }
    }

    if (AppDatabase.instance.ftsAvailable) {
      for (final train in await _ftsSearch(db, q, limit * 4)) {
        candidates[train.id] = train;
      }
    }
    for (final train in await _likeSearch(db, q, limit * 3)) {
      candidates[train.id] = train;
    }

    final ranked = candidates.values.toList()
      ..sort((a, b) => _score(q, b).compareTo(_score(q, a)));
    return ranked.take(limit).toList(growable: false);
  }

  Future<Train?> getByNumber(String number) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'trains',
      where: 'number = ?',
      whereArgs: [number],
      limit: 1,
    );
    return rows.isEmpty ? null : Train.fromRow(rows.first);
  }

  /// Full ordered route of a train with station names joined in.
  Future<List<TrainStop>> getSchedule(String trainNumber) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT ts.*, s.name AS station_name
      FROM train_stops ts
      LEFT JOIN stations s ON s.code = ts.station_code
      WHERE ts.train_number = ?
      ORDER BY ts.seq ASC
    ''', [trainNumber]);
    return rows.map(TrainStop.fromRow).toList(growable: false);
  }

  /// Trains halting at a station, for the Live Station screen.
  Future<List<Train>> trainsStoppingAt(String stationCode, {int limit = 20}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT t.*
      FROM train_stops ts
      JOIN trains t ON t.number = ts.train_number
      WHERE ts.station_code = ?
      ORDER BY t.number
      LIMIT ?
    ''', [stationCode.toUpperCase(), limit]);
    return rows.map(Train.fromRow).toList(growable: false);
  }

  Future<List<Train>> _ftsSearch(dynamic db, String query, int limit) async {
    final tokens = query
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '"${t.replaceAll('"', '')}"*')
        .toList();
    final match = tokens.join(' ');
    if (match.isEmpty) return const [];
    try {
      final rows = await db.rawQuery('''
        SELECT t.* FROM trains_fts f
        JOIN trains t ON t.id = f.rowid
        WHERE trains_fts MATCH ?
        ORDER BY rank
        LIMIT ?
      ''', [match, limit]);
      return rows.map(Train.fromRow).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<Train>> _likeSearch(dynamic db, String query, int limit) async {
    final rows = await db.query(
      'trains',
      where: 'name LIKE ? OR number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: limit,
    );
    return rows.map(Train.fromRow).toList(growable: false);
  }

  double _score(String query, Train train) {
    final nameScore = FuzzyMatch.combinedScore(query, train.name);
    final numberScore = train.number.startsWith(query)
        ? 0.97
        : FuzzyMatch.similarity(query, train.number) * 0.5;
    return nameScore > numberScore ? nameScore : numberScore;
  }
}
