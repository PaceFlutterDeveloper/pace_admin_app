import 'dart:convert';

import 'package:admin_app/UI/notification/models/notification_model.dart';

class NotificationResponseModel {
  final bool status;
  final String message;
  final List<NotificationModel> data;
  final int count;

  NotificationResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.count,
  });

  factory NotificationResponseModel.fromJson(String str) =>
      NotificationResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory NotificationResponseModel.fromMap(Map<String, dynamic> json) =>
      NotificationResponseModel(
        status: json["status"],
        message: json["message"],
        data: List<NotificationModel>.from(
            json["data"].map((x) => NotificationModel.fromMap(x))),
        count: json["count"],
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
        "count": count,
      };
}
