import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/events/domain/events_repository.dart';
import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiEventsRepository implements EventsRepository {
  ApiEventsRepository({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<StaffEvent>> eventsOn(DateTime day) {
    return _list({'action': 'today'});
  }

  @override
  Future<List<StaffEvent>> eventsBetween(DateTime from, DateTime to) {
    return _list({
      'action': 'list',
      'from': ymd(from),
      'to': ymd(to),
      'pageNo': 0,
      'limit': 100,
    });
  }

  @override
  Future<StaffEvent> eventDetail(String id) async {
    final body = await postStaffPage(
      api: apiService,
      url: ApiConstants.getEvents(),
      fields: {'action': 'detail', 'event_id': id},
    );
    final data = _record(body, 'event');
    final event = data == null ? null : StaffEvent.tryFromMap(data);
    if (event == null) {
      throw const StaffApiException('Event details were not returned');
    }
    return event;
  }

  Future<List<StaffEvent>> _list(Map<String, dynamic> fields) async {
    final body = await postStaffPage(
      api: apiService,
      url: ApiConstants.getEvents(),
      fields: fields,
    );
    return eventsFromBody(body);
  }
}

Map<String, dynamic>? _record(Map<String, dynamic> body, String nestedKey) {
  final data = objectPayload(body);
  if (data == null) return null;
  final nested = data[nestedKey];
  if (nested is Map && readString(data['title']).isEmpty) {
    final record = Map<String, dynamic>.from(nested);
    if (record['attachments'] == null && data['attachments'] != null) {
      record['attachments'] = data['attachments'];
    }
    return record;
  }
  return data;
}
