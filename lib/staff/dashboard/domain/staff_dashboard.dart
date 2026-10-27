import 'package:admin_app/staff/shared/read_json.dart';

class DashboardLeave {
  const DashboardLeave({required this.type, required this.remaining});

  final String type;
  final double remaining;
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
  });

  final String? checkIn;
  final String? checkOut;
  final String todayStatus;
  final double percentage;
  final int absentDays;
  final int presentDays;
  final int lateDays;

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
  });

  final int? openTickets;
  final int? tasksDueToday;
  final int? tasksOverdue;
  final List<DashboardLeave>? leave;
  final int? unreadNotifications;
  final int? eventsToday;
  final int? approvalsPending;
  final DashboardAttendance? attendance;

  /// Days left across every leave type, or null when leave is not available.
  double? get leaveLeft {
    final items = leave;
    if (items == null) return null;
    return items.fold<double>(0, (sum, item) => sum + item.remaining);
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
      leave: leave is Map && leave['balance'] is List
          ? [
              for (final row in objectList(leave['balance']))
                DashboardLeave(
                  type: readString(row['type']),
                  remaining: readNum(row['remaining']),
                ),
            ]
          : null,
      unreadNotifications: _count(data['unread_notifications']),
      eventsToday: _count(data['events_today']),
      approvalsPending: _count(data['approvals_pending']),
      attendance: attendance is Map
          ? DashboardAttendance.fromMap(attendance)
          : null,
    );
  }
}
