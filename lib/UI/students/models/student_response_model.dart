import 'dart:convert';

import 'package:admin_app/UI/students/models/student_att_model.dart';

class StudenstsResponseModel {
  final bool status;
  final String message;
  final StudenstsDataModel data;

  StudenstsResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StudenstsResponseModel.fromJson(String str) =>
      StudenstsResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StudenstsResponseModel.fromMap(Map<String, dynamic> json) =>
      StudenstsResponseModel(
        status: json["status"],
        message: json["message"],
        data: StudenstsDataModel.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": data.toMap(),
      };
}

class StudenstsDataModel {
  final List<StudentModel> students;
  final List<Remark> remarks;
  StudenstsDataModel({
    required this.remarks,
    required this.students,
  });

  factory StudenstsDataModel.fromJson(String str) =>
      StudenstsDataModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StudenstsDataModel.fromMap(Map<String, dynamic> json) =>
      StudenstsDataModel(
        remarks:
            List<Remark>.from(json["remarks"].map((x) => Remark.fromMap(x))),
        students: List<StudentModel>.from(
            json["students"].map((x) => StudentModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "students": List<dynamic>.from(students.map((x) => x.toMap())),
      };
}

class StudentModel {
  final String studcode;
  final String photo;
  final String fullname;
  final String famcode;
  final String fname;
  final String mobile;
  final String studentClass;
  final String section;
  final String lastYrClass;
  final String lastYrSec;
  final String joinStat;
  final String secondlang;
  final String stdsex;
  final String acdyear;
  StudentAttModel? att;
  final String religion;
  final dynamic joindate;
  final String national;
  final String house;
  final String dob;
  final String birthDate;

  StudentModel({
    required this.studcode,
    required this.fullname,
    required this.famcode,
    required this.fname,
    required this.mobile,
    required this.photo,
    required this.studentClass,
    required this.section,
    required this.lastYrClass,
    required this.lastYrSec,
    required this.joinStat,
    required this.secondlang,
    required this.stdsex,
    required this.acdyear,
    required this.religion,
    required this.joindate,
    required this.national,
    required this.house,
    required this.dob,
    required this.birthDate,
    required this.att,
  });

  factory StudentModel.fromJson(String str) =>
      StudentModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StudentModel.fromMap(Map<String, dynamic> json) => StudentModel(
      studcode: json["studcode"],
      fullname: json["fullname"],
      famcode: json["famcode"],
      fname: json["fname"],
      mobile: json["mobile"],
      studentClass: json["class"],
      section: json["section"],
      lastYrClass: json["last_yr_class"] ?? "",
      lastYrSec: json["last_yr_sec"] ?? "",
      joinStat: json["join_stat"],
      secondlang: json["SECONDLANG"],
      stdsex: json["STDSEX"],
      acdyear: json["acdyear"],
      religion: json["RELIGION"],
      joindate: json["JOINDATE"],
      att: json['att'] == null ? null : StudentAttModel.fromMap(json['att']),
      national: json["NATIONAL"],
      house: json["HOUSE"],
      dob: json["DOB"],
      birthDate: json["BIRTH_DATE"],
      photo: json['photo'] as String);

  Map<String, dynamic> toMap() => {
        "studcode": studcode,
        "fullname": fullname,
        "famcode": famcode,
        "fname": fname,
        "mobile": mobile,
        "class": studentClass,
        "section": section,
        "last_yr_class": lastYrClass,
        "last_yr_sec": lastYrSec,
        "join_stat": joinStat,
        "SECONDLANG": secondlang,
        "STDSEX": stdsex,
        "acdyear": acdyear,
        "RELIGION": religion,
        "JOINDATE": joindate,
        "NATIONAL": national,
        "HOUSE": house,
        "DOB": dob,
        "BIRTH_DATE": birthDate,
      };
}

class Remark {
  final String key;
  final String value;
  final String remarkType;

  Remark({
    required this.key,
    required this.value,
    required this.remarkType,
  });

  factory Remark.fromJson(String str) => Remark.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Remark.fromMap(Map<String, dynamic> json) => Remark(
        key: json["key"],
        value: json["value"],
        remarkType: json["remark_type"],
      );

  Map<String, dynamic> toMap() => {
        "key": key,
        "value": value,
        "remark_type": remarkType,
      };
}
