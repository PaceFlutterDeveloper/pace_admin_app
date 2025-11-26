import 'dart:convert';

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
  });
  factory DocModel.fromJson(String str) => DocModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DocModel.fromMap(Map<String, dynamic> json) => DocModel(
        id: json["id"],
        doc: json["document"] ?? "",
        issueStat: json["issue_stat"],
        expiryStat: json["expiry_stat"],
        alertDays: json["alert_days"],
        stat: json["stat"],
        alias: json["alias"],
        docNo: json["doc_no"],
        fileName: json["file_name"],
        expiryDate: json["expiry_date"],
        issueDate: json["issue_date"],
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
      };
}
