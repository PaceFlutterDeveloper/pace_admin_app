import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/user/utils/auth_guard.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApplyButton extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onApply;

  const ApplyButton({
    super.key,
    required this.job,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: 'Apply for this Position',
      leadingIcon: CupertinoIcons.paperplane_fill,
      onPressed: () {
        AuthGuard.requireAuth(context, onAuthenticated: () {
          onApply?.call();
        });
      },
    );
  }
}
