import 'package:admin_app/staff/events/domain/staff_event.dart';

abstract class EventsRepository {
  /// Events that fall on [day], in any order.
  Future<List<StaffEvent>> eventsOn(DateTime day);

  /// Events whose start falls between [from] and [to], inclusive.
  Future<List<StaffEvent>> eventsBetween(DateTime from, DateTime to);

  Future<StaffEvent> eventDetail(String id);
}
