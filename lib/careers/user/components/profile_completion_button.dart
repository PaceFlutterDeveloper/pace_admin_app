import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/careers/user/models/profile_completion_model.dart';
import 'package:admin_app/careers/user/utils/profile_completion_mapper.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
            color: CareersColors.success,
            icon: CupertinoIcons.checkmark_seal_fill,
            title: 'Profile complete',
            message: 'You are ready to apply for open positions.',
          ),
          CareersSpacing.gap16,
          AppButton.secondary(
            label: 'Edit profile',
            leadingIcon: CupertinoIcons.pencil,
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
              'Finish the items below to apply for jobs.'
        : 'Complete your profile to apply for jobs.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusBanner(
          color: CareersColors.warning,
          icon: CupertinoIcons.exclamationmark_circle_fill,
          title: 'Profile incomplete',
          message: message,
        ),
        if (missingItems.isNotEmpty) ...[
          CareersSpacing.gap16,
          _MissingFieldsCard(items: missingItems),
        ],
        CareersSpacing.gap16,
        AppButton.primary(
          label: 'Complete profile',
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CareersSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.careers.surface,
        borderRadius: CareersRadius.cardAll,
        border: Border.fromBorderSide(
          BorderSide(color: context.careers.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Still needed', style: textTheme.titleSmall),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: CareersColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.careers.textSecondary,
                      ),
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CareersSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: CareersRadius.cardAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: color),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(
                    color: context.careers.textSecondary,
                    height: 1.45,
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
