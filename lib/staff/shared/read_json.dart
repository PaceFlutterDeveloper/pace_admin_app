import 'dart:convert';

class StaffApiException implements Exception {
  const StaffApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

String staffErrorMessage(Object error) {
  if (error is StaffApiException && error.message.trim().isNotEmpty) {
    return error.message.trim();
  }
  return 'Something went wrong. Pull to try again.';
}

Map<String, dynamic> decodeJsonMap(dynamic raw) {
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is String && raw.trim().isNotEmpty) {
    final decoded = jsonDecode(raw);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  throw const FormatException('Expected a JSON object');
}

String readString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

int readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(readString(value)) ?? 0;
}

double readNum(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(readString(value)) ?? 0;
}

bool readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = readString(value).toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}

/// Parses an API date. A date-only value stays on that calendar day.
DateTime? readDate(dynamic value) {
  final text = readString(value);
  if (text.isEmpty || text.startsWith('0000')) return null;
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return null;
  if (!text.contains('T') && text.length <= 10) {
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
  return parsed.toLocal();
}

String plainText(String value) {
  return value
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String personName(dynamic value) {
  if (value is Map) {
    final name = readString(
      value['name'] ?? value['empl_name'] ?? value['title'],
    );
    if (name.isNotEmpty) return name;
  }
  return readString(value);
}

List<Map<String, dynamic>> objectList(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}

/// List payload: `data` as an array, or `data.<key>` when the list is wrapped.
List<Map<String, dynamic>> listPayload(Map body, List<String> keys) {
  final data = body['data'];
  if (data is List) return objectList(data);
  if (data is Map) {
    for (final key in keys) {
      if (data[key] is List) return objectList(data[key]);
    }
  }
  return const [];
}

Map<String, dynamic>? objectPayload(Map body) {
  final data = body['data'];
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is List && data.isNotEmpty && data.first is Map) {
    return Map<String, dynamic>.from(data.first as Map);
  }
  return null;
}

Map<String, dynamic>? countsPayload(Map body) {
  if (body['counts'] is Map) {
    return Map<String, dynamic>.from(body['counts'] as Map);
  }
  final data = body['data'];
  if (data is Map && data['counts'] is Map) {
    return Map<String, dynamic>.from(data['counts'] as Map);
  }
  return null;
}
