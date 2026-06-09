import 'package:admin_app/UI/public/user/components/shared/profile_card.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeaderCard extends StatelessWidget {
  final VoidCallback? onCompleteProfile;

  const ProfileHeaderCard({
    super.key,
    this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          _buildAvatar(context),
          const SizedBox(height: AppSpacing.md),
          _buildUserInfo(context),
          const SizedBox(height: AppSpacing.md),
          _buildProfileStatus(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 44,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
      child: Icon(
        CupertinoIcons.person_fill,
        size: 44,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          CareersUserManager.getDisplayName(),
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          CareersUserManager.getEmail(),
          style: GoogleFonts.inter(
            fontSize: 15,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStatus(BuildContext context) {
    final isComplete = CareersUserManager.isProfileComplete();
    final color = isComplete ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.exclamationmark_triangle_fill,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isComplete ? 'Profile Complete' : 'Profile Incomplete',
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
