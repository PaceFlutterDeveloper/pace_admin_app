import 'package:admin_app/staff/shared/read_json.dart';

class NotificationCategory {
  const NotificationCategory({
    required this.key,
    required this.label,
    required this.push,
    required this.inApp,
    required this.mandatory,
  });

  final String key;
  final String label;
  final bool push;
  final bool inApp;

  /// The school requires this alert, so the person cannot switch it off.
  final bool mandatory;

  NotificationCategory copyWith({bool? push, bool? inApp}) {
    return NotificationCategory(
      key: key,
      label: label,
      push: push ?? this.push,
      inApp: inApp ?? this.inApp,
      mandatory: mandatory,
    );
  }

  factory NotificationCategory.fromMap(Map<String, dynamic> map) {
    return NotificationCategory(
      key: readString(map['key']),
      label: readString(map['label'] ?? map['name'] ?? map['key']),
      push: readBool(map['push']),
      inApp: readBool(map['in_app']),
      mandatory: readBool(map['mandatory']),
    );
  }
}

class NotificationSettings {
  const NotificationSettings({
    required this.categories,
    this.quietFrom = '',
    this.quietTo = '',
  });

  final List<NotificationCategory> categories;
  final String quietFrom;
  final String quietTo;

  bool get hasQuietHours => quietFrom.isNotEmpty && quietTo.isNotEmpty;
}
