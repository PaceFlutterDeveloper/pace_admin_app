import 'dart:async';
import 'dart:io';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/notification/services/notification_router.dart';
import 'package:admin_app/UI/notification/services/notification_service.dart';
import 'package:admin_app/UI/public/notification/careers_fcm_service.dart';
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
      _handleNotificationCount(message);
      NotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      CareersFcmService.logMessage('App opened from background by notification');
      NotificationRouter.handleMessage(message);
    });
  }

  static void _handleNotificationCount(RemoteMessage message) {
    if (message.notification != null &&
        message.data['school_code'] != null &&
        message.data['admin_id'] != null) {
      AuthData.updateNotificationCount(
        appCode: message.data['school_code'],
        userId: message.data['admin_id'],
        notificationCount: 1,
        mode: NotificationUpdateMode.add,
      );
    }
  }
}
