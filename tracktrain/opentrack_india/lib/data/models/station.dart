/// A railway station row from the bundled SQLite timetable database.
class Station {
  const Station({
    required this.id,
    required this.code,
    required this.name,
    required this.nameLocal,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String code;
  final String name;
  final String nameLocal;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  factory Station.fromRow(Map<String, Object?> row) => Station(
        id: row['id'] as int,
        code: row['code'] as String,
        name: row['name'] as String,
        nameLocal: (row['name_local'] as String?) ?? row['name'] as String,
        city: (row['city'] as String?) ?? '',
        state: (row['state'] as String?) ?? '',
        latitude: (row['lat'] as num?)?.toDouble() ?? 0.0,
        longitude: (row['lon'] as num?)?.toDouble() ?? 0.0,
      );

  /// Display title preferring the vernacular name when it differs.
  String get displayTitle => nameLocal.isNotEmpty ? nameLocal : name;

  String get subtitle => '$code · $city, $state';
}
