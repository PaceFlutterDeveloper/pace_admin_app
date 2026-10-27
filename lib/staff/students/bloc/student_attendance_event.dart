part of 'student_attendance_bloc.dart';

abstract class StudentAttendanceEvent extends Equatable {
  const StudentAttendanceEvent();

  @override
  List<Object> get props => [];
}

class ClearStudentAttendanceEvent extends StudentAttendanceEvent {}

class FetchStudentsEvent extends StudentAttendanceEvent {
  final String grade;
  final String section;

  /// Keeps the current roll on screen while a newer copy loads.
  final bool quiet;

  const FetchStudentsEvent({
    required this.grade,
    required this.section,
    this.quiet = false,
  });

  @override
  List<Object> get props => [grade, section, quiet];
}

class MarkAllStudentEvent extends StudentAttendanceEvent {}

class UpdateStudentAttendanceEvent extends StudentAttendanceEvent {
  final String studcode;
  final StudentAttModel studentAttendance;

  const UpdateStudentAttendanceEvent({
    required this.studcode,
    required this.studentAttendance,
  });

  @override
  List<Object> get props => [studcode, studentAttendance];
}

class PostAttendanceEvent extends StudentAttendanceEvent {
  final String type;
  final String grade;
  final String section;

  const PostAttendanceEvent({
    required this.grade,
    required this.type,
    required this.section,
  });

  @override
  List<Object> get props => [grade, type, section];
}
