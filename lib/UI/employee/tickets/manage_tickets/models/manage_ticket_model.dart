// lib/models/ticket.dart
import 'dart:convert';

import 'package:admin_app/UI/employee/tickets/manage_tickets/models/status_option.dart';

class ManageTicketModel {
  final int id;
  final String description;
  final String createdAt;
  final String ticketType;
  final String category;
  final String locationName;
  final String blockName;
  final String priorityName;
  final String statusName;
  final String color;
  final String requesterName;
  final List<StatusOption>? statusOptions;
  final int? endStat;
  final int? assignedTo;
  final String? attachment;

  ManageTicketModel({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.ticketType,
    required this.category,
    required this.locationName,
    required this.blockName,
    required this.priorityName,
    required this.statusName,
    required this.color,
    required this.requesterName,
    required this.statusOptions,
    required this.endStat,
    required this.assignedTo,
    required this.attachment,
  });

  /// Decode from a raw JSON string
  factory ManageTicketModel.fromJson(String str) =>
      ManageTicketModel.fromJson(json.decode(str));

  /// Encode to a raw JSON string
  String toJson() => json.encode(toJson());

  /// Decode from a Map (parsed JSON)
  factory ManageTicketModel.fromMap(Map<String, dynamic> json) =>
      ManageTicketModel(
          id: json['ticket_id'] as int,
          description: json['description'] as String,
          createdAt: json['created_at'] as String,
          ticketType: json['ticket_type'] as String,
          category: json['category'] as String,
          locationName: json['location_name'] as String,
          blockName: json['block_name'] as String,
          priorityName: json['priority_name'] as String,
          statusName: json['status_name'] as String,
          color: json['color'] as String,
          requesterName: json['requester_name'] as String,
          endStat: json['end_stat'] == null ? null : json['end_stat'] as int,
          assignedTo:
              json['assigned_to'] == null ? null : json['assigned_to'] as int,
          statusOptions:
              json['status_options'] == null
                  ? null
                  : (json['status_options'] as List<dynamic>)
                      .map((e) =>
                          StatusOption.fromJson(e as Map<String, dynamic>))
                      .toList(),
          attachment:
              json['attachment'] == null ? null : json['attachment'] as String);

  /// Encode to a Map (before JSON serialization)
  Map<String, dynamic> toMap() => {
        'ticket_id': id,
        'description': description,
        'created_at': createdAt,
        'ticket_type': ticketType,
        'category': category,
        'location_name': locationName,
        'block_name': blockName,
        'priority_name': priorityName,
        'status_name': statusName,
        'color': color,
      };
}
