import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:admin_app/staff/widgets/staff_icons.dart';

/// Tinted rounded tile with a soft light edge (Glass icon style).
class GlassIconTile extends StatelessWidget {
  const GlassIconTile({
    super.key,
    required this.glyph,
    required this.accent,
    this.size = 42,
    this.radius,
    this.iconSize,
    this.strokeWidth = 1.9,
    this.imageUrl,
    this.child,
  });

  final String glyph;
  final StaffAccent accent;
  final double size;
  final double? radius;
  final double? iconSize;
  final double strokeWidth;

  /// Network image drawn over the glyph. A failed load leaves the glyph.
  final String? imageUrl;

  /// Overlay (for example a count badge) positioned relative to the tile.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final tint = p.tint(accent);
    final r = radius ?? size * 0.34;
    final br = BorderRadius.circular(r);
    final edge = p.isDark
        ? Colors.white.withValues(alpha: 0.14)
        : tint.foreground.withValues(alpha: 0.16);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: tint.background,
                borderRadius: br,
                border: Border.all(color: edge),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: br,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0, -0.35),
                  colors: [
                    Colors.white.withValues(alpha: p.isDark ? 0.12 : 0.40),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _GlassIcon(
                glyph: glyph,
                color: tint.foreground,
                size: iconSize ?? size * 0.44,
                strokeWidth: strokeWidth,
                imageUrl: imageUrl,
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({
    required this.glyph,
    required this.color,
    required this.size,
    required this.strokeWidth,
    this.imageUrl,
  });

  final String glyph;
  final Color color;
  final double size;
  final double strokeWidth;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final glyphIcon = StaffIcon(
      glyph,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
    );
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return Center(child: glyphIcon);
    // API `icon_url` (internal-web menus). Glyph is only the load/error fallback.
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Center(child: glyphIcon),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(child: glyphIcon);
        },
      ),
    );
  }
}

/// Surface card with the 1px hairline border used across the Hub design.
class StaffCard extends StatelessWidget {
  const StaffCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 22,
    this.onTap,
    this.color,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final br = BorderRadius.circular(radius);
    Widget body = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    if (onTap != null) {
      body = InkWell(
        borderRadius: br,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: body,
      );
    }
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        // Soft lift on paper-white surfaces; dark mode relies on the hairline.
        decoration: BoxDecoration(
          borderRadius: br,
          boxShadow: p.isDark
              ? null
              : [
                  BoxShadow(
                    color: p.shadow.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: color ?? p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: br,
            side: BorderSide(color: p.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: body,
        ),
      ),
    );
  }
}

/// Small caps label such as "MY WORK".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(22, 14, 22, 8),
      child: Text(
        text,
        style: sora(
          11,
          weight: FontWeight.w700,
          color: context.staff.muted,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

/// Section title with an optional amber action ("See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: sora(15.5, weight: FontWeight.w700, color: p.text),
          ),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  action!,
                  style: sora(
                    12.5,
                    weight: FontWeight.w700,
                    color: p.amberText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Number plus caption block used on hero cards (ink in dark, white in light).
class HeroStat extends StatelessWidget {
  const HeroStat({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final radius = BorderRadius.circular(14);
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: sora(17, weight: FontWeight.w800, color: p.heroTitle),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: sora(10.5, weight: FontWeight.w500, color: p.heroSubtle),
          ),
        ],
      ),
    );
    final decoration = BoxDecoration(
      color: p.isDark
          ? Colors.white.withValues(alpha: 0.06)
          : p.surface.withValues(alpha: 0.75),
      borderRadius: radius,
      border: Border.all(
        color: p.isDark ? Colors.white.withValues(alpha: 0.08) : p.border,
      ),
    );
    if (onTap == null) {
      return Container(decoration: decoration, child: content);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: Ink(decoration: decoration, child: content),
      ),
    );
  }
}

