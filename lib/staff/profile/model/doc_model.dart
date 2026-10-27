import 'dart:convert';

import 'package:admin_app/staff/shared/read_json.dart';

class DocModel {
  final String id;
  final String doc;
  final String issueStat;
  final String expiryStat;
  final String alertDays;
  final String stat;
  final String alias;
  final String docNo;
  final dynamic fileName;
  final String expiryDate;
  final String issueDate;
  final String downloadUrl;

  DocModel({
    required this.id,
    required this.doc,
    required this.issueStat,
    required this.expiryStat,
    required this.alertDays,
    required this.stat,
    required this.alias,
    required this.docNo,
    required this.fileName,
    required this.expiryDate,
    required this.issueDate,
    this.downloadUrl = '',
  });
  factory DocModel.fromJson(String str) => DocModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DocModel.fromMap(Map<String, dynamic> json) => DocModel(
    id: readString(json["id"]),
    doc: readString(json["document"]),
    issueStat: readString(json["issue_stat"]),
    expiryStat: readString(json["expiry_stat"]),
    alertDays: readString(json["alert_days"]),
    stat: readString(json["stat"]),
    alias: readString(json["alias"]),
    docNo: readString(json["doc_no"]),
    fileName: json["file_name"],
    expiryDate: readString(json["expiry_date"]),
    issueDate: readString(json["issue_date"]),
    downloadUrl: readString(json["download_url"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "doc": doc,
    "issue_stat": issueStat,
    "expiry_stat": expiryStat,
    "alert_days": alertDays,
    "stat": stat,
    "alias": alias,
    "doc_no": docNo,
    "file_name": fileName,
    "expiry_date": expiryDate,
    "issue_date": issueDate,
    "download_url": downloadUrl,
  };
}
