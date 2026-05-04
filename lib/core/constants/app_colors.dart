import 'package:flutter/material.dart';

/// Design system colors for PACE Admin. Extended palette below supports
/// existing screens until everything uses theme-aware accessors.
class AppColors {
  AppColors._();

  // — — — Step 1: canonical names — — —
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6C6C70);
  static const Color textTertiary = Color(0xFFAEAEB2);

  static const Color pageBg = Color(0xFFF2F2F7);
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0x0F000000); // black ~6%

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF3949AB);
  static const Color teal = Color(0xFF00838F);
  static const Color purple = Color(0xFF7B1FA2);

  // — — — Extended (legacy / iOS-style) — — —

  static const Color iosSystemGray = Color(0xFF8E8E93);
  static const Color iosSystemGray2 = Color(0xFFAEAEB2);
  static const Color iosSystemGray3 = Color(0xFFC7C7CC);
  static const Color iosSystemGray4 = Color(0xFFD1D1D6);
  static const Color iosSystemGray5 = Color(0xFFE5E5EA);
  static const Color iosSystemGray6 = Color(0xFFF2F2F7);

  static const Color iosSystemGrayDark = Color(0xFF8E8E93);
  static const Color iosSystemGray2Dark = Color(0xFF636366);
  static const Color iosSystemGray3Dark = Color(0xFF48484A);
  static const Color iosSystemGray4Dark = Color(0xFF3A3A3C);
  static const Color iosSystemGray5Dark = Color(0xFF2C2C2E);
  static const Color iosSystemGray6Dark = Color(0xFF1C1C1E);

  static const Color iosRed = Color(0xFFFF3B30);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosYellow = Color(0xFFFFCC00);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosTeal = Color(0xFF5AC8FA);
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosPink = Color(0xFFFF2D55);

  static const Color iosRedDark = Color(0xFFFF453A);
  static const Color iosOrangeDark = Color(0xFFFF9F0A);
  static const Color iosYellowDark = Color(0xFFFFD60A);
  static const Color iosGreenDark = Color(0xFF30D158);
  static const Color iosTealDark = Color(0xFF64D2FF);
  static const Color iosBlueDark = Color(0xFF0A84FF);
  static const Color iosPurpleDark = Color(0xFFBF5AF2);
  static const Color iosPinkDark = Color(0xFFFF375F);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF5F5F7);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color surfaceBorderLight = Color(0x14000000);

  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF6C6C70);
  static const Color textTertiaryLight = Color(0xFFAEAEB2);

  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceContainerDark = Color(0xFF1C1C1E);
  static const Color surfaceElevatedDark = Color(0xFF2C2C2E);
  static const Color surfaceBorderDark = Color(0x14FFFFFF);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textTertiaryDark = Color(0xFF636366);

  static const Color surfaceLight = surfaceContainerLight;
  static const Color surfaceDark = surfaceContainerDark;
  static const Color cardLight = surfaceElevatedLight;
  static const Color cardDark = surfaceElevatedDark;
  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color dividerDark = Color(0xFF38383A);
}

/// Theme-aware color accessor.
class AppSemanticColors {
  final BuildContext _context;

  AppSemanticColors._(this._context);

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;

  Color get background => _isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surfaceContainer =>
      _isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight;
  Color get surfaceElevated =>
      _isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevatedLight;
  Color get card => _isDark ? AppColors.cardDark : AppColors.cardLight;

  Color get border => _isDark ? AppColors.surfaceBorderDark : AppColors.surfaceBorderLight;
  Color get divider => _isDark ? AppColors.dividerDark : AppColors.dividerLight;

  Color get textPrimary => _isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      _isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary => _isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  Color get systemGray => AppColors.iosSystemGray;
  Color get systemGray2 =>
      _isDark ? AppColors.iosSystemGray2Dark : AppColors.iosSystemGray2;
  Color get systemGray3 =>
      _isDark ? AppColors.iosSystemGray3Dark : AppColors.iosSystemGray3;
  Color get systemGray4 =>
      _isDark ? AppColors.iosSystemGray4Dark : AppColors.iosSystemGray4;
  Color get systemGray5 =>
      _isDark ? AppColors.iosSystemGray5Dark : AppColors.iosSystemGray5;
  Color get systemGray6 =>
      _isDark ? AppColors.iosSystemGray6Dark : AppColors.iosSystemGray6;

  Color get red => _isDark ? AppColors.iosRedDark : AppColors.iosRed;
  Color get orange => _isDark ? AppColors.iosOrangeDark : AppColors.iosOrange;
  Color get yellow => _isDark ? AppColors.iosYellowDark : AppColors.iosYellow;
  Color get green => _isDark ? AppColors.iosGreenDark : AppColors.iosGreen;
  Color get teal => _isDark ? AppColors.iosTealDark : AppColors.iosTeal;
  Color get blue => _isDark ? AppColors.iosBlueDark : AppColors.iosBlue;
  Color get purple => _isDark ? AppColors.iosPurpleDark : AppColors.iosPurple;
  Color get pink => _isDark ? AppColors.iosPinkDark : AppColors.iosPink;

  Color get success => green;
  Color get warning => orange;
  Color get error => red;
  Color get info => blue;

  Color get primary => Theme.of(_context).colorScheme.primary;
  Color get onPrimary => Theme.of(_context).colorScheme.onPrimary;

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

extension AppColorsExtension on BuildContext {
  AppSemanticColors get appColors => AppSemanticColors._(this);
}
