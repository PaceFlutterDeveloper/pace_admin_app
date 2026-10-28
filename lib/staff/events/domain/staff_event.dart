import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_attachment.dart';

/// One school event shown to staff.
class StaffEvent {
  const StaffEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    this.endsAt,
    this.location,
    this.allDay = false,
    this.description = '',
    this.category = '',
    this.audience = '',
    this.color = '',
    this.createdBy = '',
    this.attachments = const [],
    this.exclusiveEnd = false,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? location;
  final bool allDay;
  final String description;
  final String category;
  final String audience;
  final String color;
  final String createdBy;
  final List<StaffAttachment> attachments;

  /// True when [endsAt] is midnight of the day after the last day, the usual
  /// way an all-day event marks an exclusive end.
  final bool exclusiveEnd;

  static StaffEvent? tryFromMap(Map<String, dynamic> json) {
    final starts = readDate(
      json['starts_at'] ?? json['start_at'] ?? json['start'],
    );
    if (starts == null) return null;
    final title = plainText(readString(json['title']));
    if (title.isEmpty) return null;
    final place = readString(json['location']);
    final id = readString(json['event_id'] ?? json['id']);
    final endRaw = json['ends_at'] ?? json['end_at'] ?? json['end'];
    final allDay = readBool(json['all_day'] ?? json['is_all_day']);
    final exclusiveEnd = allDay && _exclusiveMidnight(endRaw);
    return StaffEvent(
      id: id.isEmpty ? title : id,
      title: title,
      startsAt: starts,
      // Keep the calendar date written in the payload. Converting an exclusive
      // midnight through the phone's zone can shift that date by one day.
      endsAt: exclusiveEnd ? _calendarDay(endRaw) : readDate(endRaw),
      location: place.isEmpty ? null : place,
      allDay: allDay,
      description: plainText(readString(json['description'])),
      category: readString(json['category']),
      audience: readString(json['audience']),
      color: readString(json['color']),
      createdBy: personName(json['created_by']),
      attachments: readAttachments(json['attachments']),
      exclusiveEnd: exclusiveEnd,
    );
  }
}

/// Where an event sits on one calendar day of a longer run.
enum EventSpan { single, first, middle, last }

DateTime eventStartDay(StaffEvent event) {
  final local = event.startsAt.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Last calendar day the event occupies. An all-day exclusive midnight does
/// not add an empty extra day.
DateTime eventEndDay(StaffEvent event) {
  final start = eventStartDay(event);
  final ends = event.endsAt;
  if (ends == null) return start;
  final local = ends.toLocal();
  var end = DateTime(local.year, local.month, local.day);
  if (event.allDay && event.exclusiveEnd && end.isAfter(start)) {
    end = end.subtract(const Duration(days: 1));
  }
  if (end.isBefore(start)) return start;
  return end;
}

EventSpan eventSpanOn(StaffEvent event, DateTime day) {
  final start = eventStartDay(event);
  final end = eventEndDay(event);
  final date = DateTime(day.year, day.month, day.day);
  if (!end.isAfter(start)) return EventSpan.single;
  if (date == start) return EventSpan.first;
  if (date == end) return EventSpan.last;
  return EventSpan.middle;
}

class EventOnDay {
  const EventOnDay({
    required this.event,
    required this.day,
    required this.span,
  });

  final StaffEvent event;
  final DateTime day;
  final EventSpan span;
}

/// One row per day an event covers. [from] and [to] are inclusive and drop
/// days outside the agenda window. The span still uses the real start and end,
/// so a day inside the window can be "continues" or "ends".
List<EventOnDay> expandEventDays(
  List<StaffEvent> events, {
  DateTime? from,
  DateTime? to,
}) {
  final placed = <EventOnDay>[];
  for (final event in events) {
    final start = eventStartDay(event);
    final end = eventEndDay(event);
    var first = start;
    var last = end;
    if (from != null) {
      final window = DateTime(from.year, from.month, from.day);
      if (window.isAfter(first)) first = window;
    }
    if (to != null) {
      final window = DateTime(to.year, to.month, to.day);
      if (window.isBefore(last)) last = window;
    }
    if (last.isBefore(first)) continue;
    for (
      var day = first;
      !day.isAfter(last);
      day = day.add(const Duration(days: 1))
    ) {
      placed.add(
        EventOnDay(event: event, day: day, span: eventSpanOn(event, day)),
      );
    }
  }
  return placed;
}

bool _exclusiveMidnight(dynamic raw) {
  return RegExp(r'T00:00:00').hasMatch(readString(raw));
}

/// The year-month-day written on the timestamp, before any zone conversion.
DateTime? _calendarDay(dynamic raw) {
  final match = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})',
  ).firstMatch(readString(raw).trim());
  if (match == null) return null;
  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

int compareStaffEvents(StaffEvent a, StaffEvent b) {
  if (a.allDay != b.allDay) return a.allDay ? -1 : 1;
  return a.startsAt.compareTo(b.startsAt);
}

List<StaffEvent> eventsFromBody(Map<String, dynamic> body) {
  final events = [
    for (final item in listPayload(body, const ['events', 'items']))
      if (StaffEvent.tryFromMap(item) case final event?) event,
  ]..sort(compareStaffEvents);
  return events;
}
