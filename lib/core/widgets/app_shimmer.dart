import 'package:flutter/material.dart';

import '../../config/themes/app_design_tokens.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration? duration;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = widget.baseColor ??
        (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8));
    final highlightColor = widget.highlightColor ??
        (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF5F5F5));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerLine({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
        shape: BoxShape.circle,
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;
  final bool showTrailing;

  const ShimmerListTile({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (showAvatar) ...[
              const ShimmerCircle(size: 44),
              AppSpacing.hGapMd,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(width: 150, height: 14),
                  if (showSubtitle) ...[
                    AppSpacing.vGapSm,
                    const ShimmerLine(width: 100, height: 12),
                  ],
                ],
              ),
            ),
            if (showTrailing) ...[
              AppSpacing.hGapMd,
              const ShimmerLine(width: 60, height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final bool showAvatar;
  final bool showSubtitle;
  final bool showTrailing;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => ShimmerListTile(
          showAvatar: showAvatar,
          showSubtitle: showSubtitle,
          showTrailing: showTrailing,
        ),
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const ShimmerCard(),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final double? lastLineWidth;

  const ShimmerText({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 8,
    this.lastLineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (index) {
          final isLast = index == lines - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
            child: ShimmerLine(
              width: isLast ? lastLineWidth : null,
              height: lineHeight,
            ),
          );
        }),
      ),
    );
  }
}
