/// One scheduled halt of a train, joined with its station metadata.
class TrainStop {
  const TrainStop({
    required this.trainNumber,
    required this.sequence,
    required this.stationCode,
    required this.stationName,
    required this.arrival,
    required this.departure,
    required this.distanceKm,
    required this.dayOffset,
  });

  final String trainNumber;
  final int sequence;
  final String stationCode;
  final String stationName;

  /// Scheduled times in IST as `HH:mm`; empty for origin departure / final
  /// arrival edges.
  final String arrival;
  final String departure;
  final double distanceKm;
  final int dayOffset;

  factory TrainStop.fromRow(Map<String, Object?> row) => TrainStop(
        trainNumber: row['train_number'] as String,
        sequence: row['seq'] as int,
        stationCode: row['station_code'] as String,
        stationName: (row['station_name'] as String?) ?? '',
        arrival: (row['arrival'] as String?) ?? '',
        departure: (row['departure'] as String?) ?? '',
        distanceKm: (row['distance_km'] as num?)?.toDouble() ?? 0.0,
        dayOffset: (row['day_offset'] as int?) ?? 0,
      );

  bool get isOrigin => sequence == 1;

  /// "Arr 04:00 · Dep 04:10 · Day 2" style row for the timeline UI.
  String get scheduleLine {
    final parts = <String>[];
    if (arrival.isNotEmpty) parts.add('Arr $arrival');
    if (departure.isNotEmpty) parts.add('Dep $departure');
    if (dayOffset > 0) parts.add('+${dayOffset}d');
    return parts.join(' · ');
  }
}
