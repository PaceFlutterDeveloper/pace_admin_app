import 'package:flutter/material.dart';

/// Colour palette for the public careers experience.
///
/// Scoped to `lib/careers/**`. The admin side keeps using `AppColors` and
/// `ConstColors`; nothing here is wired into the global theme.
class CareersColors {
  CareersColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDeep = Color(0xFF312E81);
  static const Color primarySoft = Color(0xFFEEF2FF);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondarySoft = Color(0xFFECFEFF);
  static const Color accent = Color(0xFFEC4899);

  static const Color navy = Color(0xFF0F172A);
  static const Color slate = Color(0xFF475569);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEEF2F6);

  static const Color textPrimary = navy;
  static const Color textSecondary = slate;
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);
}

/// Gradients reserved for hero surfaces, primary CTAs and selected states.
/// Deliberately few: solid surfaces remain the default.
class CareersGradients {
  CareersGradients._();

  /// Deep indigo -> indigo -> cyan. Hero bands and auth backgrounds.
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      CareersColors.primaryDeep,
      CareersColors.primary,
      CareersColors.secondary,
    ],
    stops: [0.0, 0.58, 1.0],
  );

  /// Deeper hero ramp used on midnight surfaces so the band still has range.
  static const LinearGradient heroDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF0E7490)],
    stops: [0.0, 0.6, 1.0],
  );

  static LinearGradient heroFor(Brightness brightness) =>
      brightness == Brightness.dark ? heroDark : hero;

  /// Tighter indigo ramp for primary call-to-action surfaces.
  static const LinearGradient cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [CareersColors.primary, Color(0xFF6366F1)],
  );

  /// Low-alpha wash behind empty-state and decorative icons.
  static const LinearGradient accentWash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1A4F46E5), Color(0x14EC4899)],
  );

  /// Vertical navy veil laid over the hero so white text stays legible.
  static const LinearGradient heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x000F172A), Color(0x330F172A)],
  );
}

class CareersRadius {
  CareersRadius._();

  static const double chip = 12.0;
  static const double input = 14.0;
  static const double card = 18.0;
  static const double hero = 24.0;
  static const double pill = 999.0;

  static const BorderRadius chipAll = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroAll = BorderRadius.all(Radius.circular(hero));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Careers layout rhythm. Builds on the existing 8-point `AppSpacing` scale and
/// only adds the values that scale does not cover.
class CareersSpacing {
  CareersSpacing._();

  /// Horizontal gutter for every careers screen.
  static const double screenH = 20.0;

  /// Vertical gap between major sections.
  static const double section = 24.0;

  /// Inner padding of a standard card.
  static const double cardPadding = 16.0;

  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: screenH,
  );

  static const EdgeInsets cardInset = EdgeInsets.all(cardPadding);

  static const SizedBox gap4 = SizedBox(height: 4);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);
  static const SizedBox gap24 = SizedBox(height: 24);
  static const SizedBox gap32 = SizedBox(height: 32);
}

class CareersShadows {
  CareersShadows._();

  static const List<BoxShadow> none = [];

