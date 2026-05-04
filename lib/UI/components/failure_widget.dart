import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FailureWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const FailureWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon with background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: errorColor.withOpacity(isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 40,
                color: errorColor,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Error title
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Error message
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                leadingIcon: CupertinoIcons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
