import 'package:flutter/material.dart';

import '../../../shared/theme/careers_tokens.dart';

/// Label / value row used by job info cards and the candidate profile.
///
/// The label sits above the value so long values wrap cleanly instead of
/// squeezing into a narrow column on small screens.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? leading;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.leading,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: CareersColors.primarySoft,
            borderRadius: CareersRadius.chipAll,
          ),
          child: leading ??
              Icon(
                icon ?? Icons.info_outline,
                size: 17,
                color: CareersColors.primary,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                style: textTheme.titleMedium?.copyWith(color: valueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
