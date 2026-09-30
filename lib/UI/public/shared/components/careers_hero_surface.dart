import 'package:flutter/material.dart';

import '../theme/careers_tokens.dart';

/// Gradient hero surface for the home greeting band and auth backgrounds.
///
/// Deliberately scarce: gradients are reserved for hero areas and primary
/// CTAs, everything else uses solid surfaces.
class CareersHeroSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Corner rounding. Pass [BorderRadius.zero] for a full-bleed background.
  final BorderRadius borderRadius;

  /// Renders the soft decorative circles behind the content.
  final bool showDecoration;

  final bool showShadow;

  const CareersHeroSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = CareersRadius.heroAll,
    this.showDecoration = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: CareersGradients.hero,
        borderRadius: borderRadius,
        boxShadow: showShadow ? CareersShadows.glass : CareersShadows.none,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            if (showDecoration) ...const [
              Positioned(
                top: -70,
                right: -50,
                child: _Glow(size: 190, color: Color(0x33EC4899)),
              ),
              Positioned(
                bottom: -90,
                left: -60,
                child: _Glow(size: 210, color: Color(0x2E06B6D4)),
              ),
            ],
            Padding(
              padding: padding ?? const EdgeInsets.all(CareersSpacing.section),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withAlpha(0)]),
        ),
      ),
    );
  }
}
