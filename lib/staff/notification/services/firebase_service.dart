import 'dart:async';
import 'dart:io';

import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/session/staff_session_service.dart';
import 'package:admin_app/staff/notification/cubit/notification_cubit.dart';
import 'package:admin_app/staff/notification/services/notification_router.dart';
import 'package:admin_app/staff/notification/services/notification_service.dart';
import 'package:admin_app/careers/notification/careers_fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static bool _initialized = false;
  static RemoteMessage? _pendingInitialMessage;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _requestPermissions();
    _handleTokenManagement();
    await _setupMessageHandlers();
    _pendingInitialMessage = await _firebaseMessaging.getInitialMessage();
  }

  /// Call after the first frame so GoRouter is ready and the UI is not blocked.
  static Future<void> handlePendingInitialMessage() async {
    final message = _pendingInitialMessage;
    _pendingInitialMessage = null;
    if (message == null) return;
    CareersFcmService.logMessage(
      'App launched from terminated state by notification',
    );
    await _onStaffPush(message);
    await NotificationRouter.handleMessage(message);
  }

  /// Subscribe to get-profile topics once a session exists. Must not run
  /// before [runApp] — it would delay first paint.
  static void restoreCareersTopics() {
    unawaited(CareersFcmService.restoreSubscriptionsIfLoggedIn());
  }

  static Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _handleTokenManagement() {
    _firebaseMessaging.onTokenRefresh.listen((_) {
      CareersFcmService.logMessage('token refreshed');
      // Without this the server keeps pushing to the old token.
      unawaited(locator<StaffSessionService>().registerDevice(force: true));
    });

    unawaited(_logCurrentTokens());
  }

  static Future<void> _logCurrentTokens() async {
    if (Platform.isIOS) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      CareersFcmService.logMessage('APNS Token: $apnsToken');
      if (apnsToken == null || apnsToken.isEmpty) {
        CareersFcmService.logMessage(
          'Skipping FCM token fetch until APNS token is available.',
        );
        return;
      }
    }

    try {
      final fcmToken = await _firebaseMessaging.getToken();
      CareersFcmService.logMessage('FCM Token: $fcmToken');
    } catch (e) {
      CareersFcmService.logMessage('FCM Token error: $e');
    }
  }

  static Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      CareersFcmService.logMessage('Foreground notification: ${message.data}');
      unawaited(_onStaffPush(message));
      NotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      CareersFcmService.logMessage(
        'App opened from background by notification',
      );
      unawaited(_onStaffPush(message));
      NotificationRouter.handleMessage(message);
    });
  }

  /// Brings the signed-in staff inbox up to date. Careers payloads stay on
  /// the careers path and do not change this bell.
  static Future<void> _onStaffPush(RemoteMessage message) async {
    if (NotificationRouter.isCareersPayload(message.data)) return;
    final auth = await AuthData.getActiveUser();
    if (auth == null) return;
    final school = message.data['school_code']?.toString().trim() ?? '';
    final admin = message.data['admin_id']?.toString().trim() ?? '';
    if (school.isNotEmpty && school != auth.schoolCode) return;
    if (admin.isNotEmpty && admin != auth.userId) return;
    await AuthData.updateNotificationCount(
      appCode: auth.schoolCode,
      userId: auth.userId.toString(),
      notificationCount: 1,
      mode: NotificationUpdateMode.add,
    );
    if (!locator.isRegistered<NotificationCubit>()) return;
    unawaited(locator<NotificationCubit>().fetchNotifications(quiet: true));
  }
}
