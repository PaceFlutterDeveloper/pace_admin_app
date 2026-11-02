import 'dart:async';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/attendance_calendar/repository/attendance_repository.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_response_model.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_record_status.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/home/utils/home_attendance_summary.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AttendanceModel _day(
  String date,
  String stat, {
  String userId = '772',
  String? checkInTime,
  String checkOutTime = '',
}) {
  final marked = stat == 'present' || stat == 'late' || stat == 'early';
  return AttendanceModel(
    userId: userId,
    attDate: DateTime.parse(date),
    checkIn: marked ? 1 : 0,
    checkOut: checkOutTime.isEmpty ? 0 : 1,
    checkInTime: checkInTime ?? (stat == 'present' ? '06:56 AM' : ''),
    checkOutTime: checkOutTime,
    status: stat,
  );
}

void main() {
  var user = 'pace:772';
  final originalKey = LoadMarker.sessionKey;

  setUp(() {
    user = 'pace:772';
    LoadMarker.sessionKey = () => user;
  });

  tearDown(() => LoadMarker.sessionKey = originalKey);

  test('an html error page becomes a readable attendance error', () {
    const notice =
        'A system error occurred. We apologize for the inconvenience. '
        'Please contact PACE Group IT Department.';
    final html =
        '<div style="color: red !important; font-weight: bold !important; '
        'background-color: #ffe6e6 !important;">$notice</div>'
        '<div style="color: red !important;">$notice</div>';

    expect(attendanceFailureMessage(html), notice);
    expect(
      attendanceFailureMessage(
        '<p>require_once(./modules/profile/pages/userAttendance.php): '
        'Failed to open stream: No such file or directory in '
        '/var/www/html/schools/ERP/erp-api/index.php</p>',
      ),
      'Could not load attendance',
    );
  });

  test('present, leave and weekend are not treated as absent', () {
    expect(
      attendanceRecordStatusLabel(_day('2026-10-27', 'present')),
      'Present',
    );
    expect(attendanceRecordStatusColor('Present'), Colors.green);
    expect(attendanceRecordStatusLabel(_day('2026-10-06', 'leave')), 'Leave');
    expect(
      attendanceRecordStatusLabel(_day('2026-10-02', 'weekend')),
      'Weekend',
    );
    expect(attendanceRecordStatusLabel(_day('2026-10-28', '')), 'Not marked');
    expect(attendanceRecordStatusLabel(_day('2026-10-01', 'P')), 'Present');
    expect(attendanceRecordStatusLabel(_day('2026-10-01', 'absent')), 'Absent');
    expect(attendanceDayMarksCalendar(_day('2026-10-27', 'present')), isTrue);
    expect(attendanceDayMarksCalendar(_day('2026-10-02', 'weekend')), isFalse);
    expect(attendanceDayMarksCalendar(_day('2026-10-28', '')), isFalse);
  });

  test('the home card uses the dashboard attendance for this login', () {
    final dashboard = StaffDashboard.fromData({
      'attendance': {
        'today': {
          'check_in': '07:11',
          'check_out': '14:05',
          'status': 'present',
        },
        'month': {
          'percentage': 63,
          'absent_days': 10,
          'present_days': 17,
          'late_days': 2,
          'early_days': 1,
        },
      },
    });
    final summary = summariesFromDashboard(
      dashboard.attendance!,
      DateTime(2026, 10, 27, 12, 33),
    );

    expect(summary.today.pillLabel, 'Present');
    expect(summary.today.markedAt, DateTime(2026, 10, 27, 7, 11));
    expect(summary.today.checkedOutAt, DateTime(2026, 10, 27, 14, 5));
    expect(summary.month.percentage, 63);
    expect(summary.month.absences, 10);
    expect(summary.month.presentDays, 17);
    expect(summary.month.lateArrivals, 2);
    expect(summary.month.earlyDepartures, 1);
    expect(summary.today.earlyMinutes, isNull);
  });

  test('today early minutes are appended only when the person left early', () {
    final early = StaffDashboard.fromData({
      'attendance': {
        'today': {
          'check_in': '07:11',
          'check_out': '13:40',
          'status': 'present',
          'early_minutes': 25,
        },
        'month': {'early_days': 1},
      },
    });
    final summary = summariesFromDashboard(
      early.attendance!,
      DateTime(2026, 10, 27, 14),
    );
    expect(early.attendance!.earlyMinutes, 25);
    expect(summary.today.earlyMinutes, 25);
    expect(summary.month.earlyDepartures, 1);

    final onTime = StaffDashboard.fromData({
      'attendance': {
        'today': {'status': 'present', 'early_minutes': 0},
        'month': {'early_days': 0},
      },
    });
    expect(onTime.attendance!.earlyMinutes, isNull);
  });

  test('the tasks badge reads pending from the dashboard summary', () {
    final nested = StaffDashboard.fromData({
      'tasks': {'pending': 41, 'due_today': 3, 'overdue': 1},
    });
    expect(nested.tasksPending, 41);
    expect(nested.tasksDueToday, 3);
    expect(nested.tasksOverdue, 1);

    final topLevel = StaffDashboard.fromData({'tasks_pending': 7});
    expect(topLevel.tasksPending, 7);

    final hyphen = StaffDashboard.fromData({'tasks-pending': 2});
    expect(hyphen.tasksPending, 2);

    final missing = StaffDashboard.fromData({
      'tasks': {'due_today': 1},
    });
    expect(missing.tasksPending, isNull);
  });

  test('leave taken reads taken_days from the dashboard summary', () {
    final dashboard = StaffDashboard.fromData({
      'leave': {
        'taken_days': 2,
        'taken': [
          {'type': 'Emergency Leave (CL)', 'days': 1},
          {'type': 'Medical Leave - Full pay', 'days': 1},
        ],
      },
    });
    expect(dashboard.leaveTaken, 2);
    expect(dashboard.leave?.map((row) => row.type), [
      'Emergency Leave (CL)',
      'Medical Leave - Full pay',
    ]);
  });

  test('leave taken sums balance rows and ignores a missing taken field', () {
    final withTaken = StaffDashboard.fromData({
      'leave': {
        'balance': [
          {'type': 'Annual', 'remaining': 10, 'taken': 2},
          {'type': 'Sick', 'remaining': 5, 'taken': 1.5},
        ],
      },
    });
    expect(withTaken.leaveTaken, 3.5);
    expect(withTaken.leaveLeft, 15);

    final remainingOnly = StaffDashboard.fromData({
      'leave': {
        'balance': [
          {'type': 'Annual', 'remaining': 10},
        ],
      },
    });
    expect(remainingOnly.leaveTaken, isNull);
    expect(remainingOnly.leave, isNotNull);
  });

  test('unread circulars read top-level and nested dashboard counts', () {
    final top = StaffDashboard.fromData({'unread_circulars': 3});
    expect(top.unreadCirculars, 3);

    final legacy = StaffDashboard.fromData({'unread_notices': 4});
    expect(legacy.unreadCirculars, 4);

    final nested = StaffDashboard.fromData({
      'circulars': {'unread': 2},
    });
    expect(nested.unreadCirculars, 2);

    final missing = StaffDashboard.fromData({
      'tasks': {'due_today': 1, 'unread_circulars': 9},
    });
    expect(missing.unreadCirculars, isNull);
  });

  test('a present month is not counted as a month of absences', () {
    final summary = buildAttendanceDashboardSummaries([
      _day('2026-10-27', 'present'),
      _day('2026-10-26', 'present'),
      _day('2026-10-24', 'weekend'),
      _day('2026-10-06', 'leave'),
      _day('2026-10-28', ''),
    ], DateTime(2026, 10, 27, 9));

    expect(summary.month.presentDays, 2);
    expect(summary.month.absences, 0);
    expect(summary.month.lateArrivals, 0);
    expect(summary.month.earlyDepartures, 0);
    expect(summary.month.percentage, 100);
    expect(summary.today.pillLabel, 'Present');
    expect(summary.today.checkedOutAt, isNull);
  });

  test('late arrivals and early departures are counted from the month', () {
    final summary = buildAttendanceDashboardSummaries([
      _day('2026-10-27', 'late', checkOutTime: '03:10 PM'),
      _day(
        '2026-10-26',
        'early',
        checkInTime: '08:00 AM',
        checkOutTime: '12:00 PM',
      ),
      _day('2026-10-25', 'absent'),
    ], DateTime(2026, 10, 27, 16));

    expect(summary.month.presentDays, 0);
    expect(summary.month.absences, 1);
    expect(summary.month.lateArrivals, 1);
    expect(summary.month.earlyDepartures, 1);
    expect(summary.today.pillLabel, 'Late');
    expect(summary.today.checkedOutAt, DateTime(2026, 10, 27, 15, 10));
  });

  test('employee id on a row can differ from the login id', () async {
    final cubit = AttendanceCubit(
      load: (month, year) async => Right<MyError, AttendanceResponseModel>(
        AttendanceResponseModel(
          status: true,
          message: 'Attendance',
          data: [
            _day('2026-10-26', 'present', userId: '772'),
            _day('2026-10-27', 'present', userId: '772'),
          ],
        ),
      ),
    );
    await cubit.getAttendance(month: 10, year: 2026);
    final rows = cubit.state.maybeWhen(
      loadingSuccess: (list) => list,
      orElse: () => <AttendanceModel>[],
    );
    expect(rows, hasLength(2));
    expect(attendanceRecordStatusLabel(rows.last), 'Present');
    await cubit.close();
  });

  test('a late response from the previous user is dropped', () async {
    final gate = Completer<Either<MyError, AttendanceResponseModel>>();
    final cubit = AttendanceCubit(load: (month, year) => gate.future);
    final pending = cubit.getAttendance(month: 10, year: 2026);
    user = 'pace:1';
    cubit.dropSession();
    gate.complete(
      Right<MyError, AttendanceResponseModel>(
        AttendanceResponseModel(
          status: true,
          message: 'Attendance',
          data: [_day('2026-10-01', 'absent', userId: '772')],
        ),
      ),
    );
    await pending;
    expect(
      cubit.state.maybeWhen(initial: () => true, orElse: () => false),
      isTrue,
    );
    await cubit.close();
  });
}
