import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool enabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
  }) : variant = AppButtonVariant.danger;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    if (!_isEnabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    _controller.reverse();
  }

  bool get _isEnabled =>
      widget.enabled && !widget.isLoading && widget.onPressed != null;

  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppSizes.buttonHeightSm;
      case AppButtonSize.medium:
        return AppSizes.buttonHeight;
      case AppButtonSize.large:
        return AppSizes.buttonHeightLg;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 22;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final dangerColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;

    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        backgroundColor = primaryColor;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = primaryColor;
        border = Border.all(color: primaryColor, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = primaryColor;
        break;
      case AppButtonVariant.danger:
        backgroundColor = dangerColor;
        foregroundColor = Colors.white;
        break;
    }

    if (!_isEnabled && widget.variant != AppButtonVariant.ghost) {
      backgroundColor = backgroundColor.withOpacity(0.5);
      foregroundColor = foregroundColor.withOpacity(0.7);
    }

    final textStyle = GoogleFonts.inter(
      fontSize: _fontSize,
      fontWeight: FontWeight.w600,
      color: foregroundColor,
      letterSpacing: -0.3,
    );

    Widget content;
    if (widget.isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: foregroundColor,
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.leadingIcon != null) ...[
            Icon(
              widget.leadingIcon,
              size: _iconSize,
              color: foregroundColor,
            ),
            AppSpacing.hGapSm,
          ],
          Text(widget.label, style: textStyle),
          if (widget.trailingIcon != null) ...[
            AppSpacing.hGapSm,
            Icon(
              widget.trailingIcon,
              size: _iconSize,
              color: foregroundColor,
            ),
          ],
        ],
      );
    }

    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadius.borderRadiusMd,
            border: border,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (widget.isFullWidth) {
      return button;
    }

    return IntrinsicWidth(child: button);
  }
}

class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool enabled;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 44,
    this.tooltip,
    this.enabled = true,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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

  bool get _isEnabled => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        widget.color ?? theme.colorScheme.onSurface.withOpacity(0.7);

    Widget button = GestureDetector(
      onTapDown: (_) => _isEnabled ? _controller.forward() : null,
      onTapUp: (_) => _isEnabled ? _controller.reverse() : null,
      onTapCancel: () => _isEnabled ? _controller.reverse() : null,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedOpacity(
          duration: AppDurations.fast,
          opacity: _isEnabled ? 1.0 : 0.4,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(
              widget.icon,
              color: effectiveColor,
              size: widget.size * 0.5,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
