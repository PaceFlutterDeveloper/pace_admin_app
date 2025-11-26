part of 'attendance_cubit.dart';

@freezed
class AttendanceState with _$AttendanceState {
  const factory AttendanceState.initial() = _Initial;

  const factory AttendanceState.loading() = _Loading;
  const factory AttendanceState.loadingSuccess(
      List<AttendanceModel> attendanceList) = _LoginSuccess;
  const factory AttendanceState.laodingFailure(String myError) = _LoginFailure;
}
