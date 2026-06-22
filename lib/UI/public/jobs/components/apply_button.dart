import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/user/utils/auth_guard.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';

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
        label: 'Already Applied',
        leadingIcon: CupertinoIcons.checkmark_circle_fill,
        onPressed: null,
      );
    }

    return AppButton.primary(
      label: isLoading ? 'Please wait...' : 'Apply for this Position',
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
