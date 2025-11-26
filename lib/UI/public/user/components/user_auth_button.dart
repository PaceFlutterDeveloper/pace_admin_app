import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/UI/public/user/pages/profile_page.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class UserAuthButton extends StatelessWidget {
  final VoidCallback? onUserStateChanged;

  const UserAuthButton({
    Key? key,
    this.onUserStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = CareersUserManager.isLoggedIn();
    final userName = CareersUserManager.getDisplayName();
    final userEmail = CareersUserManager.getEmail();

    return GestureDetector(
      onTap: () => _handleAuthButtonTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isLoggedIn ? ConstColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isLoggedIn ? ConstColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoggedIn) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: ConstColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Icon(
                Icons.person_outline,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAuthButtonTap(BuildContext context) {
    if (CareersUserManager.isLoggedIn()) {
      // User is logged in, show profile page
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      )
          .then((_) {
        // Callback to notify parent of user state change
        onUserStateChanged?.call();
      });
    } else {
      // User is not logged in, show login page
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      )
          .then((_) {
        // Callback to notify parent of user state change
        onUserStateChanged?.call();
      });
    }
  }
}
