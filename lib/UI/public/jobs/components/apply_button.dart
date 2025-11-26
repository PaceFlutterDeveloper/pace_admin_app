import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/user/utils/auth_guard.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class ApplyButton extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onApply;

  const ApplyButton({
    Key? key,
    required this.job,
    this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Container(
      width: double.infinity,
      height: h * 0.07,
      decoration: _buildApplyButtonDecoration(w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleApplyButtonTap(context),
          borderRadius: BorderRadius.circular(w * 0.025),
          child: Center(
            child: _buildApplyButtonContent(w),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildApplyButtonDecoration(double w) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ConstColors.primary,
          ConstColors.primary.withValues(alpha: 0.8)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(w * 0.025),
      boxShadow: [
        BoxShadow(
          color: ConstColors.primary.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildApplyButtonContent(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.send,
          color: ConstColors.whiteColor,
          size: w * 0.05,
        ),
        SizedBox(width: w * 0.02),
        Text(
          'Apply for this Position',
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.w700,
            color: ConstColors.whiteColor,
          ),
        ),
      ],
    );
  }

  void _handleApplyButtonTap(BuildContext context) {
    AuthGuard.requireAuth(context, onAuthenticated: () {
      onApply?.call();
    });
  }
}
