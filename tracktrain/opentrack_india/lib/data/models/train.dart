/// A train row from the bundled SQLite timetable database.
class Train {
  const Train({
    required this.id,
    required this.number,
    required this.name,
    required this.sourceCode,
    required this.destinationCode,
    required this.daysBitmask,
    required this.type,
  });

  final int id;
  final String number;
  final String name;
  final String sourceCode;
  final String destinationCode;

  /// 7-character string of `0`/`1`, index 0 = Monday.
  final String daysBitmask;
  final String type;

  factory Train.fromRow(Map<String, Object?> row) => Train(
        id: row['id'] as int,
        number: row['number'] as String,
        name: row['name'] as String,
        sourceCode: row['src'] as String,
        destinationCode: row['dst'] as String,
        daysBitmask: (row['days'] as String?) ?? '1111111',
        type: (row['type'] as String?) ?? 'Express',
      );

  static const List<String> _dayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  String get routeLabel => '$sourceCode → $destinationCode';

  bool get runsDaily => daysBitmask.replaceAll('0', '').length == 7;

  /// Human-readable running-days summary, e.g. "Daily" or "Mon–Sat".
  String get daysSummary {
    if (runsDaily) return 'Daily';
    final running = <String>[];
    for (var i = 0; i < 7 && i < daysBitmask.length; i++) {
      if (daysBitmask[i] == '1') running.add(_dayNames[i]);
    }
    if (running.isEmpty) return '—';
    if (running.length > 3) return '${running.length} days/week';
    return running.join(', ');
  }
}
