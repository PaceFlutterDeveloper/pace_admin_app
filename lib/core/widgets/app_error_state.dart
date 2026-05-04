import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Widget? customIcon;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final bool compact;
  final bool showIcon;

  const AppErrorState({
    super.key,
    this.title,
    this.message,
    this.retryLabel,
    this.onRetry,
    this.icon,
    this.customIcon,
    this.iconSize = 56,
    this.padding,
    this.compact = false,
    this.showIcon = true,
  });

  factory AppErrorState.generic({
    String? title = 'Something went wrong',
    String? message = 'An unexpected error occurred. Please try again.',
    String? retryLabel = 'Try again',
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: CupertinoIcons.exclamationmark_circle,
      title: title,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.network({
    String? title = 'Connection error',
    String? message = 'Please check your internet connection and try again.',
    String? retryLabel = 'Retry',
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: CupertinoIcons.wifi_slash,
      title: title,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.serverError({
    String? title = 'Server error',
    String? message = 'We\'re having trouble connecting to the server. Please try again later.',
    String? retryLabel = 'Retry',
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: CupertinoIcons.xmark_circle,
      title: title,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.notFound({
    String? title = 'Not found',
    String? message = 'The requested content could not be found.',
    String? retryLabel,
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: CupertinoIcons.search,
      title: title,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.unauthorized({
    String? title = 'Access denied',
    String? message = 'You don\'t have permission to view this content.',
    String? retryLabel,
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: CupertinoIcons.lock,
      title: title,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }

  factory AppErrorState.timeout({
    String? title = 'Request timeout',
    String? message = 'The request took too long. Please try again.',
    String? retryLabel = 'Retry',
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      icon: CupertinoIcons.clock,
      title: title,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
        );

    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;
    final effectiveIcon = icon ?? CupertinoIcons.exclamationmark_circle;

    Widget iconWidget;
    if (customIcon != null) {
      iconWidget = customIcon!;
    } else if (showIcon) {
      iconWidget = Container(
        width: iconSize + 24,
        height: iconSize + 24,
        decoration: BoxDecoration(
          color: errorColor.withOpacity(isDark ? 0.15 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          effectiveIcon,
          size: iconSize,
          color: errorColor,
        ),
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    final effectiveTitle = title ?? 'Something went wrong';
    final effectiveMessage = message ?? 'Please try again.';

    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            iconWidget,
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          ],
          Text(
            effectiveTitle,
            style: GoogleFonts.inter(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          Text(
            effectiveMessage,
            style: GoogleFonts.inter(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (retryLabel != null && onRetry != null) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            AppButton.primary(
              label: retryLabel!,
              onPressed: onRetry,
              isFullWidth: false,
              size: compact ? AppButtonSize.small : AppButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}

class AppInlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppInlineError({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = CupertinoIcons.exclamationmark_circle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: errorColor,
            size: 20,
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: errorColor,
              ),
            ),
          ),
          if (onRetry != null) ...[
            AppSpacing.hGapSm,
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: errorColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
