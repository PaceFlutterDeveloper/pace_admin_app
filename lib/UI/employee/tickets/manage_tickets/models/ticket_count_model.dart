import 'dart:convert';

class CountsModel {
  final int unassigned;
  final int assignedActive;
  final int assignedClosed;

  CountsModel({
    required this.unassigned,
    required this.assignedActive,
    required this.assignedClosed,
  });

  factory CountsModel.fromJson(String str) =>
      CountsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CountsModel.fromMap(Map<String, dynamic> json) => CountsModel(
        unassigned: json["unassigned"],
        assignedActive: json["assigned_active"],
        assignedClosed: json["assigned_closed"],
      );

  Map<String, dynamic> toMap() => {
        "unassigned": unassigned,
        "assigned_active": assignedActive,
        "assigned_closed": assignedClosed,
      };
}
