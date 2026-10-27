import 'package:flutter/material.dart';

/// Accent families used by glass icon tiles (Hub design, "Glass" board).
enum StaffAccent {
  amber(Color(0xFFF5B544)),
  blue(Color(0xFF60A5FA)),
  green(Color(0xFF34D399)),
  pink(Color(0xFFF472B6)),
  violet(Color(0xFFA78BFA));

  const StaffAccent(this.base);
  final Color base;
}

/// Tinted tile colours resolved for the current brightness.
class StaffTint {
  const StaffTint({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

/// Colour tokens for the staff "Executive" theme (ink black + amber).
///
/// Dark values come straight from the Hub mockup. Light values are the
/// matching daylight set: same amber accent, paper surfaces.
@immutable
class StaffPalette extends ThemeExtension<StaffPalette> {
  const StaffPalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.muted,
    required this.amber,
    required this.amberText,
    required this.onAmber,
    required this.danger,
    required this.dangerText,
    required this.scrim,
    required this.shadow,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color muted;

  /// Fill amber (buttons, dock FAB, dots).
  final Color amber;

  /// Amber used as text/icon on [background] or [surface]; deeper in light mode.
  final Color amberText;
  final Color onAmber;
  final Color danger;
  final Color dangerText;
  final Color scrim;
  final Color shadow;

  Color get amberSoft => amber.withValues(alpha: 0.16);
  Color get amberLine => amber.withValues(alpha: 0.40);

  /// Title and caption colours for hero cards: ink hero in dark, plain text in light.
  Color get heroTitle => isDark ? heroText : text;
  Color get heroSubtle => isDark ? heroMuted : muted;

  static const StaffPalette dark = StaffPalette(
    isDark: true,
    background: Color(0xFF0E1116),
    surface: Color(0xFF171B23),
    surfaceRaised: Color(0xFF222A38),
    border: Color(0xFF2A3140),
    borderStrong: Color(0xFF2F384A),
    text: Color(0xFFF2F4F8),
    muted: Color(0xFFA9B2C3),
    amber: Color(0xFFF5B544),
    amberText: Color(0xFFF5B544),
    onAmber: Color(0xFF1A1200),
    danger: Color(0xFFF87171),
    dangerText: Color(0xFFFCA5A5),
    scrim: Color(0x9E000000),
    shadow: Color(0x8C000000),
  );

  static const StaffPalette light = StaffPalette(
    isDark: false,
    background: Color(0xFFF3F4F8),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFEDEFF5),
    border: Color(0xFFE3E6EE),
    borderStrong: Color(0xFFD6DAE4),
    text: Color(0xFF14161C),
    muted: Color(0xFF5B6478),
    amber: Color(0xFFF5B544),
    amberText: Color(0xFFB7700A),
    onAmber: Color(0xFF1A1200),
    danger: Color(0xFFDC2626),
    dangerText: Color(0xFFB91C1C),
    scrim: Color(0x73000000),
    shadow: Color(0x1F141C2E),
  );

  // Ink hero colours, used in dark mode. Light mode swaps to the palette text.
  static const Color heroText = Color(0xFFF2F4F8);
  static const Color heroMuted = Color(0xFFA9B2C3);
  static const Color heroBorder = Color(0xFF2F384A);
  static const Color onAmberInk = Color(0xFF1A1200);
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [Color(0xFF232B3A), Color(0xFF171B23)],
  );
  static const RadialGradient heroGlow = RadialGradient(
    center: Alignment(1, -1),
    radius: 1.1,
    colors: [Color(0x3DF5B544), Color(0x00F5B544)],
    stops: [0, 0.6],
  );
  static const LinearGradient fabGradient = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: [Color(0xFFFBC866), Color(0xFFE9962B)],
  );

  /// Glass tile colours: 20% accent fill, lifted icon on dark, deepened on light.
  StaffTint tint(StaffAccent accent) {
    final base = accent.base;
    final fg = isDark
        ? Color.lerp(base, Colors.white, 0.2)!
        : Color.lerp(base, Colors.black, 0.32)!;
    return StaffTint(
      background: base.withValues(alpha: isDark ? 0.20 : 0.18),
      foreground: fg,
    );
  }

  static StaffPalette of(BuildContext context) {
    return Theme.of(context).extension<StaffPalette>() ?? dark;
  }

  @override
  StaffPalette copyWith({
    bool? isDark,
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? muted,
    Color? amber,
    Color? amberText,
    Color? onAmber,
    Color? danger,
    Color? dangerText,
    Color? scrim,
    Color? shadow,
  }) {
    return StaffPalette(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      amber: amber ?? this.amber,
      amberText: amberText ?? this.amberText,
      onAmber: onAmber ?? this.onAmber,
      danger: danger ?? this.danger,
      dangerText: dangerText ?? this.dangerText,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  StaffPalette lerp(ThemeExtension<StaffPalette>? other, double t) {
    if (other is! StaffPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return StaffPalette(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      text: l(text, other.text),
      muted: l(muted, other.muted),
      amber: l(amber, other.amber),
      amberText: l(amberText, other.amberText),
      onAmber: l(onAmber, other.onAmber),
      danger: l(danger, other.danger),
      dangerText: l(dangerText, other.dangerText),
      scrim: l(scrim, other.scrim),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension StaffPaletteContext on BuildContext {
  StaffPalette get staff => StaffPalette.of(this);
}
