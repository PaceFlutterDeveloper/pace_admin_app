import 'dart:convert';

import 'package:admin_app/staff/shared/read_json.dart';

class GradeModel {
  final String classKey;
  final String className;
  final List<String> sections;

  GradeModel({
    required this.classKey,
    required this.className,
    required this.sections,
  });

  /// Value sent as `gr` when opening the roll. The class list uses `class_key`.
  String get gradeCode => classKey.isNotEmpty ? classKey : className;

  String get label => className.isNotEmpty ? className : gradeCode;

  factory GradeModel.fromJson(String str) =>
      GradeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GradeModel.fromMap(Map<String, dynamic> json) {
    final key = readString(
      json['class_key'] ?? json['gr'] ?? json['grade'] ?? json['id'],
    );
    final name = readString(
      json['class_value'] ?? json['class_name'] ?? json['name'],
    );
    return GradeModel(
      classKey: key,
      className: name,
      sections: readSections(
        json['sections'] ?? json['section'] ?? json['secs'],
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'class_key': classKey,
    'class_value': className,
    'sections': sections,
  };
}

List<String> readSections(dynamic raw) {
  if (raw is List) {
    final names = <String>[];
    for (final item in raw) {
      final name = item is Map
          ? readString(item['sec'] ?? item['section'] ?? item['name'])
          : readString(item);
      if (name.isNotEmpty) names.add(name);
    }
    return names;
  }
  final text = readString(raw);
  if (text.isEmpty) return const [];
  return [
    for (final part in text.split(','))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}
