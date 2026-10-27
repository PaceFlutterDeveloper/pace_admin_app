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

  static StaffEvent? tryFromMap(Map<String, dynamic> json) {
    final starts = readDate(
      json['starts_at'] ?? json['start_at'] ?? json['start'],
    );
    if (starts == null) return null;
    final title = plainText(readString(json['title']));
    if (title.isEmpty) return null;
    final place = readString(json['location']);
    final id = readString(json['event_id'] ?? json['id']);
    return StaffEvent(
      id: id.isEmpty ? title : id,
      title: title,
      startsAt: starts,
      endsAt: readDate(json['ends_at'] ?? json['end_at'] ?? json['end']),
      location: place.isEmpty ? null : place,
      allDay: readBool(json['all_day'] ?? json['is_all_day']),
      description: plainText(readString(json['description'])),
      category: readString(json['category']),
      audience: readString(json['audience']),
      color: readString(json['color']),
      createdBy: personName(json['created_by']),
      attachments: readAttachments(json['attachments']),
    );
  }
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
