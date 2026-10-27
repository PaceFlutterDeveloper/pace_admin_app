import 'dart:convert';

import 'package:admin_app/staff/shared/read_json.dart';

class DefaultGradeModel {
  final String gr;
  final String sec;

  DefaultGradeModel({required this.gr, required this.sec});

  bool get isAssigned => gr.isNotEmpty && sec.isNotEmpty;

  factory DefaultGradeModel.fromJson(String str) =>
      DefaultGradeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DefaultGradeModel.fromMap(Map<String, dynamic> json) =>
      DefaultGradeModel(
        gr: readString(json['gr'] ?? json['grade'] ?? json['class_key']),
        sec: readString(json['sec'] ?? json['section']),
      );

  Map<String, dynamic> toMap() => {'gr': gr, 'sec': sec};
}
