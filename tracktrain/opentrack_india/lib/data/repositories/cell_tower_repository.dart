import '../db/app_database.dart';
import '../models/cell_tower.dart';

/// Matches a live serving-cell identity (MCC/MNC/LAC/CID) against the
/// compressed local OpenCelliD-style table — the heart of Cell Tower Mode,
/// which needs zero GPS and zero internet.
class CellTowerRepository {
  const CellTowerRepository();

  Future<CellTowerRecord?> findMatch({
    required int mcc,
    required int mnc,
    required int lac,
    required int cid,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'cell_towers',
      where: 'mcc = ? AND mnc = ? AND lac = ? AND cid = ?',
      whereArgs: [mcc, mnc, lac, cid],
      limit: 1,
    );
    return rows.isEmpty ? null : CellTowerRecord.fromRow(rows.first);
  }

  /// Best-effort match that ignores LAC — cell identities occasionally rotate
  /// LAC ranges after network re-configuration, and a CID-only hit still
  /// pins the journey segment.
  Future<CellTowerRecord?> findLooseMatch({
    required int mcc,
    required int mnc,
    required int cid,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'cell_towers',
      where: 'mcc = ? AND mnc = ? AND cid = ?',
      whereArgs: [mcc, mnc, cid],
      orderBy: 'accuracy_m ASC',
      limit: 1,
    );
    return rows.isEmpty ? null : CellTowerRecord.fromRow(rows.first);
  }

  Future<int> towerCount() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM cell_towers');
    return (rows.first['c'] as int?) ?? 0;
  }
}
