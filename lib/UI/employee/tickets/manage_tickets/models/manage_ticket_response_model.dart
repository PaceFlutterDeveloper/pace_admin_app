import 'dart:convert';

import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/ticket_count_model.dart';

class ManageTicketResponseModel {
  final bool status;
  final String message;
  final List<ManageTicketModel>? data;
  final CountsModel? counts;
  ManageTicketResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.counts,
  });

  factory ManageTicketResponseModel.fromJson(String str) =>
      ManageTicketResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ManageTicketResponseModel.fromMap(Map<String, dynamic> json) =>
      ManageTicketResponseModel(
        status: json["status"],
        message: json["message"],
        counts:
            json["counts"] == null ? null : CountsModel.fromMap(json["counts"]),
        data: json['tickets'] == null
            ? null
            : List<ManageTicketModel>.from(
                json["tickets"].map((x) => ManageTicketModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
      };
}
