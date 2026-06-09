import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';

class CardDecoration {
  static BoxDecoration build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? AppColors.surfaceElevatedDark : AppColors.cardBg,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(
        color: isDark ? AppColors.dividerDark : AppColors.cardBorder,
      ),
      boxShadow: isDark ? AppShadows.none : AppShadows.soft,
    );
  }
}
