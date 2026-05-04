import 'package:flutter/material.dart';

export '../../core/constants/app_colors.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);

  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);

  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double card = 14.0;
  static const double hero = 20.0;
  static const double pill = 100.0;
  /// Outer radius of the floating glass bottom nav pill.
  static const double navBarPill = 32.0;
  static const double circle = 999.0;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(pill));
}

class AppShadows {
  static List<BoxShadow> get none => [];

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
  static List<BoxShadow> get strong => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration page = Duration(milliseconds: 320);
}

/// Curve tokens used by shared widgets (animations).
class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve bounce = Curves.elasticOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
}

/// Size tokens used by shared widgets (touch targets, buttons, avatars).
class AppSizes {
  AppSizes._();

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;

  static const double buttonHeight = 52.0;
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightLg = 56.0;

  static const double inputHeight = 52.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;

  /// Minimum body padding above the floating glass nav (design spec).
  static const double bodyBottomInsetFloatingNav = 96.0;

  static const double touchTarget = 44.0;

  static const double maxContentWidth = 600.0;
  static const double maxCardWidth = 400.0;
}
