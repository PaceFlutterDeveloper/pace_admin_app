import 'dart:io';

import 'package:admin_app/staff/theme/staff_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory dir;
  late Box<dynamic> box;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('staff_theme_test');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('settings_test');
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('defaults to light', () {
    expect(StaffThemeController(box: box).value, ThemeMode.light);
  });

  test('dark choice is persisted and restored', () {
    StaffThemeController(box: box).setMode(ThemeMode.dark);
    expect(box.get(StaffThemeController.storageKey), 'dark');
    expect(StaffThemeController(box: box).value, ThemeMode.dark);
  });

  test('system mode collapses to light and notifies once per change', () {
    final c = StaffThemeController(box: box);
    var calls = 0;
    c.addListener(() => calls++);
    c.setMode(ThemeMode.dark);
    c.setMode(ThemeMode.dark);
    c.setMode(ThemeMode.system);
    expect(c.value, ThemeMode.light);
    expect(calls, 2);
  });

  test('works without a box', () {
    final c = StaffThemeController();
    c.setMode(ThemeMode.dark);
    expect(c.isDark, isTrue);
  });
}
