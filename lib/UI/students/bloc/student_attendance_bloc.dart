import 'dart:async';

// Import your models (adjust paths as necessary)
import 'package:admin_app/UI/students/models/student_att_model.dart';
import 'package:admin_app/UI/students/models/student_model_extension.dart';
import 'package:admin_app/UI/students/models/student_response_model.dart';
import 'package:admin_app/UI/students/repository/students_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'student_attendance_event.dart';
part 'student_attendance_state.dart';

class StudentAttendanceBloc
    extends Bloc<StudentAttendanceEvent, StudentAttendanceState> {
  final StudentsRepository _studentsRepository = locator<StudentsRepository>();
  StudentAttendanceBloc() : super(StudentInitial()) {
    on<FetchStudentsEvent>(_onFetchStudents);
    on<MarkAllStudentEvent>(_onMarkAllStudent);
    on<UpdateStudentAttendanceEvent>(_onUpdateStudentAttendance);
    on<PostAttendanceEvent>(_onPostAttendance);
  }

  /// Simulates fetching students (replace with your repository/API call)
  Future<void> _onFetchStudents(
      FetchStudentsEvent event, Emitter<StudentAttendanceState> emit) async {
    emit(StudentLoadingState());
    try {
      var res = await _studentsRepository.getStudents(
          grade: event.grade, section: event.section);

      res.fold(
        (left) => emit(StudentErrorState(
          message: left.message,
        )),
        (right) {
          emit(StudentLoadedState(
            students: right.data.students,
            remarks: right.data.remarks,
          ));
        },
      );
    } catch (e) {
      emit(StudentErrorState(message: e.toString()));
    }
  }

  /// Marks all students as present.
  Future<void> _onMarkAllStudent(
      MarkAllStudentEvent event, Emitter<StudentAttendanceState> emit) async {
    if (state is StudentLoadedState) {
      try {
        final updatedStudents =
            (state as StudentLoadedState).students.map((student) {
          return student.copyWith(
            att: student.att?.copyWith(att: '0') ??
                StudentAttModel(
                  id: '',
                  studcode: student.studcode,
                  comment: '',
                  remark: '',
                  att: '0',
                ),
          );
        }).toList();
        emit(StudentLoadedState(
            students: updatedStudents,
            remarks: (state as StudentLoadedState).remarks));
      } catch (e) {
        emit(StudentErrorState(message: e.toString()));
      }
    }
  }

  /// Updates the attendance status for a specific student based on the updated
  /// [StudentAttModel] passed with the event.
  Future<void> _onUpdateStudentAttendance(UpdateStudentAttendanceEvent event,
      Emitter<StudentAttendanceState> emit) async {
    if (state is StudentLoadedState) {
      try {
        final updatedStudents =
            (state as StudentLoadedState).students.map((student) {
          if (student.studcode == event.studcode) {
            // Update the student's attendance with the new model.
            return student.copyWith(
              att: event.studentAttendance,
            );
          }
          return student;
        }).toList();
        emit(StudentLoadedState(
          students: updatedStudents,
          remarks: (state as StudentLoadedState).remarks,
        ));
      } catch (e) {
        emit(StudentErrorState(message: e.toString()));
      }
    }
  }

  /// Simulates posting/submitting the attendance (replace with your API call)
  Future<void> _onPostAttendance(
      PostAttendanceEvent event, Emitter<StudentAttendanceState> emit) async {
    if (state is StudentLoadedState) {
      try {
        List<StudentAttModel> attList = [];
        (state as StudentLoadedState).students.map(
          (e) {
            attList.add(StudentAttModel(
                id: e.studcode,
                studcode: e.studcode,
                comment: e.att!.comment,
                remark: e.att!.remark,
                att: e.att!.att));
          },
        );
        var res = await _studentsRepository.markAttedance(
            status: event.type,
            attList: attList,
            grade: event.grade,
            section: event.section);
        // await Future.delayed(const Duration(seconds: 2));
        emit(const StudentPostedState(
            message: 'Attendance posted successfully!'));
        emit(StudentLoadingState());
        emit(StudentLoadedState(
          students: event.students,
          remarks: event.remarks,
        ));
      } catch (e) {
        emit(StudentErrorState(message: e.toString()));
      }
    }
  }
}
