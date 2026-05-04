import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

class AppListTile extends StatefulWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showChevron;
  final bool showDivider;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Widget? badge;
  final bool dense;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.showChevron = false,
    this.showDivider = false,
    this.enabled = true,
    this.padding,
    this.backgroundColor,
    this.badge,
    this.dense = false,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  State<AppListTile> createState() => _AppListTileState();
}

class _AppListTileState extends State<AppListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectivePadding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: widget.dense ? AppSpacing.sm : AppSpacing.md,
        );

    Widget content = AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Container(
        color: _isPressed
            ? (isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03))
            : widget.backgroundColor,
        padding: effectivePadding,
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              AppSpacing.hGapMd,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: widget.titleStyle ?? GoogleFonts.inter(
                              fontSize: widget.dense ? 15 : 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.badge != null) ...[
                          AppSpacing.hGapSm,
                          widget.badge!,
                        ],
                      ],
                    ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: widget.dense ? 2 : 4),
                    Text(
                      widget.subtitle!,
                      style: widget.subtitleStyle ?? GoogleFonts.inter(
                        fontSize: widget.dense ? 13 : 14,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null || widget.showChevron) ...[
              AppSpacing.hGapSm,
              if (widget.trailing != null) widget.trailing!,
              if (widget.showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
            ],
          ],
        ),
      ),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      content = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.enabled ? widget.onTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: content,
        ),
      );
    }

    if (widget.showDivider) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Padding(
            padding: EdgeInsets.only(
              left: widget.leading != null
                  ? effectivePadding.horizontal / 2 + 40 + AppSpacing.md
                  : effectivePadding.horizontal / 2,
            ),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
        ],
      );
    }

    return content;
  }
}

class AppListSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showDividers;

  const AppListSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.padding,
    this.backgroundColor,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              header!.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ),
        Container(
          margin: padding,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark ? AppColors.cardDark : AppColors.cardLight),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (showDividers && i < children.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color:
                          isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
            ),
            child: Text(
              footer!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

class AppSettingsListTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool enabled;

  const AppSettingsListTile({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? Colors.white;
    final effectiveIconBgColor = iconBackgroundColor ?? theme.colorScheme.primary;

    return AppListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: effectiveIconBgColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 18,
          color: effectiveIconColor,
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      showChevron: showChevron,
      enabled: enabled,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
    );
  }
}
