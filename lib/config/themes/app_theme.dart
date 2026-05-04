import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_design_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(Color primaryColor) =>
      _buildTheme(primaryColor, Brightness.light);

  static ThemeData dark(Color primaryColor) =>
      _buildTheme(primaryColor, Brightness.dark);

  static ThemeData _buildTheme(Color primaryColor, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );

    // Apple HIG Surface Colors
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight;
    final cardColor = isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevatedLight;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    // Apple HIG Text Colors
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textTertiary = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    // Adaptive semantic colors
    final errorColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;

    // Adaptive grays
    final systemGray = AppColors.iosSystemGray;
    final systemGray4 = isDark ? AppColors.iosSystemGray4Dark : AppColors.iosSystemGray4;
    final systemGray5 = isDark ? AppColors.iosSystemGray5Dark : AppColors.iosSystemGray5;
    final systemGray6 = isDark ? AppColors.iosSystemGray6Dark : AppColors.iosSystemGray6;

    final textTheme = _buildTextTheme(colorScheme, textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: surfaceColor,

      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.1),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 22,
        ),
        actionsIconTheme: IconThemeData(
          color: primaryColor,
          size: 22,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: systemGray6,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          color: textTertiary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: errorColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: systemGray,
        suffixIconColor: systemGray,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: systemGray4,
          disabledForegroundColor: systemGray,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          elevation: 0,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSm,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSm,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: systemGray,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: primaryColor.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: systemGray,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor, size: 24);
          }
          return IconThemeData(color: systemGray, size: 24);
        }),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: systemGray,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: primaryColor,
            width: 2.5,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(3),
          ),
        ),
        dividerColor: Colors.transparent,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: systemGray6,
        selectedColor: primaryColor.withOpacity(0.15),
        disabledColor: systemGray5,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusPill,
        ),
        side: BorderSide.none,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXl,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withOpacity(0.8),
          height: 1.5,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        modalBackgroundColor: cardColor,
        modalElevation: 8,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceElevatedDark : const Color(0xFF323232),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
      ),

      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 0,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minVerticalPadding: AppSpacing.sm,
        horizontalTitleGap: AppSpacing.md,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        leadingAndTrailingTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return systemGray4;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(
          color: isDark ? AppColors.iosSystemGray3Dark : AppColors.iosSystemGray3,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return isDark ? AppColors.iosSystemGray3Dark : AppColors.iosSystemGray3;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: systemGray4,
        thumbColor: Colors.white,
        overlayColor: primaryColor.withOpacity(0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: systemGray5,
        circularTrackColor: systemGray5,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedLight : const Color(0xFF323232),
          borderRadius: AppRadius.borderRadiusSm,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: systemGray6,
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderRadiusMd,
            borderSide: BorderSide.none,
          ),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cardColor),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMd,
            ),
          ),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.white,
        dayStyle: GoogleFonts.inter(fontSize: 14),
        weekdayStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: systemGray,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXl,
        ),
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: cardColor,
        hourMinuteTextStyle: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        dayPeriodTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXl,
        ),
      ),

      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(systemGray6),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textTertiary,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),

      badgeTheme: BadgeThemeData(
        backgroundColor: errorColor,
        textColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      splashFactory: InkSparkle.splashFactory,

      extensions: [
        AppThemeExtension(
          cardShadow: isDark ? AppShadows.none : AppShadows.soft,
          elevatedShadow: isDark ? AppShadows.none : AppShadows.medium,
          strongShadow: isDark ? AppShadows.none : AppShadows.strong,
        ),
      ],
    );
  }

  static TextTheme _buildTextTheme(
    ColorScheme colorScheme,
    Color textPrimary,
    Color textSecondary,
  ) {
    final baseColor = textPrimary;
    final secondaryColor = textSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.3,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.35,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.4,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        height: 1.45,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.4,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.35,
        color: secondaryColor,
      ),
    );
  }
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> elevatedShadow;
  final List<BoxShadow> strongShadow;

  const AppThemeExtension({
    required this.cardShadow,
    required this.elevatedShadow,
    required this.strongShadow,
  });

  @override
  AppThemeExtension copyWith({
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? elevatedShadow,
    List<BoxShadow>? strongShadow,
  }) {
    return AppThemeExtension(
      cardShadow: cardShadow ?? this.cardShadow,
      elevatedShadow: elevatedShadow ?? this.elevatedShadow,
      strongShadow: strongShadow ?? this.strongShadow,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t) ?? cardShadow,
      elevatedShadow: BoxShadow.lerpList(elevatedShadow, other.elevatedShadow, t) ?? elevatedShadow,
      strongShadow: BoxShadow.lerpList(strongShadow, other.strongShadow, t) ?? strongShadow,
    );
  }

  static AppThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>()!;
  }
}
