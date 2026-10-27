import 'dart:convert';

import 'package:admin_app/staff/class_attendance/model/default_grade_model.dart';
import 'package:admin_app/staff/class_attendance/model/grade_model.dart';
import 'package:admin_app/staff/shared/read_json.dart';

class GradeDataModel {
  final List<GradeModel> grades;
  final DefaultGradeModel dataDefault;

  GradeDataModel({required this.grades, required this.dataDefault});

  bool get isEmpty => grades.isEmpty && !dataDefault.isAssigned;

  /// Display name for a class code, falling back to the code itself.
  String labelFor(String code) {
    for (final grade in grades) {
      if (grade.gradeCode == code || grade.label == code) return grade.label;
    }
    return code;
  }

  factory GradeDataModel.fromJson(String str) =>
      GradeDataModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GradeDataModel.fromMap(Map<String, dynamic> json) => GradeDataModel(
    grades: [
      for (final item in objectList(json['grades'] ?? json['classes']))
        GradeModel.fromMap(item),
    ],
    dataDefault: json['default'] is Map
        ? DefaultGradeModel.fromMap(
            Map<String, dynamic>.from(json['default'] as Map),
          )
        : DefaultGradeModel(gr: '', sec: ''),
  );

  Map<String, dynamic> toMap() => {
    'grades': List<dynamic>.from(grades.map((x) => x.toMap())),
    'default': dataDefault.toMap(),
  };
}
