import 'dart:developer';
import 'dart:io';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Request permissions
    await _requestPermissions();

    // Get and log tokens
    await _handleTokenManagement();

    // Set up message handlers
    await _setupMessageHandlers();

    // Handle initial message if app was launched from notification
    await _handleInitialMessage();
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

  static Future<void> _handleTokenManagement() async {
    if (Platform.isIOS) {
      final apnsToken = await _waitForApnsToken();
      log("APNS Token: $apnsToken");

      // On iOS (especially simulator), APNS may never be available.
      // Calling getToken() before APNS is ready throws:
      // [firebase_messaging/apns-token-not-set].
      if (apnsToken == null || apnsToken.isEmpty) {
        log("Skipping FCM token fetch until APNS token is available.");
        return;
      }
    }

    try {
      final fcmToken = await _firebaseMessaging.getToken();
      log("FCM Token: $fcmToken");
    } catch (e) {
      log("FCM Token error: $e");
    }
  }

  static Future<String?> _waitForApnsToken() async {
    for (var i = 0; i < 10; i++) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        return apnsToken;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  static Future<void> _setupMessageHandlers() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground notification: ${message.data}');
      _handleNotificationCount(message);
      NotificationService.showNotification(message);
    });

    // When app is in background but opened by notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from background by notification');
      _handleNavigation(message);
    });
  }

  static Future<void> _handleInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('App launched from terminated state by notification');
      // Add slight delay to ensure router is ready
      await Future.delayed(const Duration(milliseconds: 500));
      _handleNavigation(initialMessage);
    }
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

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log('Background notification handler: ${message.data}');

    // Ensure widgets are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Show notification
    await NotificationService.showNotification(message);

    // Handle navigation if needed
    _handleNavigation(message);
  }

  static void _handleNavigation(RemoteMessage message) {
    final data = message.data;
    log('Handling navigation with data: $data');

    final page = data['data_page']?.toString() ?? data['page']?.toString();
    final ticketId = int.tryParse(data['ticket_id']?.toString() ?? '');

    log('Navigation params - page: $page, ticketId: $ticketId');

    if (page == null || page.isEmpty) {
      log('No page specified in notification, defaulting to notifications');
      _navigateToDefault();
      return;
    }

    try {
      if (page == Routes.manageTicketDetailPage.path && ticketId != null) {
        log('Navigating to manage ticket detail with ID: $ticketId');
        AppRoute.router.pushNamed(
          Routes.manageTicketDetailPage.name,
          extra: {
            'ticketId': ticketId.toString(),
            'isPushNotification': true,
          },
        );
      } else if (page == Routes.ticketDetailPage.path && ticketId != null) {
        log('Navigating to ticket detail with ID: $ticketId');
        AppRoute.router.pushNamed(
          Routes.ticketDetailPage.name,
          extra: {
            'ticketId': ticketId.toString(),
            'isPushNotification': true,
          },
        );
      } else {
        log('Unknown page or missing ticketId, defaulting to notifications');
        _navigateToDefault();
      }
    } catch (e) {
      log('Navigation error: $e');
      _navigateToDefault();
    }
  }

  static void _navigateToDefault() {
    AppRoute.router.pushNamed(Routes.getNotifications.name);
  }
}
