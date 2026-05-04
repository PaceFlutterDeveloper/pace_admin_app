import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/UI/home/widgets/activity_row.dart';
import 'package:admin_app/UI/home/widgets/home_dashboard_models.dart';
import 'package:flutter/material.dart';

class RecentActivityFeed extends StatelessWidget {
  const RecentActivityFeed({
    super.key,
    required this.activities,
  });

  final List<DashboardActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => Divider(
          height: 0,
          thickness: 0.5,
          color: theme.dividerTheme.color,
        ),
        itemBuilder: (_, i) => ActivityRow(item: activities[i]),
      ),
    );
  }
}
