part of 'students_cubit.dart';

@freezed
class StudentsState with _$StudentsState {
  // The initial state provides default empty lists.
  const factory StudentsState.initial({
    @Default([]) List<StudentModel> students,
    @Default([]) List<StudentAttModel> attlist,
  }) = _Initial;

  // The loading state requires the current lists to be passed.
  const factory StudentsState.loading({
    required List<StudentModel> students,
    required List<StudentAttModel> attlist,
  }) = _Loading;

  // The success state contains students, attendance list, and remarks.
  const factory StudentsState.success({
    required List<StudentModel> students,
    required List<StudentAttModel> attlist,
    required List<Remark> remarks,
  }) = _Success;

  // The failure state carries an error message along with the common lists.
  const factory StudentsState.failure(
    String error, {
    required List<StudentModel> students,
    required List<StudentAttModel> attlist,
  }) = _Failure;
}
