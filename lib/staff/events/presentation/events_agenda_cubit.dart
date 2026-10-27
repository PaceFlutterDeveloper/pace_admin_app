import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/events/domain/events_repository.dart';
import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int kEventsAgendaDays = 30;

sealed class EventsAgendaState {
  const EventsAgendaState();
}

class EventsAgendaLoading extends EventsAgendaState {
  const EventsAgendaLoading();
}

class EventsAgendaLoaded extends EventsAgendaState {
  const EventsAgendaLoaded(this.events);

  final List<StaffEvent> events;
}

class EventsAgendaFailed extends EventsAgendaState {
  const EventsAgendaFailed(this.message);

  final String message;
}

class EventsAgendaCubit extends Cubit<EventsAgendaState> {
  EventsAgendaCubit({EventsRepository? repository, DateTime Function()? clock})
    : _repository = repository ?? locator<EventsRepository>(),
      _clock = clock ?? DateTime.now,
      super(const EventsAgendaLoading());

  final EventsRepository _repository;
  final DateTime Function() _clock;
  final LoadMarker _loaded = LoadMarker();
  final SessionScope _scope = SessionScope();

  bool get isFresh => _loaded.isFresh();

  /// Drops the agenda so the next account cannot see it.
  void dropSession() {
    _scope.invalidate();
    _loaded.clear();
    if (!isClosed) emit(const EventsAgendaLoading());
  }

  Future<void> load({bool quiet = false}) async {
    final keep = quiet && _loaded.holds() && state is EventsAgendaLoaded;
    final stamp = _scope.begin();
    if (!keep) emit(const EventsAgendaLoading());
    try {
      final now = _clock();
      final from = DateTime(now.year, now.month, now.day);
      final events = await _repository.eventsBetween(
        from,
        from.add(const Duration(days: kEventsAgendaDays)),
      );
      if (isClosed || !_scope.current(stamp)) return;
      _loaded.mark();
      emit(EventsAgendaLoaded(events));
    } catch (error) {
      if (!keep && !isClosed && _scope.current(stamp)) {
        emit(EventsAgendaFailed(staffErrorMessage(error)));
      }
    }
  }
}
