import 'dart:convert';

import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/students/models/student_att_model.dart';

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
      StudenstsResponseModel.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory StudenstsResponseModel.fromMap(Map<String, dynamic> json) {
    final data = json['data'];
    return StudenstsResponseModel(
      status: readBool(json['status']),
      message: readString(json['message']),
      data: data is Map
          ? StudenstsDataModel.fromMap(Map<String, dynamic>.from(data))
          : StudenstsDataModel(remarks: const [], students: const []),
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status,
    'message': message,
    'data': data.toMap(),
  };
}

class StudenstsDataModel {
  final List<StudentModel> students;
  final List<Remark> remarks;

  StudenstsDataModel({required this.remarks, required this.students});

  factory StudenstsDataModel.fromJson(String str) =>
      StudenstsDataModel.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory StudenstsDataModel.fromMap(Map<String, dynamic> json) =>
      StudenstsDataModel(
        remarks: [
          for (final item in objectList(json['remarks'])) Remark.fromMap(item),
        ],
        students: [
          for (final item in objectList(json['students']))
            StudentModel.fromMap(item),
        ],
      );

  Map<String, dynamic> toMap() => {
    'students': List<dynamic>.from(students.map((x) => x.toMap())),
    'remarks': List<dynamic>.from(remarks.map((x) => x.toMap())),
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

  String get displayName => fullname.isNotEmpty ? fullname : studcode;

  /// Date of birth as the server sent it. `BIRTH_DATE` wins over `DOB`.
  String get bornOn => birthDate.isNotEmpty ? birthDate : dob;

  factory StudentModel.fromJson(String str) =>
      StudentModel.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory StudentModel.fromMap(Map<String, dynamic> json) => StudentModel(
    studcode: readString(json['studcode']),
    fullname: readString(json['fullname']),
    famcode: readString(json['famcode']),
    fname: readString(json['fname']),
    mobile: readString(json['mobile']),
    studentClass: readString(json['class']),
    section: readString(json['section']),
    lastYrClass: readString(json['last_yr_class']),
    lastYrSec: readString(json['last_yr_sec']),
    joinStat: readString(json['join_stat']),
    secondlang: readString(json['SECONDLANG']),
    stdsex: readString(json['STDSEX']),
    acdyear: readString(json['acdyear']),
    religion: readString(json['RELIGION']),
    joindate: json['JOINDATE'],
    att: readStudentAttendance(json['att']),
    national: readString(json['NATIONAL']),
    house: readString(json['HOUSE']),
    dob: readString(json['DOB']),
    birthDate: readString(json['BIRTH_DATE']),
    photo: readString(json['photo']),
  );

  Map<String, dynamic> toMap() => {
    'studcode': studcode,
    'fullname': fullname,
    'famcode': famcode,
    'fname': fname,
    'mobile': mobile,
    'class': studentClass,
    'section': section,
    'last_yr_class': lastYrClass,
    'last_yr_sec': lastYrSec,
    'join_stat': joinStat,
    'SECONDLANG': secondlang,
    'STDSEX': stdsex,
    'acdyear': acdyear,
    'RELIGION': religion,
    'JOINDATE': joindate,
    'NATIONAL': national,
    'HOUSE': house,
    'DOB': dob,
    'BIRTH_DATE': birthDate,
    'photo': photo,
    'att': att?.toMap(),
  };
}

StudentAttModel? readStudentAttendance(dynamic raw) {
  if (raw is! Map || raw.isEmpty) return null;
  final att = StudentAttModel.fromMap(Map<String, dynamic>.from(raw));
  if (!att.isMarked && att.remark.isEmpty && att.id.isEmpty) return null;
  return att;
}

class Remark {
  final String key;
  final String value;
  final String remarkType;

  Remark({required this.key, required this.value, required this.remarkType});

  factory Remark.fromJson(String str) =>
      Remark.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory Remark.fromMap(Map<String, dynamic> json) => Remark(
    key: readString(json['key']),
    value: readString(json['value']),
    remarkType: readString(json['remark_type']),
  );

  Map<String, dynamic> toMap() => {
    'key': key,
    'value': value,
    'remark_type': remarkType,
  };
}
