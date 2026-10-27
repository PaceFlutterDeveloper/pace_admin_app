import 'dart:convert';

import 'package:admin_app/staff/shared/read_json.dart';

class EmpProfileModel {
  final String empId;
  final String dpCatId;
  final String mrMs;
  final String emplName;
  final dynamic emplCode;
  final dynamic fileNo;
  final String designation;
  final String visastat;
  final DateTime? joinDate;
  final String prob;
  final DateTime? jobConf;
  final String jobConfBy;
  final String moeAppDate;
  final String ppNo;
  final String ppExpDate;
  final String lcNo;
  final String lcExpDate;
  final String securityCheck;
  final String visaType;
  final String visaNo;
  final String visaExpDate;
  final String eidNo;
  final String eidExpDate;
  final String dlNo;
  final String dlExpDate;
  final DateTime? dob;
  final String sex;
  final String mStatus;
  final String address;
  final String phone1;
  final String phone2;
  final String email;
  final String schoolEmail;
  final String perHouse;
  final String perTown;
  final String perCity;
  final String perCountry;
  final String perTelRes;
  final String perTelMob;
  final String relName;
  final String relTelMob;
  final String relTelRes;
  final String relTelOff;
  final String stat;
  final String photo;
  final String joinDate1;
  final String jobConf1;
  final String dob1;
  final String remarks;
  final String submittedDoc;
  final String nationality;
  final String emplFname;
  final String emplMname;
  final String emplSpouse;
  final String empStat;
  final String salFromHere;

  EmpProfileModel({
    required this.empId,
    required this.dpCatId,
    required this.mrMs,
    required this.emplName,
    required this.emplCode,
    required this.fileNo,
    required this.designation,
    required this.visastat,
    required this.joinDate,
    required this.prob,
    required this.jobConf,
    required this.jobConfBy,
    required this.moeAppDate,
    required this.ppNo,
    required this.ppExpDate,
    required this.lcNo,
    required this.lcExpDate,
    required this.securityCheck,
    required this.visaType,
    required this.visaNo,
    required this.visaExpDate,
    required this.eidNo,
    required this.eidExpDate,
    required this.dlNo,
    required this.dlExpDate,
    required this.dob,
    required this.sex,
    required this.mStatus,
    required this.address,
    required this.phone1,
    required this.phone2,
    required this.email,
    required this.schoolEmail,
    required this.perHouse,
    required this.perTown,
    required this.perCity,
    required this.perCountry,
    required this.perTelRes,
    required this.perTelMob,
    required this.relName,
    required this.relTelMob,
    required this.relTelRes,
    required this.relTelOff,
    required this.stat,
    required this.photo,
    required this.joinDate1,
    required this.jobConf1,
    required this.dob1,
    required this.remarks,
    required this.submittedDoc,
    required this.nationality,
    required this.emplFname,
    required this.emplMname,
    required this.emplSpouse,
    required this.empStat,
    required this.salFromHere,
  });

