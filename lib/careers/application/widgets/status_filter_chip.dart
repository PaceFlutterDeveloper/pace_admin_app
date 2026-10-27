import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:flutter/material.dart';

class StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.careers;
    return Material(
      color: isSelected ? CareersColors.primary : palette.surface,
      borderRadius: CareersRadius.pillAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: CareersRadius.pillAll,
            border: Border.all(
              color: isSelected ? CareersColors.primary : palette.border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? CareersColors.onPrimary
                  : palette.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
