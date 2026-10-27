import 'dart:async';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_response_model.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_record_status.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/home/utils/home_attendance_summary.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AttendanceModel _day(String date, String stat, {String userId = '772'}) {
  return AttendanceModel(
    userId: userId,
    attDate: DateTime.parse(date),
    checkIn: stat == 'present' ? 1 : 0,
    checkOut: 0,
    checkInTime: stat == 'present' ? '06:56 AM' : '',
    checkOutTime: '',
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
        'today': {'check_in': '07:11', 'check_out': null, 'status': 'present'},
        'month': {
          'percentage': 63,
          'absent_days': 10,
          'present_days': 17,
          'late_days': 0,
        },
      },
    });
    final summary = summariesFromDashboard(
      dashboard.attendance!,
      DateTime(2026, 10, 27, 12, 33),
    );

    expect(summary.today.pillLabel, 'Present');
    expect(summary.today.markedAt, DateTime(2026, 10, 27, 7, 11));
    expect(summary.month.percentage, 63);
    expect(summary.month.absences, 10);
    expect(summary.month.presentDays, 17);
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
    expect(summary.month.percentage, 100);
    expect(summary.today.pillLabel, 'Present');
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
