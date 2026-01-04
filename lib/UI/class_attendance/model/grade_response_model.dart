import 'dart:convert';

import 'package:admin_app/UI/class_attendance/model/default_grade_model.dart';
import 'package:admin_app/UI/class_attendance/model/grade_data_model.dart';

class GradeResponseModel {
  final bool status;
  final String message;
  final GradeDataModel data;

  GradeResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GradeResponseModel.fromJson(String str) =>
      GradeResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GradeResponseModel.fromMap(Map<String, dynamic> json) =>
      GradeResponseModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? GradeDataModel.fromMap(json["data"])
            : GradeDataModel(
                grades: [],
                dataDefault: DefaultGradeModel(gr: "", sec: ""),
              ),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data.toMap(),
      };
}
