import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_record_status.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/home/widgets/home_dashboard_models.dart';
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
    case 'Late':
      return const Color(0xFFFFB74D);
    case 'Early exit':
      return const Color(0xFFFF8A65);
    case 'Leave':
    case 'Casual Leave':
    case 'Sick Leave':
    case 'Annual Leave':
      return const Color(0xFFFFB74D);
    case 'Weekend':
    case 'Not marked':
      return const Color(0xFF9E9E9E);
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

String _dashboardStatusLabel(String status) {
  if (_isEarlyStatus(status)) return 'Early exit';
  switch (status.trim().toLowerCase()) {
    case 'p':
    case 'present':
      return 'Present';
    case 'a':
    case 'absent':
      return 'Absent';
    case 'late':
      return 'Late';
    case 'leave':
      return 'Leave';
    case 'holiday':
      return 'Holiday';
    case 'weekend':
      return 'Weekend';
    default:
      return 'Not marked';
  }
}

bool _isEarlyStatus(String status) {
  switch (status.trim().toLowerCase()) {
    case 'early':
    case 'eg':
    case 'early going':
    case 'early exit':
    case 'early departure':
    case 'early_going':
    case 'left early':
      return true;
    default:
      return false;
  }
}

({DateTime? at, String? raw}) _punch(DateTime day, String? time) {
  final text = time?.trim() ?? '';
  if (!_hasMeaningfulCheckIn(text)) return (at: null, raw: null);
  final merged = _mergeDateWithParsedTime(day, text);
  return (at: merged, raw: merged == null ? text : null);
}

TodayAttendanceSummary _todaySummary({
  required DateTime day,
  required String label,
  required String? checkIn,
  required String? checkOut,
  int? earlyMinutes,
}) {
  final punchIn = _punch(day, checkIn);
  final punchOut = _punch(day, checkOut);
  return TodayAttendanceSummary(
    markedAt: punchIn.at,
    timeDisplayRaw: punchIn.raw,
    checkedOutAt: punchOut.at,
    checkOutRaw: punchOut.raw,
    earlyMinutes: earlyMinutes != null && earlyMinutes > 0
        ? earlyMinutes
        : null,
    pillLabel: label,
    pillDotColor: heroAttendancePillDotColor(label),
  );
}

/// Home hero numbers from `page=dashboard`, which already belongs to the
/// signed-in person. `userAttendance` rows use a different employee id.
({TodayAttendanceSummary today, MonthlyAttendanceSummary month})
summariesFromDashboard(DashboardAttendance attendance, DateTime now) {
  final month = MonthlyAttendanceSummary(
    percentage: attendance.percentage,
    absences: attendance.absentDays,
    presentDays: attendance.presentDays,
    lateArrivals: attendance.lateDays,
    earlyDepartures: attendance.earlyDays,
  );
  final day = DateTime(now.year, now.month, now.day);
  return (
    today: _todaySummary(
      day: day,
      label: _dashboardStatusLabel(attendance.todayStatus),
      checkIn: attendance.checkIn,
      checkOut: attendance.checkOut,
      earlyMinutes: attendance.earlyMinutes,
    ),
    month: month,
  );
}

({TodayAttendanceSummary today, MonthlyAttendanceSummary month})
buildAttendanceDashboardSummaries(List<AttendanceModel> rows, DateTime now) {
  final inMonth = rows
      .where((r) => r.attDate.year == now.year && r.attDate.month == now.month)
      .toList();

  var presentDays = 0;
  var absences = 0;
  var lateArrivals = 0;
  var earlyDepartures = 0;
  for (final r in inMonth) {
    final label = attendanceRecordStatusLabel(r);
    if (label == 'Present') presentDays++;
    if (label == 'Absent') absences++;
    if (label == 'Late') lateArrivals++;
    if (_isEarlyStatus(r.status)) earlyDepartures++;
  }

  final month = MonthlyAttendanceSummary(
    percentage: monthlyAttendancePercentage(
      presentDays: presentDays,
      absences: absences,
    ),
    absences: absences,
    presentDays: presentDays,
    lateArrivals: lateArrivals,
    earlyDepartures: earlyDepartures,
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

  final recordLabel = attendanceRecordStatusLabel(todayRow);
  final label = _isEarlyStatus(todayRow.status) ? 'Early exit' : recordLabel;
  final dayDate = DateUtils.dateOnly(todayRow.attDate);

  return (
    today: _todaySummary(
      day: dayDate,
      label: label,
      checkIn: todayRow.checkInTime,
      checkOut: todayRow.checkOutTime,
      earlyMinutes: todayRow.earlyMinutes,
    ),
    month: month,
  );
}
