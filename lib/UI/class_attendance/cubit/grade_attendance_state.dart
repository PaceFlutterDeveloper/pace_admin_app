part of 'grade_attendance_cubit.dart';

class GradeAttendanceState {
  final bool fetchGrades;
  final bool markAttendance;
  final String? errorMessage;
  final GradeDataModel? gradeDataModel;

  const GradeAttendanceState({
    required this.fetchGrades,
    required this.markAttendance,
    this.errorMessage,
    this.gradeDataModel,
  });

  /// ✅ **Ensure UI remains unaffected**
  GradeAttendanceState copyWith({
    bool? fetchGrades,
    bool? markAttendance,
    String? errorMessage,
    GradeDataModel? gradeDataModel,
  }) {
    return GradeAttendanceState(
      fetchGrades: fetchGrades ?? this.fetchGrades,
      markAttendance: markAttendance ?? this.markAttendance,
      errorMessage: errorMessage,
      gradeDataModel: gradeDataModel ?? this.gradeDataModel,
    );
  }
}
