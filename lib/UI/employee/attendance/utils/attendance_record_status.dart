import 'package:admin_app/UI/employee/attendance/models/attendance_model.dart';
import 'package:flutter/material.dart';

/// Same semantics as the employee attendance calendar ([EmpAttendancePage]).
String attendanceRecordStatusLabel(AttendanceModel attendance) {
  return attendance.status == 'P'
      ? 'Present'
      : attendance.status == 'CL'
      ? 'Casual Leave'
      : attendance.status == 'SL'
      ? 'Sick Leave'
      : attendance.status == 'HL'
      ? 'Holiday'
      : attendance.status == 'AL'
      ? 'Annual Leave'
      : 'Absent';
}

Color attendanceRecordStatusColor(String statusLabel) {
  switch (statusLabel) {
    case 'Present':
      return Colors.green;
    case 'Absent':
      return Colors.red;
    case 'Casual Leave':
    case 'Sick Leave':
    case 'Annual Leave':
      return Colors.brown;
    case 'Holiday':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
