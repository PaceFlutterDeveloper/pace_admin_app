import 'dart:convert';

class DefaultGradeModel {
  final String gr;
  final String sec;

  DefaultGradeModel({
    required this.gr,
    required this.sec,
  });

  factory DefaultGradeModel.fromJson(String str) =>
      DefaultGradeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DefaultGradeModel.fromMap(Map<String, dynamic> json) =>
      DefaultGradeModel(
        gr: json["gr"],
        sec: json["sec"],
      );

  Map<String, dynamic> toMap() => {
        "gr": gr,
        "sec": sec,
      };
}
