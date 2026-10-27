import 'package:admin_app/staff/class_attendance/model/grade_data_model.dart';
import 'package:admin_app/staff/class_attendance/repository/class_attendance_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:bloc/bloc.dart';

part 'grade_attendance_state.dart';

class GradeAttendanceCubit extends Cubit<GradeAttendanceState> {
  final ClassAttendanceRepository _attendanceRepository =
      locator<ClassAttendanceRepository>();
  final SessionScope _scope = SessionScope();
  final LoadMarker _loaded = LoadMarker();

  GradeAttendanceCubit()
    : super(const GradeAttendanceState(fetchGrades: false));

  /// Drops grades so the next account cannot see another school's classes.
  void dropSession() {
    _scope.invalidate();
    _loaded.clear();
    if (!isClosed) {
      emit(const GradeAttendanceState(fetchGrades: false));
    }
  }

  /// Loads the class list. A fresh list stays on screen and refreshes quietly.
  Future<void> getGrades({bool force = false}) async {
    if (!force && _loaded.isFresh() && state.gradeDataModel != null) return;
    final stamp = _scope.begin();
    final quiet = state.gradeDataModel != null;
    if (!quiet) emit(state.copyWith(fetchGrades: true));

    final res = await _attendanceRepository.getGrades();
    if (isClosed || !_scope.current(stamp)) return;
    if (res.isLeft) {
      final message = res.left.message.trim();
      emit(
        state.copyWith(
          fetchGrades: false,
          errorMessage: message.isEmpty ? 'Could not load classes' : message,
        ),
      );
      return;
    }
    _loaded.mark();
    emit(state.copyWith(fetchGrades: false, gradeDataModel: res.right.data));
  }
}
