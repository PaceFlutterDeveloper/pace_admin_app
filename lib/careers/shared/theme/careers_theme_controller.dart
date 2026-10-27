import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Light / dark / system appearance for the careers experience.
///
/// Persisted in the shared Hive `settingsBox`. The staff app keeps its own
/// theme and is not affected.
class CareersThemeController extends ValueNotifier<ThemeMode> {
  static const _storageKey = 'careersThemeMode';

  final Box<dynamic>? _box;

  CareersThemeController({Box<dynamic>? box}) : _box = box, super(_read(box));

  static CareersThemeController? _fallback;

  /// The app-wide controller, or an in-memory one when the locator has not
  /// been set up (widget tests).
  static CareersThemeController get instance {
    if (locator.isRegistered<CareersThemeController>()) {
      return locator<CareersThemeController>();
    }
    return _fallback ??= CareersThemeController();
  }

  static ThemeMode _read(Box<dynamic>? box) {
    final raw = box?.get(_storageKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  void setMode(ThemeMode mode) {
    if (value == mode) return;
    value = mode;
    _box?.put(_storageKey, mode.name);
  }
}
