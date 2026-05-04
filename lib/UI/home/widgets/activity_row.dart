import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/UI/home/widgets/home_dashboard_models.dart';
import 'package:admin_app/core/widgets/app_badge.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

Color _avatarBg(DashboardActivityType t) {
  return switch (t) {
    DashboardActivityType.attendance => const Color(0xFFE8EAF6),
    DashboardActivityType.ticket => const Color(0xFFFFF3E0),
    DashboardActivityType.nfc => const Color(0xFFE0F7FA),
    DashboardActivityType.profile => const Color(0xFFF3E5F5),
    DashboardActivityType.other => const Color(0xFFF5F5F5),
  };
}

Color _avatarText(DashboardActivityType t) {
  return switch (t) {
    DashboardActivityType.attendance => AppColors.info,
    DashboardActivityType.ticket => AppColors.warning,
    DashboardActivityType.nfc => AppColors.teal,
    DashboardActivityType.profile => AppColors.purple,
    DashboardActivityType.other => const Color(0xFF616161),
  };
}

AppBadgeVariant _badgeVariant(DashboardActivityType t) {
  return switch (t) {
    DashboardActivityType.attendance => AppBadgeVariant.info,
    DashboardActivityType.ticket => AppBadgeVariant.warning,
    DashboardActivityType.nfc => AppBadgeVariant.primary,
    DashboardActivityType.profile => AppBadgeVariant.primary,
    DashboardActivityType.other => AppBadgeVariant.neutral,
  };
}

class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.item});

  final DashboardActivityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: AppSpacing.sm + 1,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _avatarBg(item.type),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.initials,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _avatarText(item.type),
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.actorName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Gap(1),
                Text(
                  item.detailText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          AppBadge(
            label: item.badgeLabel,
            variant: _badgeVariant(item.type),
          ),
        ],
      ),
    );
  }
}
