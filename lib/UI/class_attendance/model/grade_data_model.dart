import 'dart:convert';

import 'package:admin_app/UI/class_attendance/model/default_grade_model.dart';
import 'package:admin_app/UI/class_attendance/model/grade_model.dart';

class GradeDataModel {
  final List<GradeModel> grades;
  final DefaultGradeModel dataDefault;

  GradeDataModel({
    required this.grades,
    required this.dataDefault,
  });

  factory GradeDataModel.fromJson(String str) =>
      GradeDataModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GradeDataModel.fromMap(Map<String, dynamic> json) => GradeDataModel(
        grades: json["grades"] != null
            ? List<GradeModel>.from(
                json["grades"].map((x) => GradeModel.fromMap(x)))
            : <GradeModel>[],
        dataDefault: json["default"] != null
            ? DefaultGradeModel.fromMap(json["default"])
            : DefaultGradeModel(gr: "", sec: ""),
      );

  Map<String, dynamic> toMap() => {
        "grades": List<dynamic>.from(grades.map((x) => x.toMap())),
        "default": dataDefault.toMap(),
      };
}
