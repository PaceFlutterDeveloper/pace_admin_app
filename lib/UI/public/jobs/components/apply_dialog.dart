import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplyDialog extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onApply;

  const ApplyDialog({super.key, required this.job, this.onApply});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Apply for ${job.title}',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        'Application functionality will be implemented here. This could include:\n\n• Resume upload\n• Cover letter\n• Contact information\n• Application form',
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: theme.colorScheme.onSurface.withOpacity(0.75),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: GoogleFonts.inter(color: theme.colorScheme.primary),
          ),
        ),
        AppButton.primary(
          label: 'Apply',
          isFullWidth: false,
          onPressed: () {
            Navigator.of(context).pop();
            onApply?.call();
          },
        ),
      ],
    );
  }

  static void show(
    BuildContext context,
    JobModel job, {
    VoidCallback? onApply,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => ApplyDialog(job: job, onApply: onApply),
    );
  }
}
