import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Light / dark appearance for the staff experience.
///
/// Persisted in the shared Hive `settingsBox` under its own key. Careers has
/// a separate controller and is not affected.
class StaffThemeController extends ValueNotifier<ThemeMode> {
  static const storageKey = 'staffThemeMode';

  final Box<dynamic>? _box;

  StaffThemeController({Box<dynamic>? box}) : _box = box, super(_read(box));

  static StaffThemeController? _fallback;

  /// The app-wide controller, or an in-memory one when the locator has not
  /// been set up (widget tests).
  static StaffThemeController get instance {
    if (locator.isRegistered<StaffThemeController>()) {
      return locator<StaffThemeController>();
    }
    return _fallback ??= StaffThemeController();
  }

  /// Light is the default; only an explicit dark choice switches it.
  static ThemeMode _read(Box<dynamic>? box) {
    final raw = box?.get(storageKey);
    return raw == ThemeMode.dark.name ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => value == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    final next = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
    if (value == next) return;
    value = next;
    _box?.put(storageKey, next.name);
  }
}
