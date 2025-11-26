import 'dart:convert';

import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_model.dart';

class TicketResponseModel {
  final bool status;
  final String message;
  final List<TicketModel>? data;

  TicketResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TicketResponseModel.fromJson(String str) =>
      TicketResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TicketResponseModel.fromMap(Map<String, dynamic> json) =>
      TicketResponseModel(
        status: json["status"],
        message: json["message"],
        data: json['tickets'] == null
            ? null
            : List<TicketModel>.from(
                json["tickets"].map((x) => TicketModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
      };
}
