import 'dart:convert';

class GradeModel {
  final dynamic classKey;
  final String className;
  final List<String> sections;

  GradeModel({
    required this.classKey,
    required this.className,
    required this.sections,
  });

  factory GradeModel.fromJson(String str) =>
      GradeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GradeModel.fromMap(Map<String, dynamic> json) => GradeModel(
        classKey: json["class_key"],
        className: json["class_value"] ?? "",
        sections: json["sections"] != null
            ? List<String>.from(json["sections"].map((x) => x))
            : <String>[],
      );

  Map<String, dynamic> toMap() => {
        "class_key": classKey,
        "class_value": className,
        "sections": List<dynamic>.from(sections.map((x) => x)),
      };
}
