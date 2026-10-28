import 'package:admin_app/staff/shell/staff_dock.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('dock tab follows the route, null for pushed pages', () {
    expect(staffTabForPath('/menu'), StaffTab.menu);
    expect(staffTabForPath('/tasks'), StaffTab.tasks);
    expect(staffTabForPath('/events'), StaffTab.events);
    expect(
      staffTabForPath('/tickets'),
      StaffTab.menu,
      reason: 'tickets live in the Menu',
    );
    expect(staffTabForPath('/manageTickets'), StaffTab.menu);
    expect(staffTabForPath('/updatePassword'), isNull);
    expect(StaffTab.values.length, 5);
    expect(StaffTab.menu.index, 2, reason: 'raised Menu button is centred');
  });

  testWidgets('profile double tap and long press stay off the other tabs', (
    tester,
  ) async {
    var taps = 0;
    var doubles = 0;
    var holds = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: StaffTheme.light,
        home: Scaffold(
          body: StaffDock(
            current: StaffTab.home,
            onSelect: (_) => taps++,
            onProfileDoubleTap: () => doubles++,
            onProfileLongPress: () => holds++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(taps, 1);

    await tester.tap(find.text('Profile'));
    await tester.pump(kDoubleTapTimeout);
    expect(taps, 2);
    expect(doubles, 0);

    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Profile'));
    await tester.pump(kDoubleTapTimeout);
    expect(doubles, 1);
    expect(taps, 2);

    await tester.longPress(find.text('Profile'));
    await tester.pump();
    expect(holds, 1);
    expect(taps, 2);

    await tester.longPress(find.text('Home'));
    await tester.pump();
    expect(holds, 1);
  });
}
