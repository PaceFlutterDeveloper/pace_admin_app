import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/careers/user/services/careers_user_service.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/auth/cubit/auth_cubit.dart';
import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/repository/home_repository.dart';
import 'package:admin_app/staff/internal_web/internal_web_url.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

/// Routes a push-notification tap to careers or employee screens.
class NotificationRouter {
  NotificationRouter._();

  static Future<void> handleMessage(RemoteMessage message) async {
    await handleData(
      message.data,
      notificationTitle: message.notification?.title,
    );
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

  static Future<void> handleData(
    Map<String, dynamic> data, {
    String? notificationTitle,
  }) async {
    log('NotificationRouter: $data');

    if (isCareersPayload(data)) {
      _openCareers(data);
      return;
    }

    // Tap for account A while viewing account B → switch first, then route.
    final switched = await _ensureRecipientAccount(data);

    final page = _string(data, 'data_page') ?? _string(data, 'page');
    final ticketId = int.tryParse(_string(data, 'ticket_id') ?? '');

    if (_isInternalWebPush(data)) {
      final url = _string(data, 'url') ?? _string(data, 'web_url');
      if (url == null) {
        log('NotificationRouter: internalWeb requires url in data');
        return;
      }
      if (switched) AppRoute.router.go(Routes.home.path);
      await _openInternalWebFromPush(url, data, notificationTitle);
      return;
    }

    if (page == Routes.manageTicketDetailPage.path && ticketId != null) {
      if (switched) AppRoute.router.go(Routes.home.path);
      AppRoute.router.pushNamed(
        Routes.manageTicketDetailPage.name,
        extra: {'ticketId': ticketId.toString(), 'isPushNotification': true},
      );
      return;
    }

    if (page == Routes.ticketDetailPage.path && ticketId != null) {
      if (switched) AppRoute.router.go(Routes.home.path);
      AppRoute.router.pushNamed(
        Routes.ticketDetailPage.name,
        extra: {'ticketId': ticketId.toString(), 'isPushNotification': true},
      );
      return;
    }

    final activeStaff = await AuthData.getActiveUser();
    if (activeStaff == null && _isCareersUserLoggedIn()) {
      AppRoute.router.goNamed(Routes.careers.name);
      return;
    }

    if (switched) {
      AppRoute.router.goNamed(Routes.getNotifications.name);
    } else {
      AppRoute.router.pushNamed(Routes.getNotifications.name);
    }
  }

  /// When the push names a saved profile that is not active, switch to it.
  /// Uses [school_code] + [admin_id] (matches [AuthModel.userId]).
  static Future<bool> _ensureRecipientAccount(Map<String, dynamic> data) async {
    final school = _string(data, 'school_code');
    final adminId = _string(data, 'admin_id');
    if (school == null || adminId == null) return false;

    final target = AuthData.findUserBySchoolAndId(
      schoolCode: school,
      userId: adminId,
    );
    if (target == null || target.isActive) return false;

    try {
      await locator<AuthCubit>().switchUser(
        userName: target.userName,
        schoolCode: target.schoolCode,
        userId: target.userId,
      );
      log(
        'NotificationRouter: switched to ${target.userName} '
        '(${target.userId}) @ ${target.schoolCode}',
      );
      return true;
    } catch (e) {
      log('NotificationRouter: account switch failed: $e');
      return false;
    }
  }

  /// Inbox tap that is not a native screen. Reloads the role menu and opens
  /// the matching internal-web page, or tells the user it could not.
  static Future<void> openInternalWebFromInbox(NotificationModel n) async {
    final menus = await _loadMenus();
    final link = n.link.trim();
    final appPage = n.appPage.trim();
    final url = isHttpUrl(link)
        ? link
        : (isHttpUrl(appPage) ? appPage : null);

    if (url != null) {
      final matched = findInternalWebByUrl(menus, url);
      if (matched != null) {
        final label = internalWebLabel(matched);
        _pushInternalWeb(
          internalWebLaunchMenu(
            matched: matched,
            url: url,
            title: label.isNotEmpty ? label : n.head,
          ),
        );
        return;
      }
    }

    final matched = findInternalWebByLabel(menus, [
      n.action,
      n.actionName,
      appPage,
      n.head,
    ]);
    if (matched == null) {
      _unableToOpen();
      return;
    }
    _pushInternalWeb(matched);
  }

  static bool isKnownStaffPage(String appPage) {
    final path = appPage.trim();
    if (path.isEmpty) return false;
    for (final route in Routes.values) {
      if (route == Routes.internalWeb) continue;
      final routePath = route.path;
      if (routePath.length < 2) continue;
      if (path == routePath || path.startsWith('$routePath/')) return true;
    }
    return false;
  }

  static bool _isInternalWebPush(Map<String, dynamic> data) {
    final action =
        (_string(data, 'click_action') ?? _string(data, 'clickAction') ?? '')
            .toUpperCase();
    if (action != 'MENU') return false;
    return isInternalWebKey(_string(data, 'menu_key') ?? '');
  }

  static Future<void> _openInternalWebFromPush(
    String url,
    Map<String, dynamic> data,
    String? notificationTitle,
  ) async {
    final menus = await _loadMenus();
    final matched = findInternalWebByUrl(menus, url);
    final label = matched == null ? '' : internalWebLabel(matched);
    final title = label.isNotEmpty
        ? label
        : (_string(data, 'menu_val') ??
              _string(data, 'menu_title') ??
              notificationTitle ??
              _string(data, 'title') ??
              '');
    _pushInternalWeb(
      internalWebLaunchMenu(matched: matched, url: url, title: title),
    );
  }

  static void _pushInternalWeb(MenuModel menu) {
    AppRoute.router.pushNamed(Routes.internalWeb.name, extra: menu);
  }

  static Future<List<MenuModel>> _loadMenus() async {
    try {
      final result = await locator<HomeRepository>().getMenu();
      if (result.isLeft) return const <MenuModel>[];
      return result.right.data;
    } catch (e) {
      log('NotificationRouter: internalWeb menu load failed: $e');
      return const [];
    }
  }

  static void _unableToOpen() {
    final navigator =
        AppRoute.router.routerDelegate.navigatorKey.currentState;
    final context = navigator?.overlay?.context ?? navigator?.context;
    if (context == null) {
      log('NotificationRouter: Unable to open this menu');
      return;
    }
    AppToast.info(context, 'Unable to open this menu');
  }

  static bool isCareersPayload(Map<String, dynamic> data) {
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
        final router = AppRoute.router;
        final query = {'job_id': jobId.toString()};
        if (router.state.matchedLocation == Routes.careers.path) {
          router.pushNamed(Routes.jobDetail.name, queryParameters: query);
        } else {
          router.goNamed(Routes.jobDetail.name, queryParameters: query);
        }
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
