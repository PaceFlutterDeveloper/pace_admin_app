part of 'grade_attendance_cubit.dart';

class GradeAttendanceState {
  final bool fetchGrades;
  final String? errorMessage;
  final GradeDataModel? gradeDataModel;

  const GradeAttendanceState({
    required this.fetchGrades,
    this.errorMessage,
    this.gradeDataModel,
  });

  GradeAttendanceState copyWith({
    bool? fetchGrades,
    String? errorMessage,
    GradeDataModel? gradeDataModel,
  }) {
    return GradeAttendanceState(
      fetchGrades: fetchGrades ?? this.fetchGrades,
      errorMessage: errorMessage,
      gradeDataModel: gradeDataModel ?? this.gradeDataModel,
    );
  }
}
