import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCompletionButton extends StatelessWidget {
  final VoidCallback? onNavigateToCompleteProfile;

  const ProfileCompletionButton({
    super.key,
    this.onNavigateToCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = CareersUserManager.isProfileComplete();

    if (isComplete) {
      return _buildCompleteStatusCard(context);
    }

    return _buildIncompleteSection(context);
  }

  Widget _buildCompleteStatusCard(BuildContext context) {
    return _StatusBanner(
      color: AppColors.success,
      icon: CupertinoIcons.checkmark_circle_fill,
      title: 'Profile Complete!',
      message: 'Your profile is complete and you can apply for jobs.',
    );
  }

  Widget _buildIncompleteSection(BuildContext context) {
    return Column(
      children: [
        _StatusBanner(
          color: AppColors.warning,
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          title: 'Profile Incomplete',
          message: 'Complete your profile to apply for jobs.',
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton.primary(
          label: 'Complete Profile',
          onPressed: onNavigateToCompleteProfile,
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String message;

  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: color.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
