import 'package:admin_app/staff/shared/read_json.dart';

class DashboardLeave {
  const DashboardLeave({required this.type, this.remaining, this.taken});

  final String type;
  final double? remaining;

  /// Days already used for this leave type.
  final double? taken;
}

/// Today's mark and this month's totals from `page=dashboard` `attendance`.
class DashboardAttendance {
  const DashboardAttendance({
    this.checkIn,
    this.checkOut,
    this.todayStatus = '',
    this.percentage = 0,
    this.absentDays = 0,
    this.presentDays = 0,
    this.lateDays = 0,
    this.earlyDays = 0,
  });

  final String? checkIn;
  final String? checkOut;
  final String todayStatus;
  final double percentage;
  final int absentDays;
  final int presentDays;
  final int lateDays;

  /// Days this month the person left before the end of their shift.
  final int earlyDays;

  factory DashboardAttendance.fromMap(Map<dynamic, dynamic> raw) {
    final today = raw['today'];
    final month = raw['month'];
    final todayMap = today is Map ? today : const <dynamic, dynamic>{};
    final monthMap = month is Map ? month : const <dynamic, dynamic>{};
    final checkIn = readString(todayMap['check_in']);
    final checkOut = readString(todayMap['check_out']);
    return DashboardAttendance(
      checkIn: checkIn.isEmpty ? null : checkIn,
      checkOut: checkOut.isEmpty ? null : checkOut,
      todayStatus: readString(todayMap['status']),
      percentage: readNum(monthMap['percentage']),
      absentDays: readInt(monthMap['absent_days']),
      presentDays: readInt(monthMap['present_days']),
      lateDays: readInt(monthMap['late_days']),
      earlyDays: readInt(
        monthMap['early_days'] ??
            monthMap['early_going'] ??
            monthMap['early_departures'],
      ),
    );
  }
}

/// Counters for the Home screen from `page=dashboard`. A module the school
/// has not switched on arrives as null, and the matching tile says so.
class StaffDashboard {
  const StaffDashboard({
    this.openTickets,
    this.tasksDueToday,
    this.tasksOverdue,
    this.leave,
    this.unreadNotifications,
    this.eventsToday,
    this.approvalsPending,
    this.attendance,
    this.taken,
  });

  final int? openTickets;
  final int? tasksDueToday;
  final int? tasksOverdue;
  final List<DashboardLeave>? leave;
  final int? unreadNotifications;
  final int? eventsToday;
  final int? approvalsPending;
  final DashboardAttendance? attendance;

  /// Total leave already taken, when the summary sends one number.
  final double? taken;

  /// Days left across every leave type, or null when the summary has no balance.
  double? get leaveLeft {
    final items = leave;
    if (items == null) return null;
    var any = false;
    var sum = 0.0;
    for (final item in items) {
      final left = item.remaining;
      if (left == null) continue;
      any = true;
      sum += left;
    }
    return any ? sum : null;
  }

  /// Leave already taken. Uses `taken_days` when the summary sends it,
  /// otherwise the sum of each type.
  double? get leaveTaken {
    if (taken != null) return taken;
    final items = leave;
    if (items == null) return null;
    var any = false;
    var sum = 0.0;
    for (final item in items) {
      final used = item.taken;
      if (used == null) continue;
      any = true;
      sum += used;
    }
    return any ? sum : null;
  }

  static int? _count(dynamic value) => value == null ? null : readInt(value);

  factory StaffDashboard.fromData(Map<String, dynamic> data) {
    final tickets = data['tickets'];
    final tasks = data['tasks'];
    final leave = data['leave'];
    final attendance = data['attendance'];
    return StaffDashboard(
      openTickets: tickets is Map ? _count(tickets['open']) : null,
      tasksDueToday: tasks is Map ? _count(tasks['due_today']) : null,
      tasksOverdue: tasks is Map ? _count(tasks['overdue']) : null,
      leave: _leaveRows(leave),
      taken: leave is Map ? _leaveTotal(leave) : null,
      unreadNotifications: _count(data['unread_notifications']),
      eventsToday: _count(data['events_today']),
      approvalsPending: _count(data['approvals_pending']),
      attendance: attendance is Map
          ? DashboardAttendance.fromMap(attendance)
          : null,
    );
  }
}

/// `taken_days` is the total. `taken` is a list of `{type, days}`, not a number.
double? _leaveTotal(Map<dynamic, dynamic> leave) {
  final total = _optionalNum(leave, const [
    'taken_days',
    'leave_taken',
    'days_taken',
  ]);
  if (total != null) return total;
  final taken = leave['taken'];
  if (taken is num || taken is String) {
    return _optionalNum(leave, const ['taken']);
  }
  return null;
}

List<DashboardLeave>? _leaveRows(dynamic leave) {
  if (leave is! Map) return null;
  if (leave['taken'] is List) {
    return [
      for (final row in objectList(leave['taken']))
        DashboardLeave(
          type: readString(row['type']),
          taken: _optionalNum(row, const ['days', 'taken']),
        ),
    ];
  }
  if (leave['balance'] is List) {
    return [
      for (final row in objectList(leave['balance']))
        DashboardLeave(
          type: readString(row['type']),
          remaining: _optionalNum(row, const ['remaining']),
          taken: _optionalNum(row, const ['taken', 'used', 'availed', 'days']),
        ),
    ];
  }
  return null;
}

/// First numeric field that is actually present. Missing keys stay null so a
/// zero that was never sent is not treated as zero leave taken.
double? _optionalNum(Map<dynamic, dynamic> row, List<String> keys) {
  for (final key in keys) {
    if (!row.containsKey(key)) continue;
    final value = row[key];
    if (value == null) continue;
    if (value is String && value.trim().isEmpty) continue;
    return readNum(value);
  }
  return null;
}
