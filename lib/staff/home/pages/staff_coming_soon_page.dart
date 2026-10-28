import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Describes a module that has a place in the Hub but no backend yet.
class ComingSoonArgs {
  const ComingSoonArgs({
    required this.title,
    required this.glyph,
    required this.accent,
    this.blurb,
  });

  final String title;
  final String glyph;
  final StaffAccent accent;
  final String? blurb;

  static const tasks = ComingSoonArgs(
    title: 'Tasks',
    glyph: StaffGlyphs.tasks,
    accent: StaffAccent.blue,
    blurb:
        'Assigned work, due dates and quick updates will live here so nothing slips between meetings.',
  );

  static const events = ComingSoonArgs(
    title: 'Events',
    glyph: StaffGlyphs.events,
    accent: StaffAccent.pink,
    blurb:
        'School events, programmes and reminders will be listed here so the whole staff stays in step.',
  );

  static const leave = ComingSoonArgs(
    title: 'Leave',
    glyph: StaffGlyphs.leave,
    accent: StaffAccent.green,
    blurb: 'Apply for leave and follow approvals from your phone.',
  );

  static const settings = ComingSoonArgs(
    title: 'Settings',
    glyph: StaffGlyphs.sliders,
    accent: StaffAccent.violet,
  );

  static const notificationSettings = ComingSoonArgs(
    title: 'Notification settings',
    glyph: StaffGlyphs.bell,
    accent: StaffAccent.amber,
    blurb: 'Choose which alerts reach you and when.',
  );

  static const personalInfo = ComingSoonArgs(
    title: 'Personal information',
    glyph: StaffGlyphs.user,
    accent: StaffAccent.blue,
    blurb: 'Editing your details from the app is coming soon.',
  );
}

/// Polished placeholder for modules that are not available yet.
class StaffComingSoonPage extends StatelessWidget {
  const StaffComingSoonPage({super.key, required this.args});

  final ComingSoonArgs args;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final canPop = Navigator.of(context).canPop();
    final tint = p.tint(args.accent);

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: canPop
                    ? StaffIconButton(
                        glyph: StaffGlyphs.chevronLeft,
                        semanticLabel: 'Back',
                        onTap: () => context.pop(),
                      )
                    : const SizedBox(height: 46),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  tint.background,
                                  tint.background.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          GlassIconTile(
                            glyph: args.glyph,
                            accent: args.accent,
                            size: 92,
                            radius: 32,
                            iconSize: 40,
                            strokeWidth: 1.7,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: p.amberSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: p.amberLine),
                        ),
                        child: Text(
                          'COMING SOON',
                          style: sora(
                            10.5,
                            weight: FontWeight.w800,
                            color: p.amberText,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        args.title,
                        textAlign: TextAlign.center,
                        style: sora(
                          24,
                          weight: FontWeight.w700,
                          color: p.text,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        args.blurb ??
                            'We are still building this for staff. Use the desktop ERP for now. It will appear here as soon as it is ready.',
                        textAlign: TextAlign.center,
                        style: sora(
                          13,
                          weight: FontWeight.w400,
                          color: p.muted,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: AmberButton(
                          label: canPop ? 'Go back' : 'Open Menu',
                          soft: true,
                          glyph: canPop ? null : StaffGlyphs.grid,
                          onPressed: () {
                            if (canPop) {
                              context.pop();
                            } else {
                              context.go(Routes.menu.path);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the coming-soon page for [args] from anywhere inside the shell.
void openComingSoon(BuildContext context, ComingSoonArgs args) {
  context.pushNamed(Routes.comingSoon.name, extra: args);
}
