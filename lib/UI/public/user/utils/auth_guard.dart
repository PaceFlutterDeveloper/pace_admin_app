import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AuthGuard {
  static CareersUserService get _userService =>
      GetIt.instance<CareersUserService>();

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _userService.isCareersUserLoggedIn();
  }

  /// Navigate to login page if user is not authenticated
  static void requireAuth(
    BuildContext context, {
    VoidCallback? onAuthenticated,
  }) {
    if (isLoggedIn()) {
      onAuthenticated?.call();
    } else {
      _navigateToLogin(context);
    }
  }

  /// Navigate to login page
  static void _navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  /// Show authentication required dialog
  static void showAuthRequiredDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: Text('Please log in to access $feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin(context);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
