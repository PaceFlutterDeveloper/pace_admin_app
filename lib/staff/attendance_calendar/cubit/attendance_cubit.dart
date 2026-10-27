import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/repository/attendance_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_cubit.freezed.dart';
part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(const AttendanceState.initial());
  final AttendanceRepository _attendanceRepository =
      locator<AttendanceRepository>();
  final LoadMarker _loaded = LoadMarker();

  /// Whether this month was loaded recently for the active user.
  bool isFresh({required int month, required int year}) =>
      _loaded.isFresh(arg: (month, year));

  /// With [quiet] the data already on screen for this month stays visible
  /// while it refreshes; no loading state is emitted and errors are ignored.
  getAttendance({
    required int month,
    required int year,
    bool quiet = false,
  }) async {
    final arg = (month, year);
    final keep =
        quiet &&
        _loaded.holds(arg: arg) &&
        state.maybeWhen(loadingSuccess: (_) => true, orElse: () => false);
    if (!keep) emit(const AttendanceState.loading());

    var res = await _attendanceRepository.getAttendance(month, year);

    if (res.isLeft) {
      if (keep) return;
      emit(
        AttendanceState.laodingFailure(
          res.left.message ?? "Something went wrong",
        ),
      );
    } else {
      _loaded.mark(arg: arg);
      emit(AttendanceState.loadingSuccess(res.right.data));
    }
  }
}
