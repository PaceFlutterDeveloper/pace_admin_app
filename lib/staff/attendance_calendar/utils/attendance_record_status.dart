import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:flutter/material.dart';

/// How a day from `userAttendance` should be read.
///
/// The API sends words (`present`, `absent`, `late`, `leave`, `holiday`,
/// `weekend`, or an empty `stat` for a day that is not marked yet). Older
/// payloads used `P`, `CL`, `SL`, `HL` and `AL`. An empty or unknown stat is
/// not an absence.
enum AttendanceDayKind {
  present,
  absent,
  late,
  leave,
  holiday,
  weekend,
  unmarked,
}

AttendanceDayKind attendanceDayKind(AttendanceModel attendance) {
  switch (attendance.status.trim().toLowerCase()) {
    case 'p':
    case 'present':
      return AttendanceDayKind.present;
    case 'a':
    case 'absent':
      return AttendanceDayKind.absent;
    case 'late':
      return AttendanceDayKind.late;
    case 'cl':
    case 'sl':
    case 'al':
    case 'leave':
    case 'casual leave':
    case 'sick leave':
    case 'annual leave':
      return AttendanceDayKind.leave;
    case 'hl':
    case 'h':
    case 'holiday':
      return AttendanceDayKind.holiday;
    case 'w':
    case 'weekend':
      return AttendanceDayKind.weekend;
    default:
      return AttendanceDayKind.unmarked;
  }
}

/// Label shown on the attendance calendar and the home hero.
String attendanceRecordStatusLabel(AttendanceModel attendance) {
  switch (attendance.status.trim().toUpperCase()) {
    case 'CL':
      return 'Casual Leave';
    case 'SL':
      return 'Sick Leave';
    case 'AL':
      return 'Annual Leave';
    default:
      break;
  }
  switch (attendanceDayKind(attendance)) {
    case AttendanceDayKind.present:
      return 'Present';
    case AttendanceDayKind.absent:
      return 'Absent';
    case AttendanceDayKind.late:
      return 'Late';
    case AttendanceDayKind.leave:
      return 'Leave';
    case AttendanceDayKind.holiday:
      return 'Holiday';
    case AttendanceDayKind.weekend:
      return 'Weekend';
    case AttendanceDayKind.unmarked:
      return 'Not marked';
  }
}

/// Weekends and days the server has not marked yet get no calendar dot.
bool attendanceDayMarksCalendar(AttendanceModel attendance) {
  switch (attendanceDayKind(attendance)) {
    case AttendanceDayKind.weekend:
    case AttendanceDayKind.unmarked:
      return false;
    default:
      return true;
  }
}

Color attendanceRecordStatusColor(String statusLabel) {
  switch (statusLabel) {
    case 'Present':
      return Colors.green;
    case 'Absent':
      return Colors.red;
    case 'Late':
      return Colors.orange;
    case 'Casual Leave':
    case 'Sick Leave':
    case 'Annual Leave':
    case 'Leave':
      return Colors.brown;
    case 'Holiday':
      return Colors.blue;
    case 'Weekend':
    case 'Not marked':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}
