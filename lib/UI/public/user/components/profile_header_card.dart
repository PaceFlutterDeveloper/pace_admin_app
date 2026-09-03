import 'package:admin_app/UI/public/user/components/careers_profile_image.dart';
import 'package:admin_app/UI/public/user/components/shared/profile_card.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header card showing the candidate's identity and completion status.
class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;

  /// API-driven completion state; null while unknown.
  final bool? isComplete;
  final int? completionPercentage;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isComplete,
    this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          CareersProfileImage(
            remoteSource: avatarUrl,
            size: AppSizes.avatarXl,
          ),
          AppSpacing.vGapMd,
          _buildUserInfo(context),
          if (isComplete != null) ...[
            AppSpacing.vGapMd,
            _buildProfileStatus(context),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        AppSpacing.vGapXs,
        Text(
          email,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStatus(BuildContext context) {
    final complete = isComplete ?? false;
    final color = complete ? AppColors.success : AppColors.warning;
    final label = complete
        ? 'Profile Complete'
        : completionPercentage != null
        ? 'Profile $completionPercentage% Complete'
        : 'Profile Incomplete';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            complete
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.exclamationmark_triangle_fill,
            color: color,
            size: AppSizes.iconXs,
          ),
          AppSpacing.hGapSm,
          Text(
            label,
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
