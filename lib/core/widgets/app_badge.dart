import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

enum AppBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
  primary,
}

enum AppBadgeSize {
  small,
  medium,
  large,
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final AppBadgeSize size;
  final IconData? icon;
  final bool filled;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.filled = false,
  });

  const AppBadge.success({
    super.key,
    required this.label,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.filled = false,
  }) : variant = AppBadgeVariant.success;

  const AppBadge.warning({
    super.key,
    required this.label,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.filled = false,
  }) : variant = AppBadgeVariant.warning;

  const AppBadge.error({
    super.key,
    required this.label,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.filled = false,
  }) : variant = AppBadgeVariant.error;

  const AppBadge.info({
    super.key,
    required this.label,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.filled = false,
  }) : variant = AppBadgeVariant.info;

  const AppBadge.neutral({
    super.key,
    required this.label,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.filled = false,
  }) : variant = AppBadgeVariant.neutral;

  const AppBadge.primary({
    super.key,
    required this.label,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.filled = false,
  }) : variant = AppBadgeVariant.primary;

  Color _getColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    switch (variant) {
      case AppBadgeVariant.success:
        return isDark ? AppColors.iosGreenDark : AppColors.iosGreen;
      case AppBadgeVariant.warning:
        return isDark ? AppColors.iosOrangeDark : AppColors.iosOrange;
      case AppBadgeVariant.error:
        return isDark ? AppColors.iosRedDark : AppColors.iosRed;
      case AppBadgeVariant.info:
        return isDark ? AppColors.iosBlueDark : AppColors.iosBlue;
      case AppBadgeVariant.neutral:
        return AppColors.iosSystemGray;
      case AppBadgeVariant.primary:
        return theme.colorScheme.primary;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppBadgeSize.small:
        return 10;
      case AppBadgeSize.medium:
        return 12;
      case AppBadgeSize.large:
        return 14;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppBadgeSize.small:
        return 10;
      case AppBadgeSize.medium:
        return 12;
      case AppBadgeSize.large:
        return 14;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case AppBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case AppBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    final backgroundColor = filled ? color : color.withOpacity(0.12);
    final textColor = filled ? Colors.white : color;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _iconSize,
              color: textColor,
            ),
            SizedBox(width: size == AppBadgeSize.small ? 3 : 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class AppStatusDot extends StatelessWidget {
  final AppBadgeVariant variant;
  final double size;
  final bool pulsing;

  const AppStatusDot({
    super.key,
    this.variant = AppBadgeVariant.neutral,
    this.size = 8,
    this.pulsing = false,
  });

  const AppStatusDot.success({
    super.key,
    this.size = 8,
    this.pulsing = false,
  }) : variant = AppBadgeVariant.success;

  const AppStatusDot.warning({
    super.key,
    this.size = 8,
    this.pulsing = false,
  }) : variant = AppBadgeVariant.warning;

  const AppStatusDot.error({
    super.key,
    this.size = 8,
    this.pulsing = false,
  }) : variant = AppBadgeVariant.error;

  const AppStatusDot.info({
    super.key,
    this.size = 8,
    this.pulsing = false,
  }) : variant = AppBadgeVariant.info;

  Color _getColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    switch (variant) {
      case AppBadgeVariant.success:
        return isDark ? AppColors.iosGreenDark : AppColors.iosGreen;
      case AppBadgeVariant.warning:
        return isDark ? AppColors.iosOrangeDark : AppColors.iosOrange;
      case AppBadgeVariant.error:
        return isDark ? AppColors.iosRedDark : AppColors.iosRed;
      case AppBadgeVariant.info:
        return isDark ? AppColors.iosBlueDark : AppColors.iosBlue;
      case AppBadgeVariant.neutral:
        return AppColors.iosSystemGray;
      case AppBadgeVariant.primary:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    if (pulsing) {
      return _PulsingDot(color: color, size: size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({
    required this.color,
    required this.size,
  });

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: widget.size + (widget.size * 1.5 * _animation.value),
                height: widget.size + (widget.size * 1.5 * _animation.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.3 * (1 - _animation.value)),
                ),
              );
            },
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class AppCountBadge extends StatelessWidget {
  final int count;
  final int? maxCount;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;

  const AppCountBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.backgroundColor,
    this.textColor,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayCount = maxCount != null && count > maxCount!
        ? '$maxCount+'
        : count.toString();

    final effectiveBackgroundColor = backgroundColor ?? 
        (isDark ? AppColors.iosRedDark : AppColors.iosRed);
    final effectiveTextColor = textColor ?? Colors.white;

    final isWide = displayCount.length > 2;

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 6 : 0,
      ),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        displayCount,
        style: GoogleFonts.inter(
          fontSize: size * 0.55,
          fontWeight: FontWeight.w600,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}
