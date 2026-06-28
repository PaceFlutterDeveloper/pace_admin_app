import 'package:admin_app/UI/employee/tickets/manage_tickets/components/build_status_tile.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/config/themes/app_theme.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NonCollapsedHeader extends StatelessWidget {
  final int all;
  final int inProgress;
  final int finished;
  final double topPadding;

  const NonCollapsedHeader({
    super.key,
    required this.topPadding,
    required this.all,
    required this.inProgress,
    required this.finished,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final primary = theme.colorScheme.primary;
    final cardShadow = AppThemeExtension.of(context).elevatedShadow;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final horizontalMargin = w * 0.04;
    final backgroundBottom = h * 0.10;
    final headerTopOffset = topPadding + h * 0.02;
    final cardTopOffset = topPadding + h * 0.06;
    final cardPadding = w * 0.04;
    final iconSize = w * 0.07;
    final borderRadius = w * 0.08;

    return Stack(
      children: [
        Positioned.fill(
          bottom: backgroundBottom,
          child: Container(
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
            ),
          ),
        ),
        Positioned(
          top: headerTopOffset,
          left: horizontalMargin,
          right: horizontalMargin,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.home.path);
                  }
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onPrimary,
                  size: iconSize,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Text(
                  'Manage Your Tickets',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: cardTopOffset,
          left: horizontalMargin,
          right: horizontalMargin,
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? colors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary of Your Work',
                  style: theme.textTheme.headlineSmall,
                ),
                AppSpacing.vGapXs,
                Text(
                  'Your current ticket progress',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                AppSpacing.vGapMd,
                Row(
                  children: [
                    Expanded(
                      child: BuildStatusTile(
                        icon: Icons.list_alt,
                        label: 'To Do',
                        count: all,
                      ),
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: BuildStatusTile(
                        icon: Icons.timelapse,
                        label: 'In Progress',
                        count: inProgress,
                        iconColor: colors.warning,
                      ),
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: BuildStatusTile(
                        icon: Icons.check_circle,
                        label: 'Done',
                        count: finished,
                        iconColor: colors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
