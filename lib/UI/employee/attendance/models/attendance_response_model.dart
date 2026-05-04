import 'dart:convert';

import 'package:admin_app/UI/employee/attendance/models/attendance_model.dart';

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
    final List<AttendanceModel> rows;
    if (dataRaw is List) {
      rows = dataRaw
          .map(
            (x) => AttendanceModel.fromMap(
              Map<String, dynamic>.from(x as Map),
            ),
          )
          .toList();
    } else {
      rows = [];
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
