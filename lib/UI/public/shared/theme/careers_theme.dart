import 'package:admin_app/config/themes/app_theme.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static ThemeData? _cached;

  static ThemeData get light => _cached ??= _build();

  /// Wraps [child] in the careers theme.
  static Widget wrap(Widget child) => Theme(data: light, child: child);

  static ThemeData _build() {
    final base = ColorScheme.fromSeed(
      seedColor: CareersColors.primary,
      brightness: Brightness.light,
    );

    final colorScheme = base.copyWith(
      primary: CareersColors.primary,
      onPrimary: CareersColors.onPrimary,
      primaryContainer: CareersColors.primarySoft,
      onPrimaryContainer: CareersColors.primaryDeep,
      secondary: CareersColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: CareersColors.secondarySoft,
      tertiary: CareersColors.accent,
      onTertiary: Colors.white,
      surface: CareersColors.surface,
      onSurface: CareersColors.textPrimary,
      onSurfaceVariant: CareersColors.textSecondary,
      surfaceContainerLowest: CareersColors.surface,
      surfaceContainerLow: CareersColors.background,
      surfaceContainer: CareersColors.surfaceMuted,
      surfaceContainerHigh: CareersColors.surfaceMuted,
      error: CareersColors.error,
      onError: Colors.white,
      outline: CareersColors.border,
      outlineVariant: CareersColors.divider,
    );

    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CareersColors.background,
      canvasColor: CareersColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: CareersColors.divider,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: CareersColors.surface,
        foregroundColor: CareersColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: CareersColors.textPrimary,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(
          color: CareersColors.textPrimary,
          size: 22,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: CareersColors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: CareersRadius.cardAll),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CareersColors.surfaceMuted,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CareersSpacing.cardPadding,
          vertical: 15,
        ),
        border: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.primary, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.error, width: 1.4),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.error, width: 1.6),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: CareersRadius.inputAll,
          borderSide: BorderSide(color: CareersColors.divider),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: CareersColors.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CareersColors.primary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: CareersColors.textTertiary,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: CareersColors.error,
        ),
        prefixIconColor: CareersColors.textTertiary,
        suffixIconColor: CareersColors.textTertiary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CareersColors.primary,
          foregroundColor: CareersColors.onPrimary,
          disabledBackgroundColor: CareersColors.border,
          disabledForegroundColor: CareersColors.textTertiary,
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
          foregroundColor: CareersColors.primary,
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: CareersColors.primary, width: 1.4),
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
          foregroundColor: CareersColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CareersColors.surfaceMuted,
        selectedColor: CareersColors.primarySoft,
        side: const BorderSide(color: CareersColors.border),
        shape: const RoundedRectangleBorder(
          borderRadius: CareersRadius.chipAll,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: CareersColors.textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: CareersColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CareersColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CareersRadius.hero),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CareersColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: CareersRadius.heroAll,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CareersColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: CareersColors.textSecondary,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CareersColors.primary,
        linearTrackColor: CareersColors.surfaceMuted,
        circularTrackColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: CareersColors.surface,
        selectedItemColor: CareersColors.primary,
        unselectedItemColor: CareersColors.textTertiary,
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
        labelColor: CareersColors.primary,
        unselectedLabelColor: CareersColors.textSecondary,
        indicatorColor: CareersColors.primary,
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
      extensions: const [
        AppThemeExtension(
          cardShadow: CareersShadows.card,
          elevatedShadow: CareersShadows.elevated,
          strongShadow: CareersShadows.glass,
        ),
      ],
    );
  }

  static TextTheme _textTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: CareersColors.textPrimary,
      ),
      // Screen title.
      headlineLarge: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.25,
        color: CareersColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: CareersColors.textPrimary,
      ),
      // Section title.
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: CareersColors.textPrimary,
      ),
      // Card title.
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: CareersColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: CareersColors.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: CareersColors.textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: CareersColors.textPrimary,
      ),
      // Body.
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: CareersColors.textSecondary,
      ),
      // Secondary.
      bodySmall: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: CareersColors.textTertiary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: CareersColors.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: CareersColors.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: CareersColors.textSecondary,
      ),
    );
  }
}
