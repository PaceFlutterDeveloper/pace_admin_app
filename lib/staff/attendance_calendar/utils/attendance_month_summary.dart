import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_record_status.dart';

/// "Late by 35 min" when the row has late minutes.
String? attendanceLateLabel(AttendanceModel row) {
  final late = row.lateMinutes;
  if (late == null || late <= 0) return null;
  return 'Late by $late min';
}

/// "Early out by 12 min" when the row has early minutes.
String? attendanceEarlyLabel(AttendanceModel row) {
  final early = row.earlyMinutes;
  if (early == null || early <= 0) return null;
  return 'Early out by $early min';
}

/// Late note, or the early note when the day is not late.
String? attendanceVarianceLabel(AttendanceModel row) {
  return attendanceLateLabel(row) ?? attendanceEarlyLabel(row);
}

/// Counts for the attendance summary card.
///
/// [present] is the number in "13 of 19 working days" and on the ring.
/// A working day is a day in [month] on or before [today] that is not a
/// weekend and not a holiday. Days later in the month stay on the calendar
/// and stay out of the count.
class AttendanceMonthSummary {
  const AttendanceMonthSummary({
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.workingDays,
    required this.percentage,
    required this.absenceStreak,
  });

  final int present;
  final int absent;
  final int late;
  final int leave;
  final int workingDays;
  final int percentage;
  final int absenceStreak;

  String get attendedLine {
    final noun = workingDays == 1 ? 'working day' : 'working days';
    return '$present of $workingDays $noun';
  }

  /// Shown when absences run back from the latest working day.
  String? get streakLabel {
    if (absenceStreak < 2) return null;
    return '$absenceStreak absences in a row';
  }
}

/// Weekdays the server marked as weekend. Schools here run Sunday to
/// Thursday, so Friday and Saturday are the weekend when the month has
/// no weekend rows yet.
Set<int> attendanceWeekendWeekdays(Iterable<AttendanceModel> rows) {
  final days = <int>{};
  for (final row in rows) {
    if (attendanceDayKind(row) == AttendanceDayKind.weekend) {
      days.add(row.attDate.weekday);
    }
  }
  if (days.isEmpty) return {DateTime.friday, DateTime.saturday};
  return days;
}

/// How a calendar cell should read, including weekends the server did not
/// send a row for.
AttendanceDayKind attendanceDayAppearance({
  required DateTime date,
  AttendanceModel? row,
  required Set<int> weekendWeekdays,
}) {
  if (row != null) {
    final kind = attendanceDayKind(row);
    if (kind != AttendanceDayKind.unmarked) return kind;
  }
  if (weekendWeekdays.contains(date.weekday)) return AttendanceDayKind.weekend;
  return AttendanceDayKind.unmarked;
}

AttendanceMonthSummary summarizeAttendanceMonth({
  required List<AttendanceModel> rows,
  required DateTime month,
  required DateTime today,
}) {
  final year = month.year;
  final monthNumber = month.month;
  final inMonth = [
    for (final row in rows)
      if (row.attDate.year == year && row.attDate.month == monthNumber) row,
  ];
  final byDay = <int, AttendanceModel>{
    for (final row in inMonth) row.attDate.day: row,
  };
  final weekends = attendanceWeekendWeekdays(inMonth);
  final endDay = _lastIncludedDay(year, monthNumber, today);

  var present = 0;
  var absent = 0;
  var late = 0;
  var leave = 0;
  var workingDays = 0;
  for (var day = 1; day <= endDay; day++) {
    final appearance = attendanceDayAppearance(
      date: DateTime(year, monthNumber, day),
      row: byDay[day],
      weekendWeekdays: weekends,
    );
    if (appearance == AttendanceDayKind.weekend ||
        appearance == AttendanceDayKind.holiday) {
      continue;
    }
    workingDays++;
    switch (appearance) {
      case AttendanceDayKind.present:
        present++;
      case AttendanceDayKind.absent:
        absent++;
      case AttendanceDayKind.late:
        late++;
      case AttendanceDayKind.leave:
        leave++;
      case AttendanceDayKind.holiday:
      case AttendanceDayKind.weekend:
      case AttendanceDayKind.unmarked:
    }
  }

  var streak = 0;
  for (var day = endDay; day >= 1; day--) {
    final appearance = attendanceDayAppearance(
      date: DateTime(year, monthNumber, day),
      row: byDay[day],
      weekendWeekdays: weekends,
    );
    if (appearance == AttendanceDayKind.weekend ||
        appearance == AttendanceDayKind.holiday) {
      continue;
    }
    if (appearance == AttendanceDayKind.absent) {
      streak++;
      continue;
    }
    break;
  }

  final percentage = workingDays == 0
      ? 0
      : ((100 * present) / workingDays).round();
  return AttendanceMonthSummary(
    present: present,
    absent: absent,
    late: late,
    leave: leave,
    workingDays: workingDays,
    percentage: percentage,
    absenceStreak: streak,
  );
}

