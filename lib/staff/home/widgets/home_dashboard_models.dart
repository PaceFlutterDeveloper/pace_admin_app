import 'package:flutter/material.dart';

/// Aggregated attendance for the home hero (from `userAttendance` monthly list).
class TodayAttendanceSummary {
  /// Parsed check-in instant when the API time could be parsed (shown as main clock).
  final DateTime? markedAt;

  /// Raw check-in string when parsing failed but the API provided text.
  final String? timeDisplayRaw;

  final String pillLabel;

  /// Dot color for the status pill (designed for the dark hero surface).
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