/// Hero container shared by Home and Profile: ink with an amber corner glow in
/// dark mode, a white card with a soft amber wash in light mode.
class HeroSurface extends StatelessWidget {
  const HeroSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final radius = BorderRadius.circular(28);
    if (p.isDark) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: StaffPalette.heroBorder),
          gradient: StaffPalette.heroGradient,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          gradient: StaffPalette.heroGlow,
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      );
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: p.border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(p.amber.withValues(alpha: 0.16), p.surface),
            p.surface,
          ],
          stops: const [0, 0.65],
        ),
        boxShadow: [
          BoxShadow(
            color: p.shadow.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}

/// Primary amber button (48px, r15).
class AmberButton extends StatelessWidget {
  const AmberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.glyph,
    this.height = 48,
    this.soft = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? glyph;
  final double height;

  /// Tinted variant used for secondary actions on panels.
  final bool soft;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final bg = soft ? p.amberSoft : p.amber;
    final fg = soft ? p.amberText : p.onAmber;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: loading || onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: fg,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (glyph != null) ...[
                        StaffIcon(glyph!, size: 19, color: fg, strokeWidth: 2),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sora(
                            height < 48 ? 13.5 : 14.5,
                            weight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Amber count badge that overlaps the top-right of a tile.
class StaffCountBadge extends StatelessWidget {
  const StaffCountBadge(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      constraints: const BoxConstraints(minWidth: 21, minHeight: 21),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.amber,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: p.background, width: 2),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: sora(11, weight: FontWeight.w800, color: p.onAmber),
      ),
    );
  }
}

/// "Soon" marker for modules without a backend yet.
class SoonPill extends StatelessWidget {
  const SoonPill({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Text(
        'SOON',
        style: sora(
          8.5,
          weight: FontWeight.w800,
          color: p.muted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Round-rect icon button used in headers (bell, back).
class StaffIconButton extends StatelessWidget {
  const StaffIconButton({
    super.key,
    required this.glyph,
    required this.onTap,
    this.active = false,
    this.showDot = false,
    this.semanticLabel,
  });

  final String glyph;
  final VoidCallback onTap;
  final bool active;
  final bool showDot;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final bg = active ? p.amber : p.surface;
    final fg = active ? p.onAmber : p.text;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: active ? p.amber : p.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                StaffIcon(
                  glyph,
                  size: 22,
                  color: fg,
                  strokeWidth: active ? 2 : 1.9,
                ),
                if (showDot)
                  Positioned(
                    top: 10,
                    right: 11,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: p.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered icon, title and optional action for empty and error states.
class StaffStateMessage extends StatelessWidget {
  const StaffStateMessage({
    super.key,
    required this.glyph,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.accent = StaffAccent.amber,
  });

  final String glyph;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final StaffAccent accent;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassIconTile(glyph: glyph, accent: accent, size: 64, radius: 22),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: sora(16, weight: FontWeight.w700, color: p.text),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: sora(
                  12.5,
                  weight: FontWeight.w400,
                  color: p.muted,
                  height: 1.5,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 200,
                child: AmberButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  soft: true,
                  height: 44,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Placeholder block for loading skeletons.
class StaffSkeleton extends StatelessWidget {
  const StaffSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 10,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Soft colour wash behind staff pages. Gives the light theme the warmth the
/// dark hero glow gives the dark theme, without touching content.
class StaffBackdrop extends StatelessWidget {
  const StaffBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final warm = p.amber.withValues(alpha: p.isDark ? 0.05 : 0.16);
    final cool = StaffAccent.blue.base.withValues(
      alpha: p.isDark ? 0.03 : 0.09,
    );
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1.0, -1.05),
            radius: 1.0,
            colors: [warm, warm.withValues(alpha: 0)],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.1, 0.55),
              radius: 0.9,
              colors: [cool, cool.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

/// Page frame for pushed staff screens: themed background, backdrop and a
/// safe-area body.
class StaffPage extends StatelessWidget {
  const StaffPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.staff.background,
      body: Stack(
        children: [
          const Positioned.fill(child: StaffBackdrop()),
          SafeArea(bottom: false, child: child),
        ],
      ),
    );
  }
}

/// Page header used by pushed staff screens: back button, title, subtitle and
/// an optional trailing widget.
class StaffPageHeader extends StatelessWidget {
  const StaffPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;

  /// Pushed screens show back. The profile gate hides it when nobody is
  /// signed in, because there is no screen to return to.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (showBack) ...[
            StaffIconButton(
              glyph: StaffGlyphs.chevronLeft,
              semanticLabel: 'Back',
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sora(
                    21,
                    weight: FontWeight.w700,
                    color: p.text,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sora(12, weight: FontWeight.w400, color: p.muted),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}
