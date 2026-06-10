import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// API-driven completion banner with a call to action when incomplete.
class ProfileCompletionButton extends StatelessWidget {
  final ProfileCompletionModel? completion;
  final VoidCallback? onNavigateToCompleteProfile;

  const ProfileCompletionButton({
    super.key,
    this.completion,
    this.onNavigateToCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    final completion = this.completion;

    if (completion != null && completion.isComplete && completion.canApply) {
      return const _StatusBanner(
        color: AppColors.success,
        icon: Icons.check_circle_rounded,
        title: 'Profile Complete!',
        message: 'Your profile is complete and you can apply for jobs.',
      );
    }

    final message = completion != null
        ? 'Your profile is ${completion.percentage}% complete. '
              'Complete it to apply for jobs.'
        : 'Complete your profile to apply for jobs.';

    return Column(
      children: [
        _StatusBanner(
          color: AppColors.warning,
          icon: Icons.warning_rounded,
          title: 'Profile Incomplete',
          message: message,
        ),
        AppSpacing.vGapMd,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSizes.iconSm + 2),
          AppSpacing.hGapSm,
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
                    color: color.withValues(alpha: 0.85),
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
