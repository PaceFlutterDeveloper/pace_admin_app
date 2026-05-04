import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_avatar.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserTile extends StatelessWidget {
  final VoidCallback onTap;

  const UserTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Box<AuthModel> loginBox = locator<Box<AuthModel>>();

    return ValueListenableBuilder(
      valueListenable: loginBox.listenable(),
      builder: (context, Box<AuthModel> box, child) {
        final AuthModel? activeUser = box.values
            .where((login) => login.isActive)
            .isNotEmpty
            ? box.values.firstWhere((login) => login.isActive)
            : null;

        if (activeUser == null) {
          return AppButton.primary(
            label: 'Sign In',
            onPressed: onTap,
            isFullWidth: false,
          );
        }

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              // Avatar with primary color border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: AppAvatar(
                  imageUrl: activeUser.profilePicture,
                  name: activeUser.name.isNotEmpty ? activeUser.name : 'User',
                  size: AppAvatarSize.md,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activeUser.name.isNotEmpty ? activeUser.name : 'Guest User',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeUser.schoolCode,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
