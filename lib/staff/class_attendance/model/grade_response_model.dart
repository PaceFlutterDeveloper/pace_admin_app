import 'dart:convert';

import 'package:admin_app/staff/class_attendance/model/default_grade_model.dart';
import 'package:admin_app/staff/class_attendance/model/grade_data_model.dart';
import 'package:admin_app/staff/shared/read_json.dart';

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
      GradeResponseModel.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory GradeResponseModel.fromMap(Map<String, dynamic> json) {
    final data = json['data'];
    return GradeResponseModel(
      status: readBool(json['status']),
      message: readString(json['message']),
      data: data is Map
          ? GradeDataModel.fromMap(Map<String, dynamic>.from(data))
          : GradeDataModel(
              grades: const [],
              dataDefault: DefaultGradeModel(gr: '', sec: ''),
            ),
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status,
    'message': message,
    'data': data.toMap(),
  };
}
