import 'package:admin_app/staff/shared/read_json.dart';

class DashboardLeave {
  const DashboardLeave({required this.type, required this.remaining});

  final String type;
  final double remaining;
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
  });

  final int? openTickets;
  final int? tasksDueToday;
  final int? tasksOverdue;
  final List<DashboardLeave>? leave;
  final int? unreadNotifications;
  final int? eventsToday;
  final int? approvalsPending;

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
    );
  }
}
