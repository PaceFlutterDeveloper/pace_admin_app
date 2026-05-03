import 'package:admin_app/features/attendance/domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.attendanceId,
    required super.employeeId,
    required super.markedAt,
    required super.confidence,
    required super.matched,
    required super.message,
    required super.schoolName,
    super.capturedImagePath,
  });

  factory AttendanceRecordModel.fromJson(
    Map<String, dynamic> json, {
    required String employeeId,
    required String schoolName,
    String? capturedImagePath,
  }) {
    return AttendanceRecordModel(
      attendanceId: (json['attendanceId'] ?? '').toString(),
      employeeId: employeeId,
      markedAt: DateTime.tryParse((json['markedAt'] ?? '').toString()) ??
          DateTime.now(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      matched: json['matched'] == true,
      message: (json['message'] ?? '').toString(),
      schoolName: schoolName,
      capturedImagePath: capturedImagePath,
    );
  }
}