/// One leave type and how many days of it fall in the month so far.
class LeaveTypeCount {
  const LeaveTypeCount({required this.type, required this.count});

  final String type;
  final int count;
}

/// Leave days in [month] on or before [today], grouped by `leave_type`.
List<LeaveTypeCount> leaveTypeCounts({
  required List<AttendanceModel> rows,
  required DateTime month,
  required DateTime today,
}) {
  final year = month.year;
  final monthNumber = month.month;
  final inMonth = [
    for (final row in rows)
      if (row.attDate.year == year && row.attDate.month == monthNumber) row,
  ];
  final byDay = <int, AttendanceModel>{
    for (final row in inMonth) row.attDate.day: row,
  };
  final weekends = attendanceWeekendWeekdays(inMonth);
  final endDay = _lastIncludedDay(year, monthNumber, today);
  final counts = <String, int>{};
  for (var day = 1; day <= endDay; day++) {
    final row = byDay[day];
    final appearance = attendanceDayAppearance(
      date: DateTime(year, monthNumber, day),
      row: row,
      weekendWeekdays: weekends,
    );
    if (appearance != AttendanceDayKind.leave || row == null) continue;
    final type = row.leaveType.trim().isEmpty ? 'Leave' : row.leaveType.trim();
    counts[type] = (counts[type] ?? 0) + 1;
  }
  final items =
      [
        for (final entry in counts.entries)
          LeaveTypeCount(type: entry.key, count: entry.value),
      ]..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) return byCount;
        return a.type.compareTo(b.type);
      });
  return items;
}

int _lastIncludedDay(int year, int month, DateTime today) {
  final start = DateTime(year, month, 1);
  final todayMonth = DateTime(today.year, today.month, 1);
  if (start.isAfter(todayMonth)) return 0;
  final last = DateTime(year, month + 1, 0).day;
  if (year == today.year && month == today.month) {
    return today.day > last ? last : today.day;
  }
  return last;
}

/// Clock text for the day card. Empty punches render as an em dash.
String attendancePunchLabel(String raw) {
  final text = raw.trim();
  if (text.isEmpty ||
      text == '-' ||
      text == '—' ||
      text.toUpperCase() == 'N/A') {
    return '—';
  }
  return text;
}

/// Hours between check-in and check-out, or `0h` when either punch is missing.
String attendanceHoursLabel(String checkIn, String checkOut) {
  final start = _parseClock(checkIn);
  final end = _parseClock(checkOut);
  if (start == null || end == null) return '0h';
  var minutes = end.difference(start).inMinutes;
  if (minutes < 0) minutes += 24 * 60;
  if (minutes <= 0) return '0h';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '${remainder}m';
  if (remainder == 0) return '${hours}h';
  return '${hours}h ${remainder}m';
}

DateTime? _parseClock(String raw) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])?$',
  ).firstMatch(raw.trim());
  if (match == null) return null;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final second = int.parse(match.group(3) ?? '0');
  final ampm = match.group(4)?.toLowerCase();
  if (minute > 59 || second > 59) return null;
  if (ampm == null) {
    if (hour > 23) return null;
  } else {
    if (hour < 1 || hour > 12) return null;
    if (ampm == 'pm' && hour < 12) hour += 12;
    if (ampm == 'am' && hour == 12) hour = 0;
  }
  return DateTime(2000, 1, 1, hour, minute, second);
}
