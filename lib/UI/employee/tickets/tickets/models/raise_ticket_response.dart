// lib/UI/employee/tickets/models/raise_ticket_response.dart

import 'dart:convert';

class RaiseTicketResponse {
  final bool status;
  final String message;

  RaiseTicketResponse({
    required this.status,
    required this.message,
  });

  /// Named constructor for parsing from a Dart map
  factory RaiseTicketResponse.fromMap(Map<String, dynamic> map) {
    return RaiseTicketResponse(
      status: map['status'] as bool,
      message: map['message'] as String,
    );
  }

  /// Parse directly from a JSON-encoded string
  factory RaiseTicketResponse.fromJson(String source) =>
      RaiseTicketResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Convert this object back into a Dart map
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'message': message,
    };
  }

  /// Convert to a JSON-encoded string
  String toJson() => json.encode(toMap());
}
