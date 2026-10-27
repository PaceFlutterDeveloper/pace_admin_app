part of 'student_attendance_bloc.dart';

abstract class StudentAttendanceState extends Equatable {
  const StudentAttendanceState();

  @override
  List<Object> get props => [];
}

class StudentInitial extends StudentAttendanceState {}

class StudentLoadingState extends StudentAttendanceState {}

class StudentLoadedState extends StudentAttendanceState {
  final String grade;
  final String section;
  final List<StudentModel> students;
  final List<Remark> remarks;
  final bool saving;
  final String? notice;
  final bool noticeIsError;

  const StudentLoadedState({
    required this.grade,
    required this.section,
    required this.students,
    required this.remarks,
    this.saving = false,
    this.notice,
    this.noticeIsError = false,
  });

  bool matches(String grade, String section) =>
      this.grade == grade && this.section == section;

  StudentLoadedState copyWith({
    List<StudentModel>? students,
    List<Remark>? remarks,
    bool? saving,
    String? notice,
    bool? noticeIsError,
    bool clearNotice = false,
  }) {
    return StudentLoadedState(
      grade: grade,
      section: section,
      students: students ?? this.students,
      remarks: remarks ?? this.remarks,
      saving: saving ?? this.saving,
      notice: clearNotice ? null : (notice ?? this.notice),
      noticeIsError: clearNotice
          ? false
          : (noticeIsError ?? this.noticeIsError),
    );
  }

  @override
  List<Object> get props => [
    grade,
    section,
    students,
    remarks,
    saving,
    notice ?? '',
    noticeIsError,
  ];
}

class StudentErrorState extends StudentAttendanceState {
  final String message;
  final String grade;
  final String section;

  const StudentErrorState({
    required this.message,
    this.grade = '',
    this.section = '',
  });

  bool matches(String grade, String section) =>
      this.grade == grade && this.section == section;

  @override
  List<Object> get props => [message, grade, section];
}
