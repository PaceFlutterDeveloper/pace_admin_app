// lib/models/student_model_extension.dart
import 'package:admin_app/UI/students/models/student_att_model.dart';
import 'package:admin_app/UI/students/models/student_response_model.dart';

extension StudentModelCopy on StudentModel {
  StudentModel copyWith({
    String? studcode,
    String? fullname,
    String? famcode,
    String? fname,
    String? mobile,
    String? photo,
    String? studentClass,
    String? section,
    String? lastYrClass,
    String? lastYrSec,
    String? joinStat,
    String? secondlang,
    String? stdsex,
    String? acdyear,
    String? religion,
    dynamic joindate,
    String? national,
    String? house,
    String? dob,
    String? birthDate,
    StudentAttModel? att,
  }) {
    return StudentModel(
      studcode: studcode ?? this.studcode,
      fullname: fullname ?? this.fullname,
      famcode: famcode ?? this.famcode,
      fname: fname ?? this.fname,
      mobile: mobile ?? this.mobile,
      photo: photo ?? this.photo,
      studentClass: studentClass ?? this.studentClass,
      section: section ?? this.section,
      lastYrClass: lastYrClass ?? this.lastYrClass,
      lastYrSec: lastYrSec ?? this.lastYrSec,
      joinStat: joinStat ?? this.joinStat,
      secondlang: secondlang ?? this.secondlang,
      stdsex: stdsex ?? this.stdsex,
      acdyear: acdyear ?? this.acdyear,
      religion: religion ?? this.religion,
      joindate: joindate ?? this.joindate,
      national: national ?? this.national,
      house: house ?? this.house,
      dob: dob ?? this.dob,
      birthDate: birthDate ?? this.birthDate,
      att: att ?? this.att,
    );
  }
}
