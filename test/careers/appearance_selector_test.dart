import 'dart:io';

import 'package:admin_app/careers/shared/theme/careers_theme.dart';
import 'package:admin_app/careers/shared/theme/careers_theme_controller.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/careers/user/components/appearance_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('careers_theme_test');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  Future<void> pumpButton(
    WidgetTester tester,
    CareersThemeController controller,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: CareersThemeScope(
          controller: controller,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [AppearanceAppBarButton(controller: controller)],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'tapping Dark then Light on the segmented control updates theme',
    (tester) async {
      final controller = CareersThemeController();
      await pumpButton(tester, controller);
      expect(controller.value, ThemeMode.system);

      expect(find.text('Light'), findsNothing);
      expect(find.text('Dark'), findsNothing);

      await tester.tap(find.byTooltip('Dark'));
      await tester.pumpAndSettle();

      expect(controller.value, ThemeMode.dark);
      expect(
        tester.element(find.byType(AppearanceAppBarButton)).careers.isDark,
        isTrue,
      );

      await tester.tap(find.byTooltip('Light'));
      await tester.pumpAndSettle();
      expect(controller.value, ThemeMode.light);
      expect(
        tester.element(find.byType(AppearanceAppBarButton)).careers.isDark,
        isFalse,
      );
    },
  );

  testWidgets('system mode stays stored and follows resolved brightness', (
    tester,
  ) async {
    final controller = CareersThemeController();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await pumpButton(tester, controller);

    expect(controller.value, ThemeMode.system);
    expect(
      tester.element(find.byType(AppearanceAppBarButton)).careers.isDark,
      isTrue,
    );
  });

  test('choice is persisted and restored from Hive', () async {
    final box = await Hive.openBox<dynamic>('settingsBox');
    CareersThemeController(box: box).setMode(ThemeMode.dark);

    expect(CareersThemeController(box: box).value, ThemeMode.dark);
  });
}
