import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Confirmation step before submitting an application. Still one step: the
/// optional cover letter is the only input, exactly as before.
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
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: CareersGradients.cta,
                        borderRadius: BorderRadius.circular(CareersRadius.chip),
                      ),
                      child: const Icon(
                        CupertinoIcons.paperplane_fill,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apply for this role',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.job.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                CareersSpacing.gap24,
                AppTextField(
                  controller: _coverLetterController,
                  label: 'Cover letter (optional)',
                  hint: 'Tell us why you are a great fit...',
                  maxLines: 5,
                  outlined: true,
                ),
                CareersSpacing.gap12,
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.lock_shield,
                      size: 14,
                      color: CareersColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your saved profile and CV are sent with this application.',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                CareersSpacing.gap24,
                AppButton.primary(
                  label: 'Submit application',
                  leadingIcon: CupertinoIcons.paperplane_fill,
                  onPressed: _submit,
                ),
                CareersSpacing.gap8,
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
