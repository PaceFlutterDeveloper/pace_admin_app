import 'dart:developer';

import 'package:admin_app/core/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class NavigationService {
  static final _logger = Logger();
  static late final GoRouter _router;
  static String? _currentRoute;
  static final List<String> _routeHistory = [];

  static void initialize(GoRouter router) {
    _router = router;
    _addRouteListener();
  }

  static void _addRouteListener() {
    _router.routerDelegate.addListener(() {
      try {
        final newRoute =
            _router.routerDelegate.currentConfiguration.uri.toString();
        if (newRoute != _currentRoute) {
          _currentRoute = newRoute;
          _routeHistory.add(newRoute);
          _logger.d('Route changed to: $newRoute');
        }
      } catch (e) {
        _logger.e('Error in route listener: $e');
      }
    });
  }

  static bool hasParent(String routePath) {
    return _routeHistory.any((route) => route.contains(routePath));
  }

  static Future<void> navigateFromNotification(RemoteMessage message) async {
    try {
      // Log full notification data
      _logger.d('Notification data: ${message.data}');

      final data = message.data;
      final page = data['data_page']?.toString() ?? data['page']?.toString();
      final ticketId = int.tryParse(data['ticket_id']?.toString() ?? '');

      // Validate required parameters
      if (page == null || page.isEmpty) {
        _logger.w('No target page specified in notification');
        return _navigateToDefault();
      }

      // Ensure home route exists in stack
      if (!hasParent(Routes.home.path)) {
        _logger.d('Adding home route to stack');
        await _router.pushNamed(Routes.home.name);
      }

      if (page == Routes.manageTicketDetailPage.path && ticketId != null) {
        log('Navigating to manage ticket detail with ID: $ticketId');
        AppRoute.router.goNamed(
          Routes.manageTicketDetailPage.name,
          extra: {
            'ticketId': ticketId.toString(),
            'isPushNotification': true,
          },
        );
      } else if (page == Routes.ticketDetailPage.path && ticketId != null) {
        log('Navigating to ticket detail with ID: $ticketId');
        AppRoute.router.goNamed(
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
    } catch (e, stackTrace) {
      _logger.e('Navigation failed', error: e, stackTrace: stackTrace);
      _navigateToDefault();
    }
  }

  static void _navigateToDefault() {
    _router.goNamed(Routes.getNotifications.name);
  }
}
