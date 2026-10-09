/// Minimal RFC-4180-ish CSV reader used to seed the bundled SQLite database
/// from `assets/data/*.csv`. Supports quoted fields with escaped quotes.
class Csv {
  Csv._();

  /// Parses [raw] into rows of fields. The first row is treated as the
  /// header and returned in [headers]; data rows are returned keyed by
  /// header name. Blank lines are skipped.
  static (List<String> headers, List<Map<String, String>> rows) parse(
    String raw,
  ) {
    final lines = _splitLines(raw);
    if (lines.isEmpty) return (<String>[], <Map<String, String>>[]);

    final headers = _parseLine(lines.first);
    final rows = <Map<String, String>>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;
      final fields = _parseLine(line);
      final row = <String, String>{};
      for (var c = 0; c < headers.length; c++) {
        row[headers[c]] = c < fields.length ? fields[c].trim() : '';
      }
      rows.add(row);
    }
    return (headers, rows);
  }

  static List<String> _splitLines(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    return normalized.split('\n');
  }

  static List<String> _parseLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var i = 0;
    while (i < line.length) {
      final char = line[i];
      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buffer.write('"');
            i += 2;
            continue;
          }
          inQuotes = false;
          i++;
          continue;
        }
        buffer.write(char);
        i++;
        continue;
      }
      if (char == '"') {
        inQuotes = true;
        i++;
        continue;
      }
      if (char == ',') {
        fields.add(buffer.toString());
        buffer.clear();
        i++;
        continue;
      }
      buffer.write(char);
      i++;
    }
    fields.add(buffer.toString());
    return fields;
  }
}
