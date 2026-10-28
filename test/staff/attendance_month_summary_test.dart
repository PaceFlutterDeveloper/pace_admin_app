import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_month_summary.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_record_status.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_status_style.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AttendanceModel _day(
  String date,
  String stat, {
  String checkInTime = '',
  String checkOutTime = '',
}) {
  return AttendanceModel(
    userId: '772',
    attDate: DateTime.parse(date),
    checkIn: checkInTime.isEmpty ? 0 : 1,
    checkOut: checkOutTime.isEmpty ? 0 : 1,
    checkInTime: checkInTime,
    checkOutTime: checkOutTime,
    status: stat,
  );
}

void main() {
  test(
    'present days out of elapsed working days, with a running absence streak',
    () {
      final rows = [
        _day('2026-10-01', 'holiday'),
        _day('2026-10-02', 'weekend'),
        _day('2026-10-03', 'weekend'),
        _day('2026-10-04', 'present'),
        _day('2026-10-05', 'present'),
        _day('2026-10-06', 'absent'),
        _day('2026-10-07', 'absent'),
        _day('2026-10-08', 'present'),
        _day('2026-10-09', 'weekend'),
        _day('2026-10-10', 'weekend'),
        _day('2026-10-11', 'present'),
        _day('2026-10-12', 'present'),
        _day('2026-10-13', 'present'),
        _day('2026-10-14', 'present'),
        _day('2026-10-15', 'present'),
        _day('2026-10-16', 'weekend'),
        _day('2026-10-17', 'weekend'),
        _day('2026-10-18', 'present'),
        _day('2026-10-19', 'present'),
        _day('2026-10-20', 'present'),
        _day('2026-10-21', 'present'),
        _day('2026-10-22', 'present'),
        _day('2026-10-23', 'weekend'),
        _day('2026-10-24', 'weekend'),
        _day('2026-10-25', 'absent'),
        _day('2026-10-26', 'absent'),
        _day('2026-10-27', 'absent'),
        _day('2026-10-28', 'absent'),
        _day('2026-10-29', 'present'),
        _day('2026-10-30', 'weekend'),
        _day('2026-10-31', 'weekend'),
      ];

      final summary = summarizeAttendanceMonth(
        rows: rows,
        month: DateTime(2026, 10),
        today: DateTime(2026, 10, 28),
      );

      expect(summary.present, 13);
      expect(summary.absent, 6);
      expect(summary.late, 0);
      expect(summary.leave, 0);
      expect(summary.workingDays, 19);
      expect(summary.percentage, 68);
      expect(summary.attendedLine, '13 of 19 working days');
      expect(summary.absenceStreak, 4);
      expect(summary.streakLabel, '4 absences in a row');
    },
  );

  test('a future day in the month is not part of the summary', () {
    final summary = summarizeAttendanceMonth(
      rows: [_day('2026-10-01', 'present'), _day('2026-10-29', 'absent')],
      month: DateTime(2026, 10),
      today: DateTime(2026, 10, 1),
    );

    expect(summary.present, 1);
    expect(summary.absent, 0);
    expect(summary.workingDays, 1);
    expect(summary.percentage, 100);
    expect(summary.streakLabel, isNull);
  });

  test('one absence is not called a run', () {
    final summary = summarizeAttendanceMonth(
      rows: [_day('2026-10-05', 'absent')],
      month: DateTime(2026, 10),
      today: DateTime(2026, 10, 5),
    );

    expect(summary.absenceStreak, 1);
    expect(summary.streakLabel, isNull);
  });

  test('weekend days follow the server, including a worked Friday', () {
    final rows = [
      _day('2026-10-02', 'present'),
      _day('2026-10-03', 'weekend'),
      _day('2026-10-04', 'weekend'),
    ];
    final weekends = attendanceWeekendWeekdays(rows);

    expect(weekends, {DateTime.saturday, DateTime.sunday});
    expect(
      attendanceDayAppearance(
        date: DateTime(2026, 10, 2),
        row: rows.first,
        weekendWeekdays: weekends,
      ),
      AttendanceDayKind.present,
    );
    expect(
      attendanceDayAppearance(
        date: DateTime(2026, 10, 9),
        weekendWeekdays: weekends,
      ),
      AttendanceDayKind.unmarked,
    );
    expect(
      attendanceDayAppearance(
        date: DateTime(2026, 10, 10),
        weekendWeekdays: weekends,
      ),
      AttendanceDayKind.weekend,
    );
  });

  test('hours and empty punches', () {
    expect(attendancePunchLabel(''), '—');
    expect(attendancePunchLabel('N/A'), '—');
    expect(attendancePunchLabel('07:11'), '07:11');
    expect(attendanceHoursLabel('', ''), '0h');
    expect(attendanceHoursLabel('08:00 AM', ''), '0h');
    expect(attendanceHoursLabel('08:00 AM', '04:30 PM'), '8h 30m');
    expect(attendanceHoursLabel('07:11', '14:05'), '6h 54m');
  });

  test('late and leave minutes are shown only when the server sends them', () {
    expect(attendanceVarianceLabel(_day('2026-10-07', 'late')), isNull);
    expect(
      attendanceVarianceLabel(
        AttendanceModel(
          userId: '772',
          attDate: DateTime.parse('2026-10-07'),
          checkIn: 1,
          checkOut: 1,
          checkInTime: '07:48 AM',
          checkOutTime: '03:30 PM',
          status: 'late',
          lateMinutes: 18,
        ),
      ),
      'Late by 18 min',
    );
    expect(
      attendanceVarianceLabel(
        AttendanceModel(
          userId: '772',
          attDate: DateTime.parse('2026-10-07'),
          checkIn: 1,
          checkOut: 1,
          checkInTime: '07:00 AM',
          checkOutTime: '01:00 PM',
          status: 'present',
          earlyMinutes: 25,
        ),
      ),
      'Early out by 25 min',
    );
    final both = AttendanceModel(
      userId: '772',
      attDate: DateTime.parse('2026-10-11'),
      checkIn: 1,
      checkOut: 1,
      checkInTime: '08:11 AM',
      checkOutTime: '02:00 PM',
      status: 'late',
      lateMinutes: 11,
      earlyMinutes: 40,
    );
    expect(attendanceLateLabel(both), 'Late by 11 min');
    expect(attendanceEarlyLabel(both), 'Early out by 40 min');
  });

  test('late and leave use different colours and marks', () {
    final late = AttendanceMarkStyle.of(AttendanceDayKind.late, isDark: true);
    final leave = AttendanceMarkStyle.of(AttendanceDayKind.leave, isDark: true);
    final present = AttendanceMarkStyle.of(
      AttendanceDayKind.present,
      isDark: true,
    );

    expect(late.background, const Color(0xFF3A2A14));
    expect(late.foreground, const Color(0xFFFFB547));
    expect(late.badge, StaffGlyphs.clock);
    expect(leave.background, const Color(0xFF2A2342));
    expect(leave.foreground, const Color(0xFFB9A4FF));
    expect(leave.badge, StaffGlyphs.leave);
    expect(late.foreground, isNot(leave.foreground));
    expect(late.badge, isNot(leave.badge));
    expect(present.badge, isNull);
  });

  test('leave_type and late_minutes come from the attendance row', () {
    final late = AttendanceModel.fromMap({
      'user_id': '772',
      'attDate': '2026-10-07',
      'stat': 'late',
      'check_in_time': '07:50 AM',
      'check_out_time': '04:34 PM',
      'late_minutes': 35,
      'leave_type': '',
    });
    final leave = AttendanceModel.fromMap({
      'user_id': '772',
      'attDate': '2026-10-06',
      'stat': 'leave',
      'leave_type': 'Emergency Leave (CL)',
      'late_minutes': 0,
    });

    expect(late.lateMinutes, 35);
    expect(attendanceVarianceLabel(late), 'Late by 35 min');
    expect(leave.lateMinutes, isNull);
    expect(attendanceRecordStatusLabel(leave), 'Emergency Leave (CL)');

    final counts = leaveTypeCounts(
      rows: [late, leave, _day('2026-10-13', 'leave')],
      month: DateTime(2026, 10),
      today: DateTime(2026, 10, 28),
    );
    expect(
      [for (final item in counts) '${item.type}:${item.count}'],
      ['Emergency Leave (CL):1', 'Leave:1'],
    );
  });

  test('a missed punch leaves that dot empty and keeps the other', () {
    final both = _day(
      '2026-10-07',
      'late',
      checkInTime: '07:50 AM',
      checkOutTime: '04:34 PM',
    );
    final missedOut = _day('2026-10-08', 'present', checkInTime: '08:02 AM');
    final missedIn = AttendanceModel(
      userId: '772',
      attDate: DateTime.parse('2026-10-09'),
      checkIn: 0,
      checkOut: 1,
      checkInTime: '',
      checkOutTime: '04:00 PM',
      status: 'present',
    );
    final leave = _day('2026-10-06', 'leave');

    expect(both.hasPunchIn, isTrue);
    expect(both.hasPunchOut, isTrue);
    expect(missedOut.hasPunchIn, isTrue);
    expect(missedOut.hasPunchOut, isFalse);
    expect(missedIn.hasPunchIn, isFalse);
    expect(missedIn.hasPunchOut, isTrue);
    expect(attendanceShowsPunchDots(both, AttendanceDayKind.late), isTrue);
    expect(
      attendanceShowsPunchDots(missedOut, AttendanceDayKind.present),
      isTrue,
    );
    expect(attendanceShowsPunchDots(leave, AttendanceDayKind.leave), isFalse);
    expect(attendanceShowsPunchDots(null, AttendanceDayKind.weekend), isFalse);
  });
}
