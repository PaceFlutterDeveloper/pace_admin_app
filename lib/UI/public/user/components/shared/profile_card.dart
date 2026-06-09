import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ProfileCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.cardBorder,
        ),
        boxShadow: isDark ? AppShadows.none : AppShadows.soft,
      ),
      child: child,
    );
  }
}
