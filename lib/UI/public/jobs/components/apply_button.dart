import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:admin_app/UI/public/user/utils/auth_guard.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Primary apply CTA. The auth guard and callback behaviour are unchanged.
class ApplyButton extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onApply;
  final bool hasApplied;
  final bool isLoading;

  const ApplyButton({
    super.key,
    required this.job,
    this.onApply,
    this.hasApplied = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hasApplied) {
      return const AppButton.secondary(
        label: 'Already applied',
        leadingIcon: CupertinoIcons.checkmark_circle_fill,
        onPressed: null,
      );
    }

    return AppButton.primary(
      label: isLoading ? 'Please wait...' : 'Apply now',
      leadingIcon: CupertinoIcons.paperplane_fill,
      isLoading: isLoading,
      onPressed: isLoading
          ? null
          : () {
              AuthGuard.requireAuth(
                context,
                onAuthenticated: () {
                  onApply?.call();
                },
              );
            },
    );
  }
}

/// Sticky bar that pins the apply CTA to the bottom of the job detail screen.
class ApplyBottomBar extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onApply;
  final bool hasApplied;
  final bool isLoading;

  const ApplyBottomBar({
    super.key,
    required this.job,
    this.onApply,
    this.hasApplied = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final salary = job.salaryRange;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: CareersColors.surface,
        border: Border(top: BorderSide(color: CareersColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CareersSpacing.screenH,
            12,
            CareersSpacing.screenH,
            12,
          ),
          // AppButton only sets a minimum height, so it would stretch to the
          // full height the Scaffold offers a bottom bar. IntrinsicHeight
          // tightens the row to the button's natural height instead.
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (salary.isNotEmpty) ...[
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Salary', style: textTheme.bodySmall),
                        const SizedBox(height: 1),
                        Text(
                          salary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: ApplyButton(
                    job: job,
                    onApply: onApply,
                    hasApplied: hasApplied,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
