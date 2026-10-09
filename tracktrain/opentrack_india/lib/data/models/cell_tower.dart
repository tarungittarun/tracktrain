/// A row from the compressed local OpenCelliD-style lookup table mapping a
/// serving cell tower to approximate coordinates near a station.
class CellTowerRecord {
  const CellTowerRecord({
    required this.mcc,
    required this.mnc,
    required this.lac,
    required this.cid,
    required this.latitude,
    required this.longitude,
    required this.stationCode,
    required this.accuracyMeters,
  });

  final int mcc;
  final int mnc;
  final int lac;
  final int cid;
  final double latitude;
  final double longitude;
  final String stationCode;
  final double accuracyMeters;

  factory CellTowerRecord.fromRow(Map<String, Object?> row) =>
      CellTowerRecord(
        mcc: row['mcc'] as int,
        mnc: row['mnc'] as int,
        lac: row['lac'] as int,
        cid: row['cid'] as int,
        latitude: (row['lat'] as num).toDouble(),
        longitude: (row['lon'] as num).toDouble(),
        stationCode: row['station_code'] as String,
        accuracyMeters: (row['accuracy_m'] as num).toDouble(),
      );
}

/// Live serving-tower identity read from Android TelephonyManager through the
/// `in.opentrack/cell_info` method channel.
class CellTowerInfo {
  const CellTowerInfo({
    required this.tech,
    this.mcc,
    this.mnc,
    this.lac,
    this.cid,
    this.signalDbm,
  });

  final String tech;
  final int? mcc;
  final int? mnc;
  final int? lac;
  final int? cid;
  final int? signalDbm;

  factory CellTowerInfo.fromMap(Map<Object?, Object?> map) => CellTowerInfo(
        tech: (map['tech'] as String?) ?? 'UNKNOWN',
        mcc: map['mcc'] as int?,
        mnc: map['mnc'] as int?,
        lac: map['lac'] as int?,
        cid: map['cid'] as int?,
        signalDbm: map['signalDbm'] as int?,
      );

  bool get hasIdentity => mcc != null && mnc != null && lac != null && cid != null;
}
