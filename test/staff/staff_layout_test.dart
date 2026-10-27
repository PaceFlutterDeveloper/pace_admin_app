import 'package:admin_app/staff/home/menu/staff_menu_tile.dart';
import 'package:admin_app/staff/home/widgets/home_sections.dart';
import 'package:admin_app/staff/shell/staff_dock.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final dark in [false, true]) {
    for (final size in const [Size(360, 640), Size(430, 932)]) {
      for (final scale in const [1.0, 1.2]) {
        testWidgets(
          'dock, tiles and stat cards fit: dark=$dark $size scale=$scale',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                ),
                child: MaterialApp(
                  theme: dark ? StaffTheme.dark : StaffTheme.light,
                  home: Scaffold(
                    body: Column(
                      children: [
                        Row(
                          children: [
                            for (var i = 0; i < 3; i++)
                              Expanded(
                                child: QuickStatCard(
                                  glyph: StaffGlyphs.ticket,
                                  accent: StaffAccent.pink,
                                  label: 'Open tickets',
                                  value: '12',
                                  onTap: () {},
                                ),
                              ),
                          ],
                        ),
                        Builder(
                          builder: (context) => GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: staffMenuGridDelegate(context),
                            itemCount: 4,
                            itemBuilder: (_, i) => StaffMenuTile(
                              label: 'Manage tickets',
                              glyph: StaffGlyphs.wrench,
                              accent: StaffAccent.violet,
                              badge: i == 0 ? 3 : 0,
                              soon: i == 3,
                              onTap: () {},
                            ),
                          ),
                        ),
                        const Spacer(),
                        StaffDock(current: StaffTab.home, onSelect: (_) {}),
                      ],
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();

            final e = tester.takeException();
            expect(e, isNull);
          },
        );
      }
    }
  }
}
