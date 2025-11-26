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

  factory AttendanceResponseModel.fromMap(Map<String, dynamic> json) =>
      AttendanceResponseModel(
        status: json["status"],
        message: json["message"],
        data: List<AttendanceModel>.from(
            json["data"].map((x) => AttendanceModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}
