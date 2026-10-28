import 'dart:convert';

import 'package:admin_app/careers/notification/careers_fcm_service.dart';

/// Staff push topics, kept apart from the careers topic list.
///
/// The device has one FCM registration. Subscribing staff topics through the
/// careers helper with a separate cache means a staff login does not drop
/// careers topics, and the other way around.
class StaffFcm {
  StaffFcm._();

  /// Subscribes when [body] includes a `topics` array on the root or under
  /// `data`. Payloads that never mention topics are left alone.
  static Future<void> subscribeIfPresent(dynamic body) async {
    final map = _asMap(body);
    if (map == null) return;
    final topics = _topicsIn(map);
    if (topics == null) return;
    await CareersFcmService.subscribeToTopics(
      topics,
      cacheKey: CareersFcmService.staffTopicsKey,
    );
  }

  static Future<void> clearTopics() {
    return CareersFcmService.unsubscribeCachedTopics(
      CareersFcmService.staffTopicsKey,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is String && body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  /// Null when this payload does not talk about topics at all.
  static List<String>? _topicsIn(Map<String, dynamic> body) {
    final data = body['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : null;
    final mentioned =
        body.containsKey('topics') || (dataMap?.containsKey('topics') ?? false);
    if (!mentioned) return null;
    final raw = body.containsKey('topics')
        ? body['topics']
        : dataMap?['topics'];
    if (raw is! List) return const [];
    return [
      for (final value in raw)
        if (value.toString().trim().isNotEmpty) value.toString().trim(),
    ];
  }
}
