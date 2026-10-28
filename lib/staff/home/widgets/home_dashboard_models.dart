import 'package:flutter/material.dart';

/// Aggregated attendance for the home hero (from `userAttendance` monthly list).
class TodayAttendanceSummary {
  /// Parsed check-in when the API time could be read.
  final DateTime? markedAt;

  /// Raw check-in string when parsing failed but the API provided text.
  final String? timeDisplayRaw;

  /// Parsed check-out when the API time could be read.
  final DateTime? checkedOutAt;

  /// Raw check-out string when parsing failed but the API provided text.
  final String? checkOutRaw;

  final String pillLabel;

  /// Dot color for the status pill (designed for the dark hero surface).
  final Color pillDotColor;

  const TodayAttendanceSummary({
    this.markedAt,
    this.timeDisplayRaw,
    this.checkedOutAt,
    this.checkOutRaw,
    this.pillLabel = 'Not marked',
    this.pillDotColor = const Color(0xFFFF9500),
  });
}

class MonthlyAttendanceSummary {
  final double percentage;
  final int absences;
  final int presentDays;
  final int lateArrivals;
  final int earlyDepartures;

  const MonthlyAttendanceSummary({
    required this.percentage,
    required this.absences,
    required this.presentDays,
    this.lateArrivals = 0,
    this.earlyDepartures = 0,
  });
}
