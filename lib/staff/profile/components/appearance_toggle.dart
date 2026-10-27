import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/theme/staff_theme_controller.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact Light / Dark switch bound to [StaffThemeController].
class AppearanceToggle extends StatelessWidget {
  const AppearanceToggle({super.key, this.controller});

  final StaffThemeController? controller;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? StaffThemeController.instance;
    final p = context.staff;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller,
      builder: (context, mode, _) {
        final dark = mode == ThemeMode.dark;
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: p.surfaceRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Segment(
                label: 'Light',
                glyph: StaffGlyphs.sun,
                selected: !dark,
                onTap: () => _set(controller, ThemeMode.light),
              ),
              _Segment(
                label: 'Dark',
                glyph: StaffGlyphs.moon,
                selected: dark,
                onTap: () => _set(controller, ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );
  }

  void _set(StaffThemeController c, ThemeMode mode) {
    HapticFeedback.selectionClick();
    c.setMode(mode);
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.glyph,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String glyph;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final fg = selected ? p.onAmber : p.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label theme',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: selected ? p.amber : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StaffIcon(glyph, size: 15, color: fg, strokeWidth: 2),
              const SizedBox(width: 5),
              Text(
                label,
                style: sora(11.5, weight: FontWeight.w700, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
