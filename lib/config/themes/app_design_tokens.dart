import 'package:flutter/material.dart';

/// Design tokens for the PACE Admin App.
/// Every spacing, radius, shadow, and duration value used across the app
/// must reference this file. Never use hardcoded magic numbers in widgets.

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

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
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
  static const double circle = 999.0;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(pill));
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
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

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 32,
          offset: const Offset(0, 12),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> softDark(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? none : soft;
  }
}

class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration page = Duration(milliseconds: 320);
  static const Duration stagger = Duration(milliseconds: 50);
}

class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve bounce = Curves.elasticOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
}

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

  static const double touchTarget = 44.0;

  static const double maxContentWidth = 600.0;
  static const double maxCardWidth = 400.0;
}

class AppColors {
  AppColors._();

  // iOS System Gray Scale (Light Mode)
  static const Color iosSystemGray = Color(0xFF8E8E93);
  static const Color iosSystemGray2 = Color(0xFFAEAEB2);
  static const Color iosSystemGray3 = Color(0xFFC7C7CC);
  static const Color iosSystemGray4 = Color(0xFFD1D1D6);
  static const Color iosSystemGray5 = Color(0xFFE5E5EA);
  static const Color iosSystemGray6 = Color(0xFFF2F2F7);

  // iOS System Gray Scale (Dark Mode)
  static const Color iosSystemGrayDark = Color(0xFF8E8E93);
  static const Color iosSystemGray2Dark = Color(0xFF636366);
  static const Color iosSystemGray3Dark = Color(0xFF48484A);
  static const Color iosSystemGray4Dark = Color(0xFF3A3A3C);
  static const Color iosSystemGray5Dark = Color(0xFF2C2C2E);
  static const Color iosSystemGray6Dark = Color(0xFF1C1C1E);

  // iOS Semantic Colors
  static const Color iosRed = Color(0xFFFF3B30);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosYellow = Color(0xFFFFCC00);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosTeal = Color(0xFF5AC8FA);
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosPink = Color(0xFFFF2D55);

  // iOS Semantic Colors (Dark variants - more vibrant for dark backgrounds)
  static const Color iosRedDark = Color(0xFFFF453A);
  static const Color iosOrangeDark = Color(0xFFFF9F0A);
  static const Color iosYellowDark = Color(0xFFFFD60A);
  static const Color iosGreenDark = Color(0xFF30D158);
  static const Color iosTealDark = Color(0xFF64D2FF);
  static const Color iosBlueDark = Color(0xFF0A84FF);
  static const Color iosPurpleDark = Color(0xFFBF5AF2);
  static const Color iosPinkDark = Color(0xFFFF375F);

  // Light Mode Surfaces (Apple HIG)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF5F5F7);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color surfaceBorderLight = Color(0x14000000); // rgba(0,0,0,0.08)

  // Light Mode Text (Apple HIG Labels)
  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF6C6C70);
  static const Color textTertiaryLight = Color(0xFFAEAEB2);

  // Dark Mode Surfaces (Apple HIG)
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceContainerDark = Color(0xFF1C1C1E);
  static const Color surfaceElevatedDark = Color(0xFF2C2C2E);
  static const Color surfaceBorderDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // Dark Mode Text (Apple HIG Labels)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textTertiaryDark = Color(0xFF636366);

  // Legacy aliases (for backward compatibility)
  static const Color surfaceLight = surfaceContainerLight;
  static const Color surfaceDark = surfaceContainerDark;
  static const Color cardLight = surfaceElevatedLight;
  static const Color cardDark = surfaceElevatedDark;
  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color dividerDark = Color(0xFF38383A);

  // Semantic color helpers
  static Color success([double opacity = 1.0]) => iosGreen.withOpacity(opacity);
  static Color warning([double opacity = 1.0]) => iosOrange.withOpacity(opacity);
  static Color error([double opacity = 1.0]) => iosRed.withOpacity(opacity);
  static Color info([double opacity = 1.0]) => iosBlue.withOpacity(opacity);
}

/// Theme-aware color accessor.
/// Use this extension to get colors that automatically adapt to light/dark mode.
///
/// Usage:
/// ```dart
/// final colors = context.appColors;
/// Container(color: colors.background);
/// Text('Hello', style: TextStyle(color: colors.textPrimary));
/// ```
class AppSemanticColors {
  final BuildContext _context;

  AppSemanticColors._(this._context);

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;

  // Backgrounds
  Color get background => _isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surfaceContainer => _isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight;
  Color get surfaceElevated => _isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevatedLight;
  Color get card => _isDark ? AppColors.cardDark : AppColors.cardLight;

  // Borders & Dividers
  Color get border => _isDark ? AppColors.surfaceBorderDark : AppColors.surfaceBorderLight;
  Color get divider => _isDark ? AppColors.dividerDark : AppColors.dividerLight;

  // Text
  Color get textPrimary => _isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => _isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary => _isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  // System Grays (adaptive)
  Color get systemGray => AppColors.iosSystemGray;
  Color get systemGray2 => _isDark ? AppColors.iosSystemGray2Dark : AppColors.iosSystemGray2;
  Color get systemGray3 => _isDark ? AppColors.iosSystemGray3Dark : AppColors.iosSystemGray3;
  Color get systemGray4 => _isDark ? AppColors.iosSystemGray4Dark : AppColors.iosSystemGray4;
  Color get systemGray5 => _isDark ? AppColors.iosSystemGray5Dark : AppColors.iosSystemGray5;
  Color get systemGray6 => _isDark ? AppColors.iosSystemGray6Dark : AppColors.iosSystemGray6;

  // Semantic Colors (adaptive for better contrast)
  Color get red => _isDark ? AppColors.iosRedDark : AppColors.iosRed;
  Color get orange => _isDark ? AppColors.iosOrangeDark : AppColors.iosOrange;
  Color get yellow => _isDark ? AppColors.iosYellowDark : AppColors.iosYellow;
  Color get green => _isDark ? AppColors.iosGreenDark : AppColors.iosGreen;
  Color get teal => _isDark ? AppColors.iosTealDark : AppColors.iosTeal;
  Color get blue => _isDark ? AppColors.iosBlueDark : AppColors.iosBlue;
  Color get purple => _isDark ? AppColors.iosPurpleDark : AppColors.iosPurple;
  Color get pink => _isDark ? AppColors.iosPinkDark : AppColors.iosPink;

  // Status Colors
  Color get success => green;
  Color get warning => orange;
  Color get error => red;
  Color get info => blue;

  // Primary from theme
  Color get primary => Theme.of(_context).colorScheme.primary;
  Color get onPrimary => Theme.of(_context).colorScheme.onPrimary;

  // Fill colors for interactive elements
  Color get fillPrimary => _isDark
      ? const Color(0xFF787880).withOpacity(0.36)
      : const Color(0xFF787880).withOpacity(0.2);
  Color get fillSecondary => _isDark
      ? const Color(0xFF787880).withOpacity(0.32)
      : const Color(0xFF787880).withOpacity(0.16);
  Color get fillTertiary => _isDark
      ? const Color(0xFF767680).withOpacity(0.24)
      : const Color(0xFF767680).withOpacity(0.12);
}

/// Extension to easily access semantic colors from BuildContext.
extension AppColorsExtension on BuildContext {
  AppSemanticColors get appColors => AppSemanticColors._(this);
}
