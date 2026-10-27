import 'package:admin_app/careers/shared/theme/careers_theme_controller.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact iOS-style Light / Dark segmented control for the profile app bar.
///
/// Visible options are Light and Dark only. [ThemeMode.system] stays stored
/// until the user taps a segment; the highlighted side follows resolved
/// brightness.
class AppearanceAppBarButton extends StatelessWidget {
  final CareersThemeController? controller;

  const AppearanceAppBarButton({super.key, this.controller});

  static const _width = 84.0;
  static const _height = 36.0;
  static const _inset = 3.0;
  static const _animation = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? CareersThemeController.instance;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller,
      builder: (context, _, _) {
        final palette = context.careers;
        final isDark = palette.isDark;
        final primary = Theme.of(context).colorScheme.primary;

        return Center(
          child: Semantics(
            label: 'Appearance',
            child: SizedBox(
              width: _width,
              height: _height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: CareersRadius.pillAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_inset),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final thumbWidth = constraints.maxWidth / 2;
                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: _animation,
                            curve: Curves.easeOutCubic,
                            top: 0,
                            bottom: 0,
                            left: isDark ? thumbWidth : 0,
                            width: thumbWidth,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: CareersRadius.pillAll,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _Segment(
                                  label: 'Light',
                                  selected: !isDark,
                                  icon: CupertinoIcons.sun_max,
                                  onTap: () =>
                                      _select(controller, ThemeMode.light),
                                ),
                              ),
                              Expanded(
                                child: _Segment(
                                  label: 'Dark',
                                  selected: isDark,
                                  icon: CupertinoIcons.moon,
                                  onTap: () =>
                                      _select(controller, ThemeMode.dark),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _select(CareersThemeController controller, ThemeMode mode) {
    if (controller.value == mode) return;
    HapticFeedback.selectionClick();
    controller.setMode(mode);
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.careers;
    final color = selected ? CareersColors.onPrimary : palette.textSecondary;

    return Tooltip(
      message: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(child: Icon(icon, size: 17, color: color)),
      ),
    );
  }
}
