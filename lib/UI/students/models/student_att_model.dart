import 'dart:convert';

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

  factory StudentAttModel.fromJson(String str) =>
      StudentAttModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StudentAttModel.fromMap(Map<String, dynamic> json) => StudentAttModel(
        id: json["id"] ?? "",
        studcode: json["studcode"] ?? "",
        comment: json["comment"] ?? "",
        remark: json["remark"] ?? "",
        att: json["att"] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "studcode": studcode,
        "comment": comment,
        "remark": remark,
        "att": att,
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
