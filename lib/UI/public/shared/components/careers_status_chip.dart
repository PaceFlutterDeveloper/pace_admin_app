import 'package:flutter/material.dart';

import '../theme/careers_tokens.dart';

/// Status pill shared by application cards, job headers and filter rows.
///
/// Colours come from [CareersStatusColors] so the same status always reads the
/// same way wherever it appears.
class CareersStatusChip extends StatelessWidget {
  final String label;
  final CareersStatusStyle style;
  final IconData? icon;
  final bool dense;

  const CareersStatusChip({
    super.key,
    required this.label,
    required this.style,
    this.icon,
    this.dense = false,
  });

  /// Chip for an application status (`Applied`, `Shortlisted`, ...).
  factory CareersStatusChip.application(
    String status, {
    Key? key,
    String? label,
    bool dense = false,
  }) {
    return CareersStatusChip(
      key: key,
      label: label ?? status,
      style: CareersStatusColors.application(status),
      dense: dense,
    );
  }

  /// Chip for a job vacancy status (`Open`, `Closed`, ...).
  factory CareersStatusChip.job(String status, {Key? key, bool dense = false}) {
    return CareersStatusChip(
      key: key,
      label: status,
      style: CareersStatusColors.job(status),
      dense: dense,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = context.careers.status(this.style);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: CareersRadius.chipAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: style.foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: style.foreground,
              fontSize: dense ? 10.5 : 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small neutral pill for job metadata (employment type, location, ...).
class CareersMetaChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const CareersMetaChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final palette = context.careers;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: CareersRadius.chipAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: palette.textSecondary),
            const SizedBox(width: 5),
          ],
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
