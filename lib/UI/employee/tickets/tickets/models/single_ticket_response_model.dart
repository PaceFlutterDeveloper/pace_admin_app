import 'dart:convert';

import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_model.dart';

class SingleTicketResponseModel {
  final bool status;
  final String message;
  final TicketModel ticket;

  SingleTicketResponseModel({
    required this.status,
    required this.message,
    required this.ticket,
  });

  factory SingleTicketResponseModel.fromJson(String str) =>
      SingleTicketResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SingleTicketResponseModel.fromMap(Map<String, dynamic> json) =>
      SingleTicketResponseModel(
        status: json["status"],
        message: json["message"],
        ticket: TicketModel.fromMap(json["ticket"]),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "ticket": ticket.toMap(),
      };
}
