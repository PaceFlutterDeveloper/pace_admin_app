import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class ApplyDialog extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onApply;

  const ApplyDialog({
    Key? key,
    required this.job,
    this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return AlertDialog(
      title: _buildDialogTitle(w),
      content: _buildDialogContent(w),
      actions: _buildDialogActions(w, context),
    );
  }

  Widget _buildDialogTitle(double w) {
    return Text(
      'Apply for ${job.title}',
      style: TextStyle(
        fontSize: w * 0.045,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDialogContent(double w) {
    return Text(
      'Application functionality will be implemented here. This could include:\n\n• Resume upload\n• Cover letter\n• Contact information\n• Application form',
      style: TextStyle(
        fontSize: w * 0.04,
        height: 1.5,
      ),
    );
  }

  List<Widget> _buildDialogActions(double w, BuildContext context) {
    return [
      _buildCloseButton(w, context),
      _buildApplyButton(w, context),
    ];
  }

  Widget _buildCloseButton(double w, BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(
        'Close',
        style: TextStyle(
          fontSize: w * 0.04,
          color: ConstColors.primary,
        ),
      ),
    );
  }

  Widget _buildApplyButton(double w, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        onApply?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ConstColors.primary,
      ),
      child: Text(
        'Apply',
        style: TextStyle(
          fontSize: w * 0.04,
          color: ConstColors.whiteColor,
        ),
      ),
    );
  }

  static void show(BuildContext context, JobModel job,
      {VoidCallback? onApply}) {
    showDialog(
      context: context,
      builder: (context) => ApplyDialog(
        job: job,
        onApply: onApply,
      ),
    );
  }
}
