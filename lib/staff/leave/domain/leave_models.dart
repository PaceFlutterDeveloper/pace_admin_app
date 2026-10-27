import 'package:admin_app/staff/shared/read_json.dart';

class LeaveBalance {
  const LeaveBalance({
    required this.typeId,
    required this.type,
    required this.entitled,
    required this.taken,
    required this.pending,
    required this.remaining,
  });

  final int typeId;
  final String type;
  final double entitled;
  final double taken;
  final double pending;
  final double remaining;

  factory LeaveBalance.fromMap(Map<String, dynamic> map) {
    return LeaveBalance(
      typeId: readInt(map['leave_type_id']),
      type: readString(map['type'] ?? map['name']),
      entitled: readNum(map['entitled']),
      taken: readNum(map['taken']),
      pending: readNum(map['pending']),
      remaining: readNum(map['remaining']),
    );
  }
}

class LeaveType {
  const LeaveType({
    required this.id,
    required this.name,
    required this.requiresDocument,
    required this.halfDayAllowed,
    required this.maxDays,
  });

  final int id;
  final String name;
  final bool requiresDocument;
  final bool halfDayAllowed;
  final double maxDays;

  factory LeaveType.fromMap(Map<String, dynamic> map) {
    return LeaveType(
      id: readInt(map['leave_type_id']),
      name: readString(map['name'] ?? map['type']),
      requiresDocument: readBool(map['requires_document']),
      halfDayAllowed: readBool(map['half_day_allowed']),
      maxDays: readNum(map['max_days']),
    );
  }
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
  other;

  static LeaveStatus parse(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'pending':
        return pending;
      case 'approved':
        return approved;
      case 'rejected':
      case 'declined':
        return rejected;
      case 'cancelled':
      case 'canceled':
        return cancelled;
      default:
        return other;
    }
  }

  String get label => switch (this) {
    pending => 'Pending',
    approved => 'Approved',
    rejected => 'Rejected',
    cancelled => 'Cancelled',
    other => 'Unknown',
  };
}

class LeaveTrailStep {
  const LeaveTrailStep({
    required this.action,
    required this.by,
    required this.at,
    required this.comment,
  });

  final String action;
  final String by;
  final DateTime? at;
  final String comment;

  factory LeaveTrailStep.fromMap(Map<String, dynamic> map) {
    return LeaveTrailStep(
      action: readString(map['action'] ?? map['status']),
      by: readString(map['changed_by_name'] ?? map['changed_by'] ?? map['by']),
      at: readDate(map['changed_on'] ?? map['at'] ?? map['changed_at']),
      comment: readString(map['comment']),
    );
  }
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.typeId,
    required this.from,
    required this.to,
    required this.days,
    required this.halfDay,
    required this.status,
    required this.reason,
    required this.approverName,
    required this.approverComment,
    required this.appliedAt,
    this.trail = const [],
  });

  final String id;
  final String type;
  final int typeId;
  final DateTime? from;
  final DateTime? to;
  final double days;
  final String halfDay;
  final LeaveStatus status;
  final String reason;
  final String approverName;
  final String approverComment;
  final DateTime? appliedAt;
  final List<LeaveTrailStep> trail;

  bool get canCancel => status == LeaveStatus.pending;

  factory LeaveRequest.fromMap(Map<String, dynamic> map) {
    return LeaveRequest(
      id: readString(map['request_id']),
      type: readString(map['type'] ?? map['name']),
      typeId: readInt(map['leave_type_id']),
      from: readDate(map['from_date']),
      to: readDate(map['to_date']),
      days: readNum(map['days']),
      halfDay: readString(map['half_day']).toLowerCase(),
      status: LeaveStatus.parse(readString(map['status'])),
      reason: readString(map['reason']),
      approverName: readString(map['approver_name']),
      approverComment: readString(map['approver_comment']),
      appliedAt: readDate(map['applied_at']),
      trail: [
        for (final step in objectList(map['approval_trail'] ?? map['trail']))
          LeaveTrailStep.fromMap(step),
      ],
    );
  }
}

class LeaveOverview {
  const LeaveOverview({required this.balances, required this.requests});

  final List<LeaveBalance> balances;
  final List<LeaveRequest> requests;
}
