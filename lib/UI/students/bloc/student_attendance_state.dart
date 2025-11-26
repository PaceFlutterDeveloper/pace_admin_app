part of 'student_attendance_bloc.dart';

abstract class StudentAttendanceState extends Equatable {
  const StudentAttendanceState();

  @override
  List<Object> get props => [];
}

class StudentInitial extends StudentAttendanceState {}

class StudentLoadingState extends StudentAttendanceState {}

class StudentLoadedState extends StudentAttendanceState {
  final List<StudentModel> students;
  final List<Remark> remarks;
  const StudentLoadedState({
    required this.students,
    required this.remarks,
  });

  @override
  List<Object> get props => [students];
}

class StudentErrorState extends StudentAttendanceState {
  final String message;

  const StudentErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class StudentPostedState extends StudentAttendanceState {
  final String message;

  const StudentPostedState({required this.message});

  @override
  List<Object> get props => [message];
}
