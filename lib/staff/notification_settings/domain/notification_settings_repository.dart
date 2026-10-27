import 'package:admin_app/staff/notification_settings/domain/notification_settings_models.dart';

abstract class NotificationSettingsRepository {
  Future<NotificationSettings> load();

  Future<void> update(String key, {required bool push, required bool inApp});
}
