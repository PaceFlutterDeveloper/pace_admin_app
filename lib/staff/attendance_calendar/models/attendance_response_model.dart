import 'dart:convert';

import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';

class AttendanceResponseModel {
  final bool status;
  final String message;
  final List<AttendanceModel> data;

  AttendanceResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AttendanceResponseModel.fromJson(String str) =>
      AttendanceResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AttendanceResponseModel.fromMap(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final rows = <AttendanceModel>[];
    if (dataRaw is List) {
      for (final item in dataRaw) {
        if (item is! Map) continue;
        try {
          rows.add(AttendanceModel.fromMap(Map<String, dynamic>.from(item)));
        } on FormatException {
          // One bad day must not hide the rest of the month.
        }
      }
    }
    return AttendanceResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: rows,
    );
  }

  Map<String, dynamic> toMap() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}
