import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplyDialog extends StatefulWidget {
  final JobModel job;

  const ApplyDialog({super.key, required this.job});

  static Future<String?> show(BuildContext context, {required JobModel job}) {
    return showDialog<String?>(
      context: context,
      builder: (context) => ApplyDialog(job: job),
    );
  }

  @override
  State<ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<ApplyDialog> {
  final _coverLetterController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  void _submit() {
    final coverLetter = _coverLetterController.text.trim();
    Navigator.of(context).pop(coverLetter.isEmpty ? '' : coverLetter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Apply for ${widget.job.title}',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job.schoolName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _coverLetterController,
              label: 'Cover letter (optional)',
              hint: 'Tell us why you are a great fit...',
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: theme.colorScheme.primary),
          ),
        ),
        AppButton.primary(
          label: 'Submit Application',
          isFullWidth: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}
