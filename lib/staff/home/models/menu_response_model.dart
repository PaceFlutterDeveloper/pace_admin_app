import 'dart:convert';

import 'package:admin_app/staff/home/models/menu_model.dart';

class MenuResponseModel {
  final bool status;
  final String message;
  final List<MenuModel> data;
  final int count;

  MenuResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.count,
  });

  factory MenuResponseModel.fromJson(String str) =>
      MenuResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MenuResponseModel.fromMap(Map<String, dynamic> json) =>
      MenuResponseModel(
        status: json["status"] == true,
        count: _menuCount(json['count']),
        message: json["message"]?.toString() ?? '',
        data: [
          for (final item in (json["data"] as List? ?? const []))
            if (item is Map)
              MenuModel.fromMap(Map<String, dynamic>.from(item)),
        ],
      );

  Map<String, dynamic> toMap() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}

int _menuCount(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
