import 'package:admin_app/config/themes/app_theme.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'careers_theme_controller.dart';
import 'careers_tokens.dart';

/// Theme for the public careers experience.
///
/// Applied as a scoped [Theme] over the careers subtree only. The global
/// `AppTheme` and every admin screen are untouched. Because the shared widgets
/// in `lib/core/widgets/` resolve their colours from `Theme.of(context)`
/// (`AppButton` reads `colorScheme.primary`, `AppCard` reads
/// `AppThemeExtension`), wrapping the subtree restyles them automatically.
class CareersTheme {
  CareersTheme._();

  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData get light => _light ??= _build(CareersPalette.light);
  static ThemeData get dark => _dark ??= _build(CareersPalette.dark);

  /// Wraps [child] in the careers theme, following the user's appearance
  /// choice.
  static Widget wrap(Widget child) => CareersThemeScope(child: child);

  static ThemeData _build(CareersPalette p) {
    final isDark = p.isDark;
    final base = ColorScheme.fromSeed(
      seedColor: CareersColors.primary,
      brightness: p.brightness,
    );

    // Filled controls keep the brand indigo in both modes; only foreground
    // accents are lifted for contrast on dark surfaces.
    final primary = isDark ? const Color(0xFF6366F1) : CareersColors.primary;

    final colorScheme = base.copyWith(
      primary: primary,
      onPrimary: CareersColors.onPrimary,
      primaryContainer: p.primarySoft,
      onPrimaryContainer: isDark ? p.accentText : CareersColors.primaryDeep,
      secondary: CareersColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: p.secondarySoft,
      tertiary: CareersColors.accent,
      onTertiary: Colors.white,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.background,
      surfaceContainer: p.surfaceMuted,
      surfaceContainerHigh: p.surfaceMuted,
      surfaceContainerHighest: p.surfaceMuted,
      error: CareersColors.error,
      onError: Colors.white,
      outline: p.border,
      outlineVariant: p.divider,
    );

    final textTheme = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      cardColor: p.surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: p.divider,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: p.textSecondary),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accentText,
        selectionColor: p.accentText.withValues(alpha: 0.3),
        selectionHandleColor: p.accentText,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: p.surface,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: p.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: CareersRadius.cardAll,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceMuted,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CareersSpacing.cardPadding,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: p.accentText, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.error, width: 1.4),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.error, width: 1.6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: p.divider),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: p.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.accentText,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: p.textTertiary,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: CareersColors.error,
        ),
        prefixIconColor: p.textTertiary,
        suffixIconColor: p.textTertiary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: CareersColors.onPrimary,
          disabledBackgroundColor: p.border,
          disabledForegroundColor: p.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: CareersRadius.inputAll,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.accentText,
          minimumSize: const Size(0, 52),
          side: BorderSide(color: p.accentText, width: 1.4),
          shape: const RoundedRectangleBorder(
            borderRadius: CareersRadius.inputAll,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accentText,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceMuted,
        selectedColor: p.primarySoft,
        side: BorderSide(color: p.border),
        shape: const RoundedRectangleBorder(
          borderRadius: CareersRadius.chipAll,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: p.textSecondary,
        ),
      ),
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CareersRadius.hero),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: CareersRadius.heroAll,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: p.textSecondary,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: p.textTertiary, width: 1.4),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accentText,
        linearTrackColor: p.surfaceMuted,
        circularTrackColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: p.surface,
        selectedItemColor: p.accentText,
        unselectedItemColor: p.textTertiary,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.accentText,
        unselectedLabelColor: p.textSecondary,
        indicatorColor: p.accentText,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [
        p,
        AppThemeExtension(
          cardShadow: p.cardShadow,
          elevatedShadow: p.elevatedShadow,
          strongShadow: p.glassShadow,
        ),
      ],
    );
  }

  static TextTheme _textTheme(CareersPalette p) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: p.textPrimary,
      ),
      // Screen title.
      headlineLarge: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.25,
        color: p.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: p.textPrimary,
      ),
      // Section title.
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: p.textPrimary,
      ),
      // Card title.
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: p.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: p.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: p.textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: p.textPrimary,
      ),
      // Body.
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: p.textSecondary,
      ),
      // Secondary.
      bodySmall: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: p.textTertiary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: p.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: p.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: p.textSecondary,
      ),
    );
  }
}

/// Applies the light or dark careers theme to its subtree, following
/// [CareersThemeController] and, in system mode, the device brightness.
class CareersThemeScope extends StatelessWidget {
  final Widget child;
  final CareersThemeController? controller;

  const CareersThemeScope({super.key, required this.child, this.controller});

  static Brightness brightnessFor(ThemeMode mode, BuildContext context) {
    return switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? CareersThemeController.instance;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller,
      builder: (context, mode, _) {
        final isDark = brightnessFor(mode, context) == Brightness.dark;
        return AnimatedTheme(
          data: isDark ? CareersTheme.dark : CareersTheme.light,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: child,
        );
      },
    );
  }
}
