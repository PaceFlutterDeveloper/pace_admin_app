import 'dart:convert';

String nfcResModelToJson(List<NfcResModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NfcResModel {
  final int stat;
  final String studcode;
  final String student;
  final String grade;
  final String remark;

  NfcResModel({
    required this.stat,
    required this.studcode,
    required this.student,
    required this.grade,
    required this.remark,
  });

  /// Accepts either a Map or a JSON string (even double-encoded strings).
  factory NfcResModel.fromAny(dynamic data) {
    final map = _toMap(data);
    return NfcResModel(
      stat: _toInt(map['stat']),
      studcode: (map['studcode'] ?? '').toString(),
      student: (map['student'] ?? '').toString(),
      grade: (map['grade'] ?? '').toString(),
      remark: (map['remark'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "stat": stat,
        "studcode": studcode,
        "student": student,
        "grade": grade,
        "remark": remark,
      };

  // ---- helpers ----

  static Map<String, dynamic> _toMap(dynamic data) {
    // If it's already a Map, return it
    if (data is Map<String, dynamic>) return data;

    // If it's a String, try to decode (and handle double-encoded cases)
    if (data is String) {
      dynamic decoded = jsonDecode(data);
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }
      if (decoded is Map<String, dynamic>) return decoded;
    }

    throw const FormatException('Response is not a valid JSON object');
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
