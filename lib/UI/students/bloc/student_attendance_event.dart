part of 'student_attendance_bloc.dart';

abstract class StudentAttendanceEvent extends Equatable {
  const StudentAttendanceEvent();

  @override
  List<Object> get props => [];
}

class FetchStudentsEvent extends StudentAttendanceEvent {
  final String grade;
  final String section;

  const FetchStudentsEvent({required this.grade, required this.section});
}

class MarkAllStudentEvent extends StudentAttendanceEvent {}

/// Updated event which now takes a complete StudentAttModel
/// along with the student identifier.
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
  final List<StudentModel> students;
  final String type;
  final List<Remark> remarks;
  final String grade;
  final String section;

  const PostAttendanceEvent(
      {required this.grade,
      required this.type,
      required this.section,
      required this.students,
      required this.remarks});
}
