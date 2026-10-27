import 'package:admin_app/staff/events/domain/events_repository.dart';
import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/events/presentation/today_events_cubit.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements EventsRepository {
  _FakeRepo(this.events);

  List<StaffEvent> events;
  Object? failure;
  int calls = 0;

  @override
  Future<List<StaffEvent>> eventsOn(DateTime day) async {
    calls++;
    if (failure != null) throw failure!;
    return events;
  }

  @override
  Future<List<StaffEvent>> eventsBetween(DateTime from, DateTime to) {
    return eventsOn(from);
  }

  @override
  Future<StaffEvent> eventDetail(String id) async => events.first;
}

StaffEvent _event(String id, int hour, {bool allDay = false}) => StaffEvent(
  id: id,
  title: id,
  startsAt: DateTime(2026, 10, 26, hour),
  allDay: allDay,
);

void main() {
  var user = 'school:1';
  setUp(() {
    user = 'school:1';
    LoadMarker.sessionKey = () => user;
  });

  test('lists today earliest first with all-day events leading', () async {
    final repo = _FakeRepo([
      _event('late', 15),
      _event('early', 9),
      _event('holiday', 0, allDay: true),
    ]);
    final cubit = TodayEventsCubit(repository: repo);
    await cubit.load();
    final state = cubit.state as TodayEventsLoaded;
    expect(state.events.map((e) => e.id), ['holiday', 'early', 'late']);
  });

  test(
    'quiet refresh keeps the list on screen and ignores a failure',
    () async {
      final repo = _FakeRepo([_event('a', 9)]);
      final cubit = TodayEventsCubit(repository: repo);
      await cubit.load();

      final seen = <TodayEventsState>[];
      final sub = cubit.stream.listen(seen.add);
      repo.failure = Exception('offline');
      await cubit.load(quiet: true);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(seen, isEmpty, reason: 'no loading or error flash');
      expect(cubit.state, isA<TodayEventsLoaded>());
    },
  );

  test('another user never sees the previous user\'s events', () async {
    final repo = _FakeRepo([_event('a', 9)]);
    final cubit = TodayEventsCubit(repository: repo);
    await cubit.load();
    expect(cubit.isFresh, isTrue);

    user = 'school:2';
    expect(cubit.isFresh, isFalse);
    final seen = <TodayEventsState>[];
    final sub = cubit.stream.listen(seen.add);
    await cubit.load(quiet: true);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(seen.first, isA<TodayEventsLoading>());
  });

  test('a failed first load reports failure', () async {
    final repo = _FakeRepo([])..failure = Exception('x');
    final cubit = TodayEventsCubit(repository: repo);
    await cubit.load();
    expect(cubit.state, isA<TodayEventsFailed>());
  });
}
