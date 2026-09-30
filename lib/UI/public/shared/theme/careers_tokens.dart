import 'package:flutter/material.dart';

/// Colour palette for the public careers experience.
///
/// Scoped to `lib/UI/public/**`. The admin side keeps using `AppColors` and
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

  static const EdgeInsets screenHorizontal =
      EdgeInsets.symmetric(horizontal: screenH);

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
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Floating surfaces: sticky CTA bars, bottom sheets, hero cards.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  /// Tinted shadow used under glass and gradient surfaces.
  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x1F4F46E5),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}

/// Foreground / background pair for a status indicator.
class CareersStatusStyle {
  final Color foreground;
  final Color background;

  const CareersStatusStyle(this.foreground, this.background);
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
