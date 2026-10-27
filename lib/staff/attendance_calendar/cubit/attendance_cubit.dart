import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_response_model.dart';
import 'package:admin_app/staff/attendance_calendar/repository/attendance_repository.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_cubit.freezed.dart';
part 'attendance_state.dart';

typedef AttendanceLoad =
    Future<Either<MyError, AttendanceResponseModel>> Function(
      int month,
      int year,
    );

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit({AttendanceLoad? load})
    : _load = load ?? _loadFromRepository,
      super(const AttendanceState.initial());

  final AttendanceLoad _load;
  final LoadMarker _loaded = LoadMarker();
  final SessionScope _scope = SessionScope();

  static Future<Either<MyError, AttendanceResponseModel>> _loadFromRepository(
    int month,
    int year,
  ) {
    return locator<AttendanceRepository>().getAttendance(month, year);
  }

  /// Whether this month was loaded recently for the active user.
  bool isFresh({required int month, required int year}) =>
      _loaded.isFresh(arg: (month, year));

  /// Drops the calendar immediately so the next account cannot see it.
  void dropSession() {
    _scope.invalidate();
    _loaded.clear();
    if (!isClosed) emit(const AttendanceState.initial());
  }

  /// With [quiet] the data already on screen for this month stays visible
  /// while it refreshes; no loading state is emitted and errors are ignored.
  Future<void> getAttendance({
    required int month,
    required int year,
    bool quiet = false,
  }) async {
    final arg = (month, year);
    final keep =
        quiet &&
        _loaded.holds(arg: arg) &&
        state.maybeWhen(loadingSuccess: (_) => true, orElse: () => false);
    final stamp = _scope.begin();
    if (!keep) emit(const AttendanceState.loading());

    final res = await _load(month, year);
    if (isClosed || !_scope.current(stamp)) return;

    if (res.isLeft) {
      if (keep) return;
      emit(AttendanceState.laodingFailure(res.left.message));
    } else {
      _loaded.mark(arg: arg);
      emit(AttendanceState.loadingSuccess(res.right.data));
    }
  }
}
