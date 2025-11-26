import 'dart:convert';

class EmpProfileModel {
  final String empId;
  final String dpCatId;
  final String mrMs;
  final String emplName;
  final dynamic emplCode;
  final dynamic fileNo;
  final String designation;
  final String visastat;
  final DateTime joinDate;
  final String prob;
  final DateTime jobConf;
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
  final DateTime dob;
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
        empId: json["empId"],
        dpCatId: json["dpCatId"],
        mrMs: json["mr_ms"],
        emplName: json["empl_name"],
        emplCode: json["empl_code"],
        fileNo: json["file_no"],
        designation: json["designation"],
        visastat: json["visastat"],
        joinDate: DateTime.parse(json["join_date"]),
        prob: json["prob"],
        jobConf: DateTime.parse(json["job_conf"]),
        jobConfBy: json["job_conf_by"],
        moeAppDate: json["moe_app_date"],
        ppNo: json["pp_no"],
        ppExpDate: json["pp_exp_date"],
        lcNo: json["lc_no"],
        lcExpDate: json["lc_exp_date"],
        securityCheck: json["security_check"],
        visaType: json["visa_type"],
        visaNo: json["visa_no"],
        visaExpDate: json["visa_exp_date"],
        eidNo: json["eid_no"],
        eidExpDate: json["eid_exp_date"],
        dlNo: json["dl_no"],
        dlExpDate: json["dl_exp_date"],
        dob: DateTime.parse(json["dob"]),
        sex: json["sex"],
        mStatus: json["mStatus"],
        address: json["address"],
        phone1: json["phone1"],
        phone2: json["phone2"],
        email: json["email"],
        schoolEmail: json["school_email"],
        perHouse: json["per_house"],
        perTown: json["per_town"],
        perCity: json["per_city"],
        perCountry: json["per_country"],
        perTelRes: json["per_tel_res"],
        perTelMob: json["per_tel_mob"],
        relName: json["rel_name"],
        relTelMob: json["rel_tel_mob"],
        relTelRes: json["rel_tel_res"],
        relTelOff: json["rel_tel_off"],
        stat: json["stat"],
        photo: json["photo"],
        joinDate1: json["join_date1"],
        jobConf1: json["job_conf1"],
        dob1: json["dob1"],
        remarks: json["remarks"],
        submittedDoc: json["submitted_doc"],
        nationality: json["nationality"],
        emplFname: json["empl_fname"],
        emplMname: json["empl_mname"],
        emplSpouse: json["empl_spouse"],
        empStat: json["emp_stat"],
        salFromHere: json["sal_from_here"],
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
        "join_date":
            "${joinDate.year.toString().padLeft(4, '0')}-${joinDate.month.toString().padLeft(2, '0')}-${joinDate.day.toString().padLeft(2, '0')}",
        "prob": prob,
        "job_conf":
            "${jobConf.year.toString().padLeft(4, '0')}-${jobConf.month.toString().padLeft(2, '0')}-${jobConf.day.toString().padLeft(2, '0')}",
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
        "dob":
            "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
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
