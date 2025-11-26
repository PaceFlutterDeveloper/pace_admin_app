import 'package:admin_app/UI/employee/attendance/models/attendance_model.dart';
import 'package:admin_app/UI/employee/attendance/repository/attendance_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_cubit.freezed.dart';
part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(const AttendanceState.initial());
  final AttendanceRepository _attendanceRepository =
      locator<AttendanceRepository>();
  getAttendance({required int month, required int year}) async {
    emit(const AttendanceState.loading());

    var res = await _attendanceRepository.getAttendance(month, year);

    if (res.isLeft) {
      emit(AttendanceState.laodingFailure(
          res.left.message ?? "Something went wrong"));
    } else {
      emit(AttendanceState.loadingSuccess(res.right.data));
    }
  }
}
