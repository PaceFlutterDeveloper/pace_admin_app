import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String attendanceId;
  final String employeeId;
  final DateTime markedAt;
  final double confidence;
  final bool matched;
  final String message;
  final String schoolName;
  final String? capturedImagePath;

  const AttendanceRecord({
    required this.attendanceId,
    required this.employeeId,
    required this.markedAt,
    required this.confidence,
    required this.matched,
    required this.message,
    required this.schoolName,
    this.capturedImagePath,
  });

  @override
  List<Object?> get props => [
        attendanceId,
        employeeId,
        markedAt,
        confidence,
        matched,
        message,
        schoolName,
        capturedImagePath,
      ];
}
