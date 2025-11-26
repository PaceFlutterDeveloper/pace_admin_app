import 'package:admin_app/UI/class_attendance/model/grade_data_model.dart';
import 'package:admin_app/UI/class_attendance/repository/class_attendance_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:bloc/bloc.dart';

part 'grade_attendance_state.dart';

class GradeAttendanceCubit extends Cubit<GradeAttendanceState> {
  final ClassAttendanceRepository _attendanceRepository =
      locator<ClassAttendanceRepository>();

  GradeAttendanceCubit()
      : super(const GradeAttendanceState(
            fetchGrades: false, markAttendance: false));

  /// ✅ **Fetch Grades (Handles only fetchGrades)**
  void getGrades() async {
    emit(state.copyWith(
        fetchGrades: true)); // UI is not affected, just updating fetchGrades

    var res = await _attendanceRepository.getGrades();
    if (res.isLeft) {
      emit(state.copyWith(
        fetchGrades: false,
        errorMessage: res.left.message ?? "Something went wrong",
      ));
    } else {
      emit(state.copyWith(
        fetchGrades: false,
        gradeDataModel: res.right.data,
      ));
    }
  }

  /// ✅ **Mark Attendance (Handles only markAttendance)**
  void markAttendance() async {
    emit(state.copyWith(
        markAttendance: true)); // UI unaffected, only markAttendance changes

    // Simulating API Call
    await Future.delayed(
        const Duration(seconds: 2)); // Replace with actual API call

    emit(state.copyWith(markAttendance: false));
  }
}
