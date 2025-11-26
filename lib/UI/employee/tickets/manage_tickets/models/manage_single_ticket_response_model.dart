import 'dart:convert';

import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_model.dart';

class ManageSingleTicketResponseModel {
  final bool status;
  final String message;
  final ManageTicketModel ticket;

  ManageSingleTicketResponseModel({
    required this.status,
    required this.message,
    required this.ticket,
  });

  factory ManageSingleTicketResponseModel.fromJson(String str) =>
      ManageSingleTicketResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ManageSingleTicketResponseModel.fromMap(Map<String, dynamic> json) =>
      ManageSingleTicketResponseModel(
        status: json["status"],
        message: json["message"],
        ticket: ManageTicketModel.fromMap(json["ticket"]),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "ticket": ticket.toMap(),
      };
}
