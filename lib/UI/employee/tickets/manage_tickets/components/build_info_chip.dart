import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';

class BuildInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const BuildInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: iconColor ?? colors.textSecondary,
      ),
      label: Text(
        label,
        style: theme.textTheme.labelSmall,
      ),
      backgroundColor: colors.surfaceContainer,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colors.border),
    );
  }
}