  /// Default resting elevation for cards.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// Floating surfaces: sticky CTA bars, bottom sheets, hero cards.
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x120F172A), blurRadius: 24, offset: Offset(0, 10)),
  ];

  /// Tinted shadow used under glass and gradient surfaces.
  static const List<BoxShadow> glass = [
    BoxShadow(color: Color(0x1F4F46E5), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

/// Foreground / background pair for a status indicator.
class CareersStatusStyle {
  final Color foreground;
  final Color background;

  const CareersStatusStyle(this.foreground, this.background);

  /// The light-mode pair is tuned for white surfaces. On dark surfaces the hue
  /// is kept but the chip becomes a translucent tint with a lifted foreground.
  CareersStatusStyle resolve(Brightness brightness) {
    if (brightness == Brightness.light) return this;
    return CareersStatusStyle(
      Color.lerp(foreground, Colors.white, 0.55)!,
      foreground.withValues(alpha: 0.2),
    );
  }
}

/// Theme-aware surface and text colours for the careers experience.
///
/// Brand colours ([CareersColors.primary], success, error, ...) stay constant;
/// everything that has to flip between light and dark lives here. Read it with
/// `context.careers`.
@immutable
class CareersPalette extends ThemeExtension<CareersPalette> {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color primarySoft;
  final Color secondarySoft;

  /// Brand accent for text, icons and outlines. [CareersColors.primary] is
  /// too dark to read on the midnight surfaces, so dark mode lifts it.
  final Color accentText;

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> elevatedShadow;
  final List<BoxShadow> glassShadow;

  const CareersPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primarySoft,
    required this.secondarySoft,
    required this.accentText,
    required this.cardShadow,
    required this.elevatedShadow,
    required this.glassShadow,
  });

  bool get isDark => brightness == Brightness.dark;

  static const CareersPalette light = CareersPalette(
    brightness: Brightness.light,
    background: CareersColors.background,
    surface: CareersColors.surface,
    surfaceMuted: CareersColors.surfaceMuted,
    border: CareersColors.border,
    divider: CareersColors.divider,
    textPrimary: CareersColors.textPrimary,
    textSecondary: CareersColors.textSecondary,
    textTertiary: CareersColors.textTertiary,
    primarySoft: CareersColors.primarySoft,
    secondarySoft: CareersColors.secondarySoft,
    accentText: CareersColors.primary,
    cardShadow: CareersShadows.card,
    elevatedShadow: CareersShadows.elevated,
    glassShadow: CareersShadows.glass,
  );

  /// Midnight palette shared with the auth screens.
  static const CareersPalette dark = CareersPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0A0D29),
    surface: Color(0xFF14173A),
    surfaceMuted: Color(0xFF1D2050),
    border: Color(0x1FFFFFFF),
    divider: Color(0x14FFFFFF),
    textPrimary: Color(0xFFF4F5FB),
    textSecondary: Color(0xB0FFFFFF),
    textTertiary: Color(0x75FFFFFF),
    primarySoft: Color(0x384F46E5),
    secondarySoft: Color(0x2606B6D4),
    accentText: Color(0xFFA5B4FC),
    cardShadow: [
      BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8)),
    ],
    elevatedShadow: [
      BoxShadow(
        color: Color(0x4D000000),
        blurRadius: 28,
        offset: Offset(0, 12),
      ),
    ],
    glassShadow: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );

  CareersStatusStyle status(CareersStatusStyle style) =>
      style.resolve(brightness);

  @override
  CareersPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? primarySoft,
    Color? secondarySoft,
    Color? accentText,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? elevatedShadow,
    List<BoxShadow>? glassShadow,
  }) {
    return CareersPalette(
      brightness: brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      primarySoft: primarySoft ?? this.primarySoft,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      accentText: accentText ?? this.accentText,
      cardShadow: cardShadow ?? this.cardShadow,
      elevatedShadow: elevatedShadow ?? this.elevatedShadow,
      glassShadow: glassShadow ?? this.glassShadow,
    );
  }

  @override
  CareersPalette lerp(CareersPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return CareersPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      border: c(border, other.border),
      divider: c(divider, other.divider),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      primarySoft: c(primarySoft, other.primarySoft),
      secondarySoft: c(secondarySoft, other.secondarySoft),
      accentText: c(accentText, other.accentText),
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      elevatedShadow: BoxShadow.lerpList(
        elevatedShadow,
        other.elevatedShadow,
        t,
      )!,
      glassShadow: BoxShadow.lerpList(glassShadow, other.glassShadow, t)!,
    );
  }
}

extension CareersPaletteContext on BuildContext {
  /// Careers palette for the current theme; falls back to light outside the
  /// careers subtree (e.g. in isolated widget tests).
  CareersPalette get careers =>
      Theme.of(this).extension<CareersPalette>() ?? CareersPalette.light;
}

/// Single source of truth for status colours across job cards, application
/// cards and filter chips.
///
/// Keys match the existing `ApplicationStatus` enum names, so status semantics
/// are unchanged — only the palette is.
class CareersStatusColors {
  CareersStatusColors._();

  static const CareersStatusStyle _neutral = CareersStatusStyle(
    CareersColors.slate,
    Color(0xFFF1F5F9),
  );

  static const Map<String, CareersStatusStyle> _application = {
    'applied': CareersStatusStyle(Color(0xFF1D4ED8), Color(0xFFDBEAFE)),
    'reviewed': CareersStatusStyle(Color(0xFF6D28D9), Color(0xFFEDE9FE)),
    'shortlisted': CareersStatusStyle(Color(0xFF0E7490), Color(0xFFCFFAFE)),
    'interviewed': CareersStatusStyle(Color(0xFFB45309), Color(0xFFFEF3C7)),
    'accepted': CareersStatusStyle(Color(0xFF047857), Color(0xFFD1FAE5)),
    'rejected': CareersStatusStyle(Color(0xFFB91C1C), Color(0xFFFEE2E2)),
  };

  /// Resolves an application status. [key] accepts an enum name or the
  /// human-readable label; unknown values fall back to a neutral grey.
  static CareersStatusStyle application(String key) {
    return _application[key.trim().toLowerCase()] ?? _neutral;
  }

  /// Resolves a job vacancy status (open / closed / filled / on hold).
  static CareersStatusStyle job(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'open':
      case 'active':
      case 'published':
        return const CareersStatusStyle(Color(0xFF047857), Color(0xFFD1FAE5));
      case 'closed':
      case 'expired':
        return const CareersStatusStyle(Color(0xFFB91C1C), Color(0xFFFEE2E2));
      case 'filled':
        return const CareersStatusStyle(Color(0xFF1D4ED8), Color(0xFFDBEAFE));
      case 'on hold':
      case 'hold':
      case 'paused':
        return const CareersStatusStyle(Color(0xFFB45309), Color(0xFFFEF3C7));
      default:
        return _neutral;
    }
  }
}
