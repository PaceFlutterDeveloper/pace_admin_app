import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';

class BuildStatusTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final int count;

  const BuildStatusTile({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: AppSizes.iconSm,
              ),
              AppSpacing.hGapXs,
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vGapXs,
          Text(
            '$count',
            style: theme.textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
