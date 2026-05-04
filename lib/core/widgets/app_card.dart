import 'package:flutter/material.dart';

import '../../config/themes/app_design_tokens.dart';
import '../../config/themes/app_theme.dart';

enum AppCardVariant {
  flat,
  elevated,
  outlined,
}

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? borderRadius;
  final Color? backgroundColor;
  final AppCardVariant variant;
  final bool enabled;
  final Widget? header;
  final Widget? footer;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.backgroundColor,
    this.variant = AppCardVariant.elevated,
    this.enabled = true,
    this.header,
    this.footer,
  });

  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.backgroundColor,
    this.enabled = true,
    this.header,
    this.footer,
  }) : variant = AppCardVariant.flat;

  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.backgroundColor,
    this.enabled = true,
    this.header,
    this.footer,
  }) : variant = AppCardVariant.outlined;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppCurves.standard,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onTap == null) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeExtension = AppThemeExtension.of(context);

    final effectiveRadius = widget.borderRadius ?? AppRadius.lg;
    final effectiveBgColor = widget.backgroundColor ??
        (isDark ? AppColors.cardDark : AppColors.cardLight);

    List<BoxShadow> shadows;
    Border? border;

    switch (widget.variant) {
      case AppCardVariant.flat:
        shadows = AppShadows.none;
        break;
      case AppCardVariant.elevated:
        shadows = themeExtension.cardShadow;
        break;
      case AppCardVariant.outlined:
        shadows = AppShadows.none;
        border = Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 1,
        );
        break;
    }

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: shadows,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) widget.header!,
            Padding(
              padding: widget.padding ?? AppSpacing.paddingMd,
              child: widget.child,
            ),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      cardContent = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.enabled ? widget.onTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: cardContent,
        ),
      );
    }

    if (widget.margin != null) {
      cardContent = Padding(
        padding: widget.margin!,
        child: cardContent,
      );
    }

    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: widget.enabled ? 1.0 : 0.6,
      child: cardContent,
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showDivider;

  const AppCardHeader({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
          color: backgroundColor,
          child: child,
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
      ],
    );
  }
}

class AppCardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showDivider;

  const AppCardFooter({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        Container(
          width: double.infinity,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
          color: backgroundColor,
          child: child,
        ),
      ],
    );
  }
}
