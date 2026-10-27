import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/dashboard/domain/dashboard_repository.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Home counters. Keeps the last numbers on screen while a refresh runs, and
/// keeps them if the refresh fails.
class DashboardCubit extends Cubit<StaffDashboard?> {
  DashboardCubit({DashboardRepository? repository})
    : _repository = repository ?? locator<DashboardRepository>(),
      super(null);

  final DashboardRepository _repository;
  final LoadMarker _loaded = LoadMarker();

  bool get isFresh => _loaded.isFresh();

  Future<void> load() async {
    // Numbers of another account must not flash while this one loads.
    if (!_loaded.holds()) emit(null);
    try {
      final data = await _repository.load();
      _loaded.mark();
      if (!isClosed) emit(data);
    } catch (_) {
      // Counters are a convenience; the screens behind them show the errors.
    }
  }
}
