import 'dart:convert';

import 'package:admin_app/UI/home/models/menu_model.dart';

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
        status: json["status"],
        count: json['count'],
        message: json["message"],
        data:
            List<MenuModel>.from(json["data"].map((x) => MenuModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}
