import 'dart:convert';

import 'package:admin_app/staff/shared/read_json.dart';

class StudentAttModel {
  final String id;
  final String studcode;
  final String comment;
  final String att;
  final String remark;

  StudentAttModel({
    required this.id,
    required this.studcode,
    required this.comment,
    required this.remark,
    required this.att,
  });

  bool get isMarked => att == attendancePresent || att == attendanceAbsent;

  factory StudentAttModel.fromJson(String str) =>
      StudentAttModel.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory StudentAttModel.fromMap(Map<String, dynamic> json) => StudentAttModel(
    id: readString(json['id']),
    studcode: readString(json['studcode']),
    comment: readString(json['comment']),
    remark: readString(json['remark']),
    att: readString(json['att'] ?? json['status']),
  );

  Map<String, String> toMap() => {
    'id': id,
    'studcode': studcode,
    'comment': comment,
    'remark': remark,
    'att': att,
  };

  StudentAttModel copyWith({
    String? id,
    String? studcode,
    String? comment,
    String? att,
    String? remark,
  }) {
    return StudentAttModel(
      id: id ?? this.id,
      studcode: studcode ?? this.studcode,
      comment: comment ?? this.comment,
      att: att ?? this.att,
      remark: remark ?? this.remark,
    );
  }
}

const String attendancePresent = '0';
const String attendanceAbsent = '1';
