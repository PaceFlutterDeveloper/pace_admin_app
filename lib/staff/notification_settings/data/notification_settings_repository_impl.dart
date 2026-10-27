import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/notification_settings/domain/notification_settings_models.dart';
import 'package:admin_app/staff/notification_settings/domain/notification_settings_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiNotificationSettingsRepository
    implements NotificationSettingsRepository {
  ApiNotificationSettingsRepository({required this.apiService});

  final ApiService apiService;

  Future<Map<String, dynamic>> _post(Map<String, dynamic> fields) {
    return postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('notificationSettings'),
      fields: fields,
    );
  }

  @override
  Future<NotificationSettings> load() async {
    final body = await _post({'action': 'get'});
    final data = objectPayload(body);
    final quiet = data?['quiet_hours'];
    return NotificationSettings(
      categories: [
        for (final row in objectList(data?['categories']))
          NotificationCategory.fromMap(row),
      ],
      quietFrom: quiet is Map ? readString(quiet['from']) : '',
      quietTo: quiet is Map ? readString(quiet['to']) : '',
    );
  }

  @override
  Future<void> update(
    String key, {
    required bool push,
    required bool inApp,
  }) async {
    await _post({
      'action': 'update',
      'key': key,
      'push': push ? 1 : 0,
      'in_app': inApp ? 1 : 0,
    });
  }
}
