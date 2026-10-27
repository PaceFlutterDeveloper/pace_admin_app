import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/careers_tokens.dart';

/// Subtle frosted panel for use on top of a gradient surface.
///
/// Only used where a gradient already sits behind it (the profile header and
/// the auth hero). Solid cards remain the default everywhere else.
class CareersGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final double blur;

  const CareersGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = CareersRadius.cardAll,
    this.blur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: padding ?? CareersSpacing.cardInset,
            child: child,
          ),
        ),
      ),
    );
  }
}
