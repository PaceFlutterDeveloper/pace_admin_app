import 'package:admin_app/staff/leave/domain/leave_models.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 12 or 12.5, without a trailing ".0".
String leaveNumber(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

String leaveDays(double days) {
  return days == 1 ? '1 day' : '${leaveNumber(days)} days';
}

String leaveRange(DateTime? from, DateTime? to) {
  if (from == null) return '';
  final start = DateFormat('d MMM yyyy').format(from);
  if (to == null || to == from) return start;
  final sameYear = from.year == to.year;
  final first = DateFormat(sameYear ? 'd MMM' : 'd MMM yyyy').format(from);
  return '$first – ${DateFormat('d MMM yyyy').format(to)}';
}

String leaveHalfLabel(String halfDay) {
  return switch (halfDay) {
    'am' => 'Morning half',
    'pm' => 'Afternoon half',
    _ => '',
  };
}

/// Half-day label and/or day count. Skips a useless "0 days".
String leaveLengthLabel({required double days, required String halfDay}) {
  final half = leaveHalfLabel(halfDay);
  if (half.isNotEmpty) {
    return days > 0 ? '$half · ${leaveDays(days)}' : half;
  }
  if (days > 0) return leaveDays(days);
  return '';
}

String leaveAppliedLabel(DateTime? appliedAt) {
  if (appliedAt == null) return '';
  return 'Applied ${DateFormat('d MMM yyyy').format(appliedAt)}';
}

/// Colours for a leave status pill.
({Color background, Color foreground}) leaveStatusColors(
  StaffPalette p,
  LeaveStatus status,
) {
  switch (status) {
    case LeaveStatus.approved:
      final t = p.tint(StaffAccent.green);
      return (background: t.background, foreground: t.foreground);
    case LeaveStatus.pending:
      final t = p.tint(StaffAccent.amber);
      return (background: t.background, foreground: p.amberText);
    case LeaveStatus.rejected:
      return (
        background: p.danger.withValues(alpha: p.isDark ? 0.18 : 0.12),
        foreground: p.dangerText,
      );
    case LeaveStatus.cancelled:
    case LeaveStatus.other:
      return (background: p.surfaceRaised, foreground: p.muted);
  }
}

class LeaveStatusPill extends StatelessWidget {
  const LeaveStatusPill(this.status, {super.key});

  final LeaveStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final colors = leaveStatusColors(p, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: sora(11, weight: FontWeight.w700, color: colors.foreground),
      ),
    );
  }
}
