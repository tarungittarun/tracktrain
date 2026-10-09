import 'package:flutter/services.dart';

import '../data/models/cell_tower.dart';

/// Reads serving cell identities (MCC/MNC/LAC/CID) from Android
/// TelephonyManager through the native `in.opentrack/cell_info` channel
/// implemented in MainActivity.kt.
///
/// No third-party telephony plugin is used on purpose: upstream packages in
/// this space are unmaintained and break across Android releases. The native
/// implementation guards every API level itself and degrades to an empty
/// list, which the tracking engine treats as "cell mode unavailable".
class CellInfoService {
  static const MethodChannel _channel =
      MethodChannel('in.opentrack/cell_info');

  /// Returns all visible cells, strongest first; empty when the permission
  /// is missing, no SIM is present, or the OEM blocks telephony access.
  Future<List<CellTowerInfo>> getServingTowers() async {
    try {
      final raw =
          await _channel.invokeMethod<List<dynamic>>('getServingCellInfo');
      if (raw == null) return const [];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map(CellTowerInfo.fromMap)
          .where((t) => t.hasIdentity)
          .toList(growable: false);
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  /// The strongest cell with a complete identity, or null.
  Future<CellTowerInfo?> getPrimaryTower() async {
    final towers = await getServingTowers();
    return towers.isEmpty ? null : towers.first;
  }
}