  factory EmpProfileModel.fromJson(String str) =>
      EmpProfileModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory EmpProfileModel.fromMap(Map<String, dynamic> json) => EmpProfileModel(
    empId: readString(json["empId"]),
    dpCatId: readString(json["dpCatId"]),
    mrMs: readString(json["mr_ms"]),
    emplName: readString(json["empl_name"]),
    emplCode: json["empl_code"],
    fileNo: json["file_no"],
    designation: readString(json["designation"]),
    visastat: readString(json["visastat"]),
    joinDate: readDate(json["join_date"]),
    prob: readString(json["prob"]),
    jobConf: readDate(json["job_conf"]),
    jobConfBy: readString(json["job_conf_by"]),
    moeAppDate: readString(json["moe_app_date"]),
    ppNo: readString(json["pp_no"]),
    ppExpDate: readString(json["pp_exp_date"]),
    lcNo: readString(json["lc_no"]),
    lcExpDate: readString(json["lc_exp_date"]),
    securityCheck: readString(json["security_check"]),
    visaType: readString(json["visa_type"]),
    visaNo: readString(json["visa_no"]),
    visaExpDate: readString(json["visa_exp_date"]),
    eidNo: readString(json["eid_no"]),
    eidExpDate: readString(json["eid_exp_date"]),
    dlNo: readString(json["dl_no"]),
    dlExpDate: readString(json["dl_exp_date"]),
    dob: readDate(json["dob"]),
    sex: readString(json["sex"]),
    mStatus: readString(json["mStatus"]),
    address: readString(json["address"]),
    phone1: readString(json["phone1"]),
    phone2: readString(json["phone2"]),
    email: readString(json["email"]),
    schoolEmail: readString(json["school_email"]),
    perHouse: readString(json["per_house"]),
    perTown: readString(json["per_town"]),
    perCity: readString(json["per_city"]),
    perCountry: readString(json["per_country"]),
    perTelRes: readString(json["per_tel_res"]),
    perTelMob: readString(json["per_tel_mob"]),
    relName: readString(json["rel_name"]),
    relTelMob: readString(json["rel_tel_mob"]),
    relTelRes: readString(json["rel_tel_res"]),
    relTelOff: readString(json["rel_tel_off"]),
    stat: readString(json["stat"]),
    photo: readString(json["photo"]),
    joinDate1: readString(json["join_date1"]),
    jobConf1: readString(json["job_conf1"]),
    dob1: readString(json["dob1"]),
    remarks: readString(json["remarks"]),
    submittedDoc: readString(json["submitted_doc"]),
    nationality: readString(json["nationality"]),
    emplFname: readString(json["empl_fname"]),
    emplMname: readString(json["empl_mname"]),
    emplSpouse: readString(json["empl_spouse"]),
    empStat: readString(json["emp_stat"]),
    salFromHere: readString(json["sal_from_here"]),
  );

  Map<String, dynamic> toMap() => {
    "empId": empId,
    "dpCatId": dpCatId,
    "mr_ms": mrMs,
    "empl_name": emplName,
    "empl_code": emplCode,
    "file_no": fileNo,
    "designation": designation,
    "visastat": visastat,
    "join_date": _ymd(joinDate),
    "prob": prob,
    "job_conf": _ymd(jobConf),
    "job_conf_by": jobConfBy,
    "moe_app_date": moeAppDate,
    "pp_no": ppNo,
    "pp_exp_date": ppExpDate,
    "lc_no": lcNo,
    "lc_exp_date": lcExpDate,
    "security_check": securityCheck,
    "visa_type": visaType,
    "visa_no": visaNo,
    "visa_exp_date": visaExpDate,
    "eid_no": eidNo,
    "eid_exp_date": eidExpDate,
    "dl_no": dlNo,
    "dl_exp_date": dlExpDate,
    "dob": _ymd(dob),
    "sex": sex,
    "mStatus": mStatus,
    "address": address,
    "phone1": phone1,
    "phone2": phone2,
    "email": email,
    "school_email": schoolEmail,
    "per_house": perHouse,
    "per_town": perTown,
    "per_city": perCity,
    "per_country": perCountry,
    "per_tel_res": perTelRes,
    "per_tel_mob": perTelMob,
    "rel_name": relName,
    "rel_tel_mob": relTelMob,
    "rel_tel_res": relTelRes,
    "rel_tel_off": relTelOff,
    "stat": stat,
    "photo": photo,
    "join_date1": joinDate1,
    "job_conf1": jobConf1,
    "dob1": dob1,
    "remarks": remarks,
    "submitted_doc": submittedDoc,
    "nationality": nationality,
    "empl_fname": emplFname,
    "empl_mname": emplMname,
    "empl_spouse": emplSpouse,
    "emp_stat": empStat,
    "sal_from_here": salFromHere,
  };
}

String _ymd(DateTime? date) {
  if (date == null) return '';
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
