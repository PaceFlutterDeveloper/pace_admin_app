import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/utils/profile_completion_mapper.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// API-driven completion banner with missing-field guidance.
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StatusBanner(
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
            title: 'Profile Complete!',
            message: 'Your profile is complete and you can apply for jobs.',
          ),
          AppSpacing.vGapMd,
          AppButton.secondary(
            label: 'Edit Profile',
            leadingIcon: Icons.edit_outlined,
            onPressed: onNavigateToCompleteProfile,
          ),
        ],
      );
    }

    final missingItems = completion != null
        ? ProfileCompletionMapper.displayMissingItems(completion)
        : <String>[];

    final threshold = completion?.requiredPercentage ?? 100;
    final message = completion != null
        ? 'Your profile is ${completion.percentage}% complete '
              '($threshold% required${completion.isFresher ? ' for freshers' : ''}). '
              'Complete the items below to apply for jobs.'
        : 'Complete your profile to apply for jobs.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusBanner(
          color: AppColors.warning,
          icon: Icons.warning_rounded,
          title: 'Profile Incomplete',
          message: message,
        ),
        if (missingItems.isNotEmpty) ...[
          AppSpacing.vGapMd,
          _MissingFieldsCard(items: missingItems),
        ],
        AppSpacing.vGapMd,
        AppButton.primary(
          label: 'Complete Profile',
          onPressed: onNavigateToCompleteProfile,
        ),
      ],
    );
  }
}

class _MissingFieldsCard extends StatelessWidget {
  final List<String> items;

  const _MissingFieldsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Still needed',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.vGapSm,
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.warning,
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
