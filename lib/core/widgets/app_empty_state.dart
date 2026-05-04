import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final bool compact;

  const AppEmptyState({
    super.key,
    this.icon,
    this.iconAsset,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customIcon,
    this.iconSize = 64,
    this.iconColor,
    this.padding,
    this.compact = false,
  });

  factory AppEmptyState.noData({
    String title = 'No data found',
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppEmptyState(
      icon: CupertinoIcons.tray,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory AppEmptyState.noResults({
    String title = 'No results found',
    String? subtitle = 'Try adjusting your search or filters',
    String? actionLabel = 'Clear filters',
    VoidCallback? onAction,
  }) {
    return AppEmptyState(
      icon: CupertinoIcons.search,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory AppEmptyState.noConnection({
    String title = 'No internet connection',
    String? subtitle = 'Check your connection and try again',
    String? actionLabel = 'Retry',
    VoidCallback? onAction,
  }) {
    return AppEmptyState(
      icon: CupertinoIcons.wifi_slash,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory AppEmptyState.noNotifications({
    String title = 'No notifications',
    String? subtitle = 'You\'re all caught up!',
  }) {
    return AppEmptyState(
      icon: CupertinoIcons.bell,
      title: title,
      subtitle: subtitle,
    );
  }

  factory AppEmptyState.noMessages({
    String title = 'No messages yet',
    String? subtitle = 'Start a conversation',
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppEmptyState(
      icon: CupertinoIcons.chat_bubble,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor =
        iconColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
        );

    Widget iconWidget;
    if (customIcon != null) {
      iconWidget = customIcon!;
    } else if (icon != null) {
      iconWidget = Container(
        width: iconSize + 24,
        height: iconSize + 24,
        decoration: BoxDecoration(
          color: effectiveIconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: effectiveIconColor,
        ),
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          if (icon != null || customIcon != null)
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            AppButton.secondary(
              label: actionLabel!,
              onPressed: onAction,
              isFullWidth: false,
              size: compact ? AppButtonSize.small : AppButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}
