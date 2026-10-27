import 'package:admin_app/staff/shared/read_json.dart';

/// "older_than_7" becomes "Older than 7".
String humanizeKey(String key) {
  final words = key.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
  if (words.isEmpty) return words;
  return words[0].toUpperCase() + words.substring(1);
}

class ReportInfo {
  const ReportInfo({required this.key, required this.name});

  final String key;
  final String name;

  factory ReportInfo.fromMap(Map<String, dynamic> map) {
    return ReportInfo(
      key: readString(map['report_key'] ?? map['key']),
      name: readString(map['name'] ?? map['title']),
    );
  }
}

class ReportResult {
  const ReportResult({
    required this.summary,
    required this.columns,
    required this.rows,
  });

  /// Headline numbers: label and value.
  final List<(String, String)> summary;

  /// Table columns in display order: key and label.
  final List<(String, String)> columns;
  final List<Map<String, String>> rows;

  factory ReportResult.fromData(Map<String, dynamic> data) {
    final summary = data['summary'];
    final rows = objectList(data['table'] ?? data['rows']);
    final keys = <String>[];
    for (final row in rows) {
      for (final key in row.keys) {
        if (!keys.contains(key)) keys.add(key);
      }
    }
    return ReportResult(
      summary: [
        if (summary is Map)
          for (final entry in summary.entries)
            (humanizeKey(readString(entry.key)), readString(entry.value)),
      ],
      columns: [for (final key in keys) (key, humanizeKey(key))],
      rows: [
        for (final row in rows)
          {for (final key in keys) key: readString(row[key])},
      ],
    );
  }
}
