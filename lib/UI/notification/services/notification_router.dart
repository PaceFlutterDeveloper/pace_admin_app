import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

/// Routes a push-notification tap to careers or employee screens.
class NotificationRouter {
  NotificationRouter._();

  static Future<void> handleMessage(RemoteMessage message) async {
    await handleData(message.data);
  }

  static Future<void> handlePayload(String? payload) async {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = json.decode(payload);
      if (decoded is Map<String, dynamic>) {
        await handleData(decoded);
      }
    } catch (e) {
      log('NotificationRouter: invalid payload $e');
    }
  }

  static Future<void> handleData(Map<String, dynamic> data) async {
    log('NotificationRouter: $data');

    if (_isCareersPayload(data)) {
      _openCareers(data);
      return;
    }

    final page = _string(data, 'data_page') ?? _string(data, 'page');
    final ticketId = int.tryParse(_string(data, 'ticket_id') ?? '');

    if (page == Routes.manageTicketDetailPage.path && ticketId != null) {
      AppRoute.router.pushNamed(
        Routes.manageTicketDetailPage.name,
        extra: {
          'ticketId': ticketId.toString(),
          'isPushNotification': true,
        },
      );
      return;
    }

    if (page == Routes.ticketDetailPage.path && ticketId != null) {
      AppRoute.router.pushNamed(
        Routes.ticketDetailPage.name,
        extra: {
          'ticketId': ticketId.toString(),
          'isPushNotification': true,
        },
      );
      return;
    }

    if (_isCareersUserLoggedIn()) {
      AppRoute.router.goNamed(Routes.careers.name);
      return;
    }

    AppRoute.router.pushNamed(Routes.getNotifications.name);
  }

  static bool _isCareersPayload(Map<String, dynamic> data) {
    final type = (_string(data, 'type') ?? '').toLowerCase();
    if (type.startsWith('careers')) return true;

    final page = (_string(data, 'page') ?? _string(data, 'data_page') ?? '')
        .toLowerCase();
    return page.contains('career') ||
        page.contains('job-detail') ||
        page.contains('application');
  }

  static void _openCareers(Map<String, dynamic> data) {
    final type = (_string(data, 'type') ?? '').toLowerCase();
    final jobId = int.tryParse(_string(data, 'job_id') ?? '');
    final page = (_string(data, 'page') ?? '').toLowerCase();

    if (type == 'careers_job' ||
        (jobId != null && (type.isEmpty || page.contains('job-detail')))) {
      if (jobId != null) {
        AppRoute.router.goNamed(
          Routes.jobDetail.name,
          queryParameters: {'job_id': jobId.toString()},
        );
        return;
      }
    }

    if (type == 'careers_application' || page.contains('application')) {
      AppRoute.router.go('${Routes.careers.path}?tab=applications');
      return;
    }

    if (type == 'careers_candidate' || page.contains('profile')) {
      AppRoute.router.go('${Routes.careers.path}?tab=profile');
      return;
    }

    AppRoute.router.goNamed(Routes.careers.name);
  }

  static bool _isCareersUserLoggedIn() {
    try {
      return GetIt.instance<CareersUserService>().isCareersUserLoggedIn();
    } catch (_) {
      return false;
    }
  }

  static String? _string(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
