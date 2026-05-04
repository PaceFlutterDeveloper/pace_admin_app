import 'package:flutter/material.dart';

/// Aggregated attendance for the home hero (from `userAttendance` monthly list).
class TodayAttendanceSummary {
  /// Parsed check-in instant when the API time could be parsed (shown as main clock).
  final DateTime? markedAt;

  /// Raw check-in string when parsing failed but the API provided text.
  final String? timeDisplayRaw;

  final String pillLabel;

  /// Dot color for the status pill (designed for the dark hero gradient).
  final Color pillDotColor;

  const TodayAttendanceSummary({
    this.markedAt,
    this.timeDisplayRaw,
    this.pillLabel = 'Not marked',
    this.pillDotColor = const Color(0xFFFF9500),
  });
}

class MonthlyAttendanceSummary {
  final double percentage;
  final int absences;
  final int presentDays;

  const MonthlyAttendanceSummary({
    required this.percentage,
    required this.absences,
    required this.presentDays,
  });
}

enum DashboardActivityType { attendance, ticket, nfc, profile, other }

class DashboardActivityItem {
  final String actorName;
  final String initials;
  final DashboardActivityType type;
  final String detailText;
  final String badgeLabel;

  const DashboardActivityItem({
    required this.actorName,
    required this.initials,
    required this.type,
    required this.detailText,
    required this.badgeLabel,
  });
}

/// Demo feed for the dashboard; replace with API when available.
List<DashboardActivityItem> demoDashboardActivities() {
  return const [
    DashboardActivityItem(
      actorName: 'PACE Admin',
      initials: 'PA',
      type: DashboardActivityType.attendance,
      detailText: 'Attendance · Sample overview',
      badgeLabel: 'Info',
    ),
    DashboardActivityItem(
      actorName: 'Facilities',
      initials: 'FC',
      type: DashboardActivityType.ticket,
      detailText: 'Ticket · Follow-up',
      badgeLabel: 'Open',
    ),
    DashboardActivityItem(
      actorName: 'Transport',
      initials: 'TR',
      type: DashboardActivityType.nfc,
      detailText: 'NFC · Terminal check',
      badgeLabel: 'NFC',
    ),
    DashboardActivityItem(
      actorName: 'HR',
      initials: 'HR',
      type: DashboardActivityType.profile,
      detailText: 'Profile · Document update',
      badgeLabel: 'Profile',
    ),
  ];
}
