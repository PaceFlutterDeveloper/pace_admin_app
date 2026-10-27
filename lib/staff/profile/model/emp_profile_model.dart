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
  final String personalCode;
  final String alias;
  final DateTime? labourJoinDate;
  final DateTime? schoolJoinDate;
  final String department;
  final String localEmirate;
  final String localRegion;
  final String localStreet;
  final String localBuilding;
  final String localLandmark;
  final String phoneCug;
  final String phoneExt;
  final String relRelation;
  final String ministryDesignation;
  final String linkedin;
  final String facebook;
  final String whatsapp;
  final String instagram;
  final String yearlyLeave;
  final String biometricId;
  final String birthPlace;
  final String birthCountry;
  final String religion;
  final String occupation;
  final String nearestAirport;
  final String healthExpDate;
  final String moeStat;
  final String busNo;
  final String foodPref;
  final String ppIssuePlace;

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
    this.personalCode = '',
    this.alias = '',
    this.labourJoinDate,
    this.schoolJoinDate,
    this.department = '',
    this.localEmirate = '',
    this.localRegion = '',
    this.localStreet = '',
    this.localBuilding = '',
    this.localLandmark = '',
    this.phoneCug = '',
    this.phoneExt = '',
    this.relRelation = '',
    this.ministryDesignation = '',
    this.linkedin = '',
    this.facebook = '',
    this.whatsapp = '',
    this.instagram = '',
    this.yearlyLeave = '',
    this.biometricId = '',
    this.birthPlace = '',
    this.birthCountry = '',
    this.religion = '',
    this.occupation = '',
    this.nearestAirport = '',
    this.healthExpDate = '',
    this.moeStat = '',
    this.busNo = '',
    this.foodPref = '',
    this.ppIssuePlace = '',
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
    personalCode: readString(json["personal_code"]),
    alias: readString(json["alias"]),
    labourJoinDate: readDate(json["labour_join_date"]),
    schoolJoinDate: readDate(json["school_join_date"]),
    department: readString(json["department"]),
    localEmirate: readString(json["local_emirate"]),
    localRegion: readString(json["local_region"]),
    localStreet: readString(json["local_street"]),
    localBuilding: readString(json["local_building"]),
    localLandmark: readString(json["local_landmark"]),
    phoneCug: readString(json["phone_cug"]),
    phoneExt: readString(json["phone_ext"]),
    relRelation: readString(json["rel_relation"]),
    ministryDesignation: readString(json["ministry_designation"]),
    linkedin: readString(json["linkedin"]),
    facebook: readString(json["facebook"]),
    whatsapp: readString(json["whatsapp"]),
    instagram: readString(json["instagram"]),
    yearlyLeave: readString(json["yearly_leave"]),
    biometricId: readString(json["biometric_id"]),
    birthPlace: readString(json["birth_place"]),
    birthCountry: readString(json["birth_country"] ?? json["birth_counrty"]),
    religion: readString(json["religion"]),
    occupation: readString(json["occupation"]),
    nearestAirport: readString(json["nearest_airport"]),
    healthExpDate: readString(json["health_exp_date"]),
    moeStat: readString(json["moe_stat"]),
    busNo: readString(json["busNo"]),
    foodPref: readString(json["food_pref"]),
    ppIssuePlace: readString(json["pp_issue_place"]),
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
    "personal_code": personalCode,
    "alias": alias,
    "labour_join_date": _ymd(labourJoinDate),
    "school_join_date": _ymd(schoolJoinDate),
    "department": department,
    "local_emirate": localEmirate,
    "local_region": localRegion,
    "local_street": localStreet,
    "local_building": localBuilding,
    "local_landmark": localLandmark,
    "phone_cug": phoneCug,
    "phone_ext": phoneExt,
    "rel_relation": relRelation,
    "ministry_designation": ministryDesignation,
    "linkedin": linkedin,
    "facebook": facebook,
    "whatsapp": whatsapp,
    "instagram": instagram,
    "yearly_leave": yearlyLeave,
    "biometric_id": biometricId,
    "birth_place": birthPlace,
    "birth_country": birthCountry,
    "religion": religion,
    "occupation": occupation,
    "nearest_airport": nearestAirport,
    "health_exp_date": healthExpDate,
    "moe_stat": moeStat,
    "busNo": busNo,
    "food_pref": foodPref,
    "pp_issue_place": ppIssuePlace,
  };
}

String _ymd(DateTime? date) {
  if (date == null) return '';
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
