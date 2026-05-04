import 'package:admin_app/UI/employee/attendance/models/attendance_model.dart';
import 'package:admin_app/UI/employee/attendance/utils/attendance_record_status.dart';
import 'package:admin_app/UI/home/widgets/home_dashboard_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Present + absent only; holidays and leaves are excluded from the denominator.
double monthlyAttendancePercentage({
  required int presentDays,
  required int absences,
}) {
  final denom = presentDays + absences;
  if (denom == 0) return 0;
  return (100.0 * presentDays) / denom;
}

Color heroAttendancePillDotColor(String statusLabel) {
  switch (statusLabel) {
    case 'Present':
      return const Color(0xFF4CAF50);
    case 'Absent':
      return const Color(0xFFFF5252);
    case 'Holiday':
      return const Color(0xFF64B5F6);
    case 'Casual Leave':
    case 'Sick Leave':
    case 'Annual Leave':
      return const Color(0xFFFFB74D);
    default:
      return const Color(0xFFFF9500);
  }
}

bool _hasMeaningfulCheckIn(String checkInTime) {
  final t = checkInTime.trim();
  return t.isNotEmpty && t.toUpperCase() != 'N/A';
}

/// Parses [timeStr] and merges it onto [calendarDate] as local wall time.
DateTime? _mergeDateWithParsedTime(DateTime calendarDate, String timeStr) {
  final p = timeStr.trim();
  if (p.isEmpty) return null;
  for (final pattern in <String>['hh:mm a', 'h:mm a', 'HH:mm', 'HH:mm:ss']) {
    try {
      final parsed = DateFormat(pattern).parse(p);
      return DateTime(
        calendarDate.year,
        calendarDate.month,
        calendarDate.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
      );
    } catch (_) {}
  }
  return null;
}

({TodayAttendanceSummary today, MonthlyAttendanceSummary month})
buildAttendanceDashboardSummaries(List<AttendanceModel> rows, DateTime now) {
  final inMonth = rows
      .where((r) => r.attDate.year == now.year && r.attDate.month == now.month)
      .toList();

  var presentDays = 0;
  var absences = 0;
  for (final r in inMonth) {
    final label = attendanceRecordStatusLabel(r);
    if (label == 'Present') presentDays++;
    if (label == 'Absent') absences++;
  }

  final month = MonthlyAttendanceSummary(
    percentage: monthlyAttendancePercentage(
      presentDays: presentDays,
      absences: absences,
    ),
    absences: absences,
    presentDays: presentDays,
  );

  AttendanceModel? todayRow;
  for (final r in inMonth) {
    if (DateUtils.isSameDay(r.attDate, now)) {
      todayRow = r;
      break;
    }
  }

  if (todayRow == null) {
    return (today: const TodayAttendanceSummary(), month: month);
  }

  final label = attendanceRecordStatusLabel(todayRow);
  final dot = heroAttendancePillDotColor(label);
  final dayDate = DateUtils.dateOnly(todayRow.attDate);

  if (label == 'Present') {
    final merged = _mergeDateWithParsedTime(dayDate, todayRow.checkInTime);
    final raw = _hasMeaningfulCheckIn(todayRow.checkInTime)
        ? todayRow.checkInTime.trim()
        : null;
    return (
      today: TodayAttendanceSummary(
        markedAt: merged,
        timeDisplayRaw: merged == null ? raw : null,
        pillLabel: 'Present',
        pillDotColor: dot,
      ),
      month: month,
    );
  }

  return (
    today: TodayAttendanceSummary(pillLabel: label, pillDotColor: dot),
    month: month,
  );
}
