import 'dart:async';

import 'package:admin_app/staff/students/models/attendance_marks.dart';
import 'package:admin_app/staff/students/models/student_att_model.dart';
import 'package:admin_app/staff/students/models/student_model_extension.dart';
import 'package:admin_app/staff/students/models/student_response_model.dart';
import 'package:admin_app/staff/students/repository/students_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'student_attendance_event.dart';
part 'student_attendance_state.dart';

class StudentAttendanceBloc
    extends Bloc<StudentAttendanceEvent, StudentAttendanceState> {
  final StudentsRepository _studentsRepository = locator<StudentsRepository>();
  final SessionScope _scope = SessionScope();

  StudentAttendanceBloc() : super(StudentInitial()) {
    on<ClearStudentAttendanceEvent>((_, emit) => emit(StudentInitial()));
    on<FetchStudentsEvent>(_onFetchStudents);
    on<MarkAllStudentEvent>(_onMarkAllStudent);
    on<UpdateStudentAttendanceEvent>(_onUpdateStudentAttendance);
    on<PostAttendanceEvent>(_onPostAttendance);
  }

  /// Drops the class roll so the next account cannot see it.
  void dropSession() {
    _scope.invalidate();
    add(ClearStudentAttendanceEvent());
  }

  Future<void> _onFetchStudents(
    FetchStudentsEvent event,
    Emitter<StudentAttendanceState> emit,
  ) async {
    final stamp = _scope.begin();
    final previous = state;
    final keep =
        event.quiet &&
        previous is StudentLoadedState &&
        previous.matches(event.grade, event.section);
    final baseline = keep ? previous.students : null;
    if (!keep) emit(StudentLoadingState());
    try {
      final res = await _studentsRepository.getStudents(
        grade: event.grade,
        section: event.section,
      );
      if (isClosed || !_scope.current(stamp)) return;
      // A quiet refresh must not wipe marks the teacher changed while it
      // was in flight. Those edits replace the student list.
      if (baseline != null &&
          state is StudentLoadedState &&
          !identical((state as StudentLoadedState).students, baseline)) {
        return;
      }
      res.fold(
        (left) => _fail(
          emit,
          message: left.message,
          grade: event.grade,
          section: event.section,
          previous: state,
        ),
        (right) => emit(
          StudentLoadedState(
            grade: event.grade,
            section: event.section,
            students: right.data.students,
            remarks: right.data.remarks,
          ),
        ),
      );
    } catch (_) {
      if (isClosed || !_scope.current(stamp)) return;
      _fail(
        emit,
        message: 'Could not load this class',
        grade: event.grade,
        section: event.section,
        previous: state,
      );
    }
  }

  void _fail(
    Emitter<StudentAttendanceState> emit, {
    required String message,
    required String grade,
    required String section,
    required StudentAttendanceState previous,
  }) {
    final text = message.trim().isEmpty
        ? 'Could not load this class'
        : message.trim();
    if (previous is StudentLoadedState && previous.matches(grade, section)) {
      emit(previous.copyWith(saving: false, notice: text, noticeIsError: true));
      return;
    }
    emit(StudentErrorState(message: text, grade: grade, section: section));
  }

  Future<void> _onMarkAllStudent(
    MarkAllStudentEvent event,
    Emitter<StudentAttendanceState> emit,
  ) async {
    final current = state;
    if (current is! StudentLoadedState || current.saving) return;
    emit(
      current.copyWith(
        students: markAllPresent(current.students, current.remarks),
        clearNotice: true,
      ),
    );
  }

  Future<void> _onUpdateStudentAttendance(
    UpdateStudentAttendanceEvent event,
    Emitter<StudentAttendanceState> emit,
  ) async {
    final current = state;
    if (current is! StudentLoadedState || current.saving) return;
    emit(
      current.copyWith(
        clearNotice: true,
        students: [
          for (final student in current.students)
            if (student.studcode == event.studcode)
              student.copyWith(att: event.studentAttendance)
            else
              student,
        ],
      ),
    );
  }

  Future<void> _onPostAttendance(
    PostAttendanceEvent event,
    Emitter<StudentAttendanceState> emit,
  ) async {
    final current = state;
    if (current is! StudentLoadedState || current.saving) return;
    if (!current.matches(event.grade, event.section)) return;

    final rows = attendanceRows(current.students);
    if (rows.isEmpty) {
      emit(
        current.copyWith(
          notice: 'Mark at least one student',
          noticeIsError: true,
        ),
      );
      return;
    }

    final stamp = _scope.begin();
    emit(current.copyWith(saving: true, clearNotice: true));
    try {
      final res = await _studentsRepository.markAttendance(
        status: event.type,
        attList: rows,
        grade: event.grade,
        section: event.section,
      );
      if (isClosed || !_scope.current(stamp)) return;
      final latest = state is StudentLoadedState
          ? state as StudentLoadedState
          : current;
      res.fold(
        (left) => emit(
          latest.copyWith(
            saving: false,
            notice: left.message.trim().isEmpty
                ? 'Could not save attendance'
                : left.message.trim(),
            noticeIsError: true,
          ),
        ),
        (message) {
          emit(
            latest.copyWith(
              saving: false,
              notice: message,
              noticeIsError: false,
            ),
          );
          add(
            FetchStudentsEvent(
              grade: event.grade,
              section: event.section,
              quiet: true,
            ),
          );
        },
      );
    } catch (_) {
      if (isClosed || !_scope.current(stamp)) return;
      final latest = state is StudentLoadedState
          ? state as StudentLoadedState
          : current;
      emit(
        latest.copyWith(
          saving: false,
          notice: 'Could not save attendance',
          noticeIsError: true,
        ),
      );
    }
  }
}
