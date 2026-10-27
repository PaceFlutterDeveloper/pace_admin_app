import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/events/domain/events_repository.dart';
import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TodayEventsState {
  const TodayEventsState();
}

class TodayEventsLoading extends TodayEventsState {
  const TodayEventsLoading();
}

class TodayEventsLoaded extends TodayEventsState {
  const TodayEventsLoaded(this.events);

  /// Today's events, earliest first, all-day events leading.
  final List<StaffEvent> events;
}

class TodayEventsFailed extends TodayEventsState {
  const TodayEventsFailed([this.message = 'Pull down to try again.']);

  final String message;
}

class TodayEventsCubit extends Cubit<TodayEventsState> {
  TodayEventsCubit({EventsRepository? repository, DateTime Function()? clock})
    : _repository = repository ?? locator<EventsRepository>(),
      _clock = clock ?? DateTime.now,
      super(const TodayEventsLoading());

  final EventsRepository _repository;
  final DateTime Function() _clock;
  final LoadMarker _loaded = LoadMarker();
  final SessionScope _scope = SessionScope();

  bool get isFresh => _loaded.isFresh();

  /// Drops today's events so the next account cannot see them.
  void dropSession() {
    _scope.invalidate();
    _loaded.clear();
    if (!isClosed) emit(const TodayEventsLoading());
  }

  /// With [quiet] the list on screen stays visible while it refreshes.
  Future<void> load({bool quiet = false}) async {
    final keep = quiet && _loaded.holds() && state is TodayEventsLoaded;
    final stamp = _scope.begin();
    if (!keep) emit(const TodayEventsLoading());
    try {
      final events = await _repository.eventsOn(_clock());
      if (isClosed || !_scope.current(stamp)) return;
      _loaded.mark();
      emit(TodayEventsLoaded([...events]..sort(compareStaffEvents)));
    } catch (error) {
      if (!keep && !isClosed && _scope.current(stamp)) {
        emit(TodayEventsFailed(staffErrorMessage(error)));
      }
    }
  }
}
