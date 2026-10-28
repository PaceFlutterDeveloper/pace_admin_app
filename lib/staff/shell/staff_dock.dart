import 'dart:math' as math;

import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// The five dock destinations. Order matches the Hub design.
enum StaffTab {
  home('Home', StaffGlyphs.home),
  tasks('Tasks', StaffGlyphs.tasks),
  menu('Menu', StaffGlyphs.grid),
  events('Events', StaffGlyphs.events),
  profile('Profile', StaffGlyphs.user);

  const StaffTab(this.label, this.glyph);
  final String label;
  final String glyph;

  String get path => switch (this) {
    StaffTab.home => Routes.home.path,
    StaffTab.tasks => Routes.tasks.path,
    StaffTab.menu => Routes.menu.path,
    StaffTab.events => Routes.events.path,
    StaffTab.profile => Routes.userProfile.path,
  };
}

/// Maps a location to a dock tab, or null for pushed pages that belong to
/// whichever tab the user came from.
StaffTab? staffTabForPath(String path) {
  if (path == Routes.home.path || path == Routes.getNotifications.path) {
    return StaffTab.home;
  }
  if (path == Routes.tasks.path) return StaffTab.tasks;
  if (path == Routes.menu.path || path == Routes.subMenuPage.path) {
    return StaffTab.menu;
  }
  if (path == Routes.events.path) return StaffTab.events;
  // Tickets are opened from the Menu, so the Menu tab stays lit on them.
  if (path.startsWith(Routes.tickets.path) ||
      path.startsWith(Routes.manageTickets.path)) {
    return StaffTab.menu;
  }
  if (path == Routes.userProfile.path) return StaffTab.profile;
  return null;
}

const double kStaffDockBarHeight = 76;
const double kStaffDockFabSize = 58;
const double _fabLift = 8;

/// Height of the dock including the raised Menu button.
const double kStaffDockHeight = kStaffDockBarHeight + _fabLift;

/// Bottom offset of the dock from the screen edge.
double staffDockBottomOffset(BuildContext context) {
  final safe = MediaQuery.paddingOf(context).bottom;
  return math.max(14, safe + 6);
}

/// Vertical space page content should reserve above the dock.
double staffDockBodyInset(BuildContext context) {
  return staffDockBottomOffset(context) + kStaffDockHeight + 10;
}

/// Floating dock with a raised Menu button (Hub structure, Executive colours).
class StaffDock extends StatelessWidget {
  const StaffDock({
    super.key,
    required this.current,
    required this.onSelect,
    this.badges = const {},
  });

  final StaffTab current;
  final ValueChanged<StaffTab> onSelect;

  /// Counts drawn on a tab icon. Zero and missing keys stay hidden.
  final Map<StaffTab, int> badges;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return SizedBox(
      height: kStaffDockHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: kStaffDockBarHeight,
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.border),
                boxShadow: [
                  BoxShadow(
                    color: p.shadow,
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final tab in StaffTab.values)
                    _DockItem(
                      tab: tab,
                      selected: tab == current,
                      badge: badges[tab] ?? 0,
                      onTap: () => onSelect(tab),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 9 + 13 + 4,
            child: Center(
              child: _MenuFab(
                selected: current == StaffTab.menu,
                onTap: () => onSelect(StaffTab.menu),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final StaffTab tab;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final isMenu = tab == StaffTab.menu;
    final color = selected ? p.amberText : p.muted;

    final count = badge > 99 ? '99+' : '$badge';
    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '${tab.label}, $count' : tab.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: kStaffDockBarHeight - 9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isMenu)
                const SizedBox(height: 30)
              else
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      width: 48,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selected ? p.amberSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: StaffIcon(tab.glyph, size: 22, color: color),
                    ),
                    if (badge > 0)
                      Positioned(
                        top: -7,
                        right: -6,
                        child: StaffCountBadge(badge),
                      ),
                  ],
                ),
              const SizedBox(height: 4),
              SizedBox(
                height: 13,
                child: Text(
                  tab.label,
                  maxLines: 1,
                  style: sora(
                    10.5,
                    weight: FontWeight.w600,
                    color: color,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuFab extends StatelessWidget {
  const _MenuFab({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Menu',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            width: kStaffDockFabSize,
            height: kStaffDockFabSize,
            decoration: BoxDecoration(
              gradient: StaffPalette.fabGradient,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: p.background, width: 4),
              boxShadow: [
                BoxShadow(
                  color: StaffPalette.dark.amber.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const StaffIcon(
              StaffGlyphs.grid,
              size: 24,
              color: StaffPalette.onAmberInk,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigates to a dock tab, ignoring a tap on the current one.
void goToStaffTab(BuildContext context, StaffTab tab) {
  HapticFeedback.selectionClick();
  context.go(tab.path);
}
