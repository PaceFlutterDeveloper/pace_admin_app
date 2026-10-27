import 'package:admin_app/config/themes/app_theme.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme_controller.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sora text style used across the staff Hub design.
TextStyle sora(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.sora(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// Theme for the staff Hub (Executive colours). Applied as a scoped [Theme]
/// over the staff subtree only; careers keeps its own theme.
class StaffTheme {
  StaffTheme._();

  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData get light => _light ??= _build(StaffPalette.light);
  static ThemeData get dark => _dark ??= _build(StaffPalette.dark);

  static Widget wrap(Widget child) => StaffThemeScope(child: child);

  static ThemeData _build(StaffPalette p) {
    final brightness = p.isDark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.amber,
      onPrimary: p.onAmber,
      primaryContainer: p.amberSoft,
      onPrimaryContainer: p.amberText,
      secondary: p.amberText,
      onSecondary: p.onAmber,
      error: p.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.muted,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.background,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceRaised,
      surfaceContainerHighest: p.surfaceRaised,
      outline: p.borderStrong,
      outlineVariant: p.border,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final base = GoogleFonts.soraTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: p.text, displayColor: p.text);

    final textTheme = base.copyWith(
      headlineLarge: sora(
        28,
        weight: FontWeight.w700,
        color: p.text,
        letterSpacing: -0.8,
      ),
      headlineMedium: sora(
        22,
        weight: FontWeight.w700,
        color: p.text,
        letterSpacing: -0.5,
      ),
      headlineSmall: sora(
        18,
        weight: FontWeight.w700,
        color: p.text,
        letterSpacing: -0.3,
      ),
      titleLarge: sora(
        16,
        weight: FontWeight.w700,
        color: p.text,
        letterSpacing: -0.2,
      ),
      titleMedium: sora(14.5, weight: FontWeight.w600, color: p.text),
      titleSmall: sora(13, weight: FontWeight.w600, color: p.text),
      bodyLarge: sora(
        14.5,
        weight: FontWeight.w400,
        color: p.text,
        height: 1.45,
      ),
      bodyMedium: sora(
        13.5,
        weight: FontWeight.w400,
        color: p.text,
        height: 1.45,
      ),
      bodySmall: sora(12, weight: FontWeight.w400, color: p.muted, height: 1.4),
      labelLarge: sora(14, weight: FontWeight.w600, color: p.text),
      labelMedium: sora(12, weight: FontWeight.w600, color: p.muted),
      labelSmall: sora(
        11,
        weight: FontWeight.w700,
        color: p.muted,
        letterSpacing: 1.0,
      ),
    );

    OutlineInputBorder outline(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      cardColor: p.surface,
      dividerColor: p.border,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: p.text),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.amberText,
        selectionColor: p.amber.withValues(alpha: 0.3),
        selectionHandleColor: p.amberText,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: p.background,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: p.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: sora(17, weight: FontWeight.w700, color: p.text),
        iconTheme: IconThemeData(color: p.text, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: p.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: outline(p.border),
        enabledBorder: outline(p.border),
        focusedBorder: outline(p.amberText, 1.5),
        errorBorder: outline(p.danger),
        focusedErrorBorder: outline(p.danger, 1.5),
        hintStyle: sora(13.5, weight: FontWeight.w400, color: p.muted),
        labelStyle: sora(13.5, weight: FontWeight.w500, color: p.muted),
        errorStyle: sora(12, weight: FontWeight.w500, color: p.dangerText),
        prefixIconColor: p.muted,
        suffixIconColor: p.muted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.amber,
          foregroundColor: p.onAmber,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: sora(14.5, weight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.amber,
          foregroundColor: p.onAmber,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: sora(14.5, weight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: p.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: sora(14, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.amberText,
          textStyle: sora(13, weight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceRaised,
        selectedColor: p.amber,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: sora(12, weight: FontWeight.w600, color: p.text),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(iconColor: p.muted, textColor: p.text),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: p.border),
        ),
        titleTextStyle: sora(18, weight: FontWeight.w700, color: p.text),
        contentTextStyle: sora(
          13.5,
          weight: FontWeight.w400,
          color: p.muted,
          height: 1.5,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.amberText,
        linearTrackColor: p.surfaceRaised,
        circularTrackColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onAmber : p.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.amber : p.surfaceRaised,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.amberText,
        unselectedLabelColor: p.muted,
        indicatorColor: p.amber,
        dividerColor: Colors.transparent,
        labelStyle: sora(13, weight: FontWeight.w700),
        unselectedLabelStyle: sora(13, weight: FontWeight.w600),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceRaised,
        contentTextStyle: sora(13, color: p.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          cardShadow: const [],
          elevatedShadow: const [],
          strongShadow: const [],
        ),
      ],
    );
  }
}

/// Applies the light or dark staff theme to its subtree, following
/// [StaffThemeController].
class StaffThemeScope extends StatelessWidget {
  const StaffThemeScope({super.key, required this.child, this.controller});

  final Widget child;
  final StaffThemeController? controller;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? StaffThemeController.instance;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return AnimatedTheme(
          data: isDark ? StaffTheme.dark : StaffTheme.light,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: child,
          ),
        );
      },
    );
  }
}
