import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/pages/staff_coming_soon_page.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter/widgets.dart';

enum StaffMenuSection {
  myWork('MY WORK'),
  school('SCHOOL'),
  management('MANAGEMENT'),
  more('MORE');

  const StaffMenuSection(this.title);
  final String title;
}

/// Look of one module tile.
class StaffMenuStyle {
  const StaffMenuStyle({
    required this.section,
    required this.glyph,
    required this.accent,
  });

  final StaffMenuSection section;
  final String glyph;
  final StaffAccent accent;
}

/// One tile on the Menu screen: either a real API module or a "Soon" tile.
class StaffMenuEntry {
  const StaffMenuEntry({
    required this.label,
    required this.style,
    this.menu,
    this.soon,
  });

  final String label;
  final StaffMenuStyle style;

  /// API menu item. Null for coming-soon tiles.
  final MenuModel? menu;

  /// Set for coming-soon tiles.
  final ComingSoonArgs? soon;

  bool get isSoon => soon != null || (menu != null && menuOpensSoon(menu!));

  /// Route name used for the badge lookup (tickets count and similar).
  String? get page => menu?.page;

  /// Network icon for an internal-web tile. Null for every other module.
  String? get iconUrl => menu?.networkIconUrl;
}

/// One titled block on the Menu screen. [title] is the parent `menu_name`.
class StaffMenuGroup {
  const StaffMenuGroup({required this.title, required this.items});

  final String title;
  final List<StaffMenuEntry> items;
}

/// Route page names the staff app can open, with their Hub styling.
const Map<String, StaffMenuStyle> _pageStyles = {
  'userAttendance': StaffMenuStyle(
    section: StaffMenuSection.myWork,
    glyph: StaffGlyphs.cal,
    accent: StaffAccent.amber,
  ),
  'tickets': StaffMenuStyle(
    section: StaffMenuSection.myWork,
    glyph: StaffGlyphs.ticket,
    accent: StaffAccent.pink,
  ),
  'classAttendance': StaffMenuStyle(
    section: StaffMenuSection.school,
    glyph: StaffGlyphs.users,
    accent: StaffAccent.blue,
  ),
  'students': StaffMenuStyle(
    section: StaffMenuSection.school,
    glyph: StaffGlyphs.users,
    accent: StaffAccent.blue,
  ),
  'nfcMapping': StaffMenuStyle(
    section: StaffMenuSection.school,
    glyph: StaffGlyphs.bus,
    accent: StaffAccent.green,
  ),
  'manageTickets': StaffMenuStyle(
    section: StaffMenuSection.management,
    glyph: StaffGlyphs.wrench,
    accent: StaffAccent.violet,
  ),
  'userProfile': StaffMenuStyle(
    section: StaffMenuSection.more,
    glyph: StaffGlyphs.user,
    accent: StaffAccent.blue,
  ),
  'getNotifications': StaffMenuStyle(
    section: StaffMenuSection.more,
    glyph: StaffGlyphs.bell,
    accent: StaffAccent.amber,
  ),
  'notificationSettings': StaffMenuStyle(
    section: StaffMenuSection.more,
    glyph: StaffGlyphs.bell,
    accent: StaffAccent.amber,
  ),
  'events': StaffMenuStyle(
    section: StaffMenuSection.school,
    glyph: StaffGlyphs.events,
    accent: StaffAccent.pink,
  ),
  'leave': StaffMenuStyle(
    section: StaffMenuSection.myWork,
    glyph: StaffGlyphs.leave,
    accent: StaffAccent.green,
  ),
  'tasks': StaffMenuStyle(
    section: StaffMenuSection.myWork,
    glyph: StaffGlyphs.tasks,
    accent: StaffAccent.blue,
  ),
  'timetable': StaffMenuStyle(
    section: StaffMenuSection.school,
    glyph: StaffGlyphs.clock,
    accent: StaffAccent.violet,
  ),
  'circulars': StaffMenuStyle(
    section: StaffMenuSection.school,
    glyph: StaffGlyphs.mega,
    accent: StaffAccent.amber,
  ),
  'notices': StaffMenuStyle(
    section: StaffMenuSection.school,
    glyph: StaffGlyphs.mega,
    accent: StaffAccent.amber,
  ),
  'approvals': StaffMenuStyle(
    section: StaffMenuSection.management,
    glyph: StaffGlyphs.check,
    accent: StaffAccent.amber,
  ),
  'staff': StaffMenuStyle(
    section: StaffMenuSection.management,
    glyph: StaffGlyphs.users,
    accent: StaffAccent.blue,
  ),
  'reports': StaffMenuStyle(
    section: StaffMenuSection.management,
    glyph: StaffGlyphs.chart,
    accent: StaffAccent.violet,
  ),
};

/// Name hints for API items whose `page` is unknown or empty.
const List<(String, StaffMenuStyle)> _keywordStyles = [
  (
    'attend',
    StaffMenuStyle(
      section: StaffMenuSection.myWork,
      glyph: StaffGlyphs.cal,
      accent: StaffAccent.amber,
    ),
  ),
  (
    'leave',
    StaffMenuStyle(
      section: StaffMenuSection.myWork,
      glyph: StaffGlyphs.leave,
      accent: StaffAccent.green,
    ),
  ),
  (
    'ticket',
    StaffMenuStyle(
      section: StaffMenuSection.myWork,
      glyph: StaffGlyphs.ticket,
      accent: StaffAccent.pink,
    ),
  ),
  (
    'task',
    StaffMenuStyle(
      section: StaffMenuSection.myWork,
      glyph: StaffGlyphs.tasks,
      accent: StaffAccent.blue,
    ),
  ),
  (
    'student',
    StaffMenuStyle(
      section: StaffMenuSection.school,
      glyph: StaffGlyphs.users,
      accent: StaffAccent.blue,
    ),
  ),
  (
    'class',
    StaffMenuStyle(
      section: StaffMenuSection.school,
      glyph: StaffGlyphs.users,
      accent: StaffAccent.blue,
    ),
  ),
  (
    'timetable',
    StaffMenuStyle(
      section: StaffMenuSection.school,
      glyph: StaffGlyphs.clock,
      accent: StaffAccent.violet,
    ),
  ),
  (
    'transport',
    StaffMenuStyle(
      section: StaffMenuSection.school,
      glyph: StaffGlyphs.bus,
      accent: StaffAccent.green,
    ),
  ),
  (
    'bus',
    StaffMenuStyle(
      section: StaffMenuSection.school,
      glyph: StaffGlyphs.bus,
      accent: StaffAccent.green,
    ),
  ),
  (
    'circular',
    StaffMenuStyle(
      section: StaffMenuSection.school,
      glyph: StaffGlyphs.mega,
      accent: StaffAccent.amber,
    ),
  ),
  (
    'notice',
    StaffMenuStyle(
      section: StaffMenuSection.school,
      glyph: StaffGlyphs.mega,
      accent: StaffAccent.amber,
    ),
  ),
  (
    'approv',
    StaffMenuStyle(
      section: StaffMenuSection.management,
      glyph: StaffGlyphs.check,
      accent: StaffAccent.amber,
    ),
  ),
  (
    'report',
    StaffMenuStyle(
      section: StaffMenuSection.management,
      glyph: StaffGlyphs.chart,
      accent: StaffAccent.violet,
    ),
  ),
  (
    'fee',
    StaffMenuStyle(
      section: StaffMenuSection.management,
      glyph: StaffGlyphs.wallet,
      accent: StaffAccent.green,
    ),
  ),
  (
    'staff',
    StaffMenuStyle(
      section: StaffMenuSection.management,
      glyph: StaffGlyphs.user,
      accent: StaffAccent.blue,
    ),
  ),
  (
    'document',
    StaffMenuStyle(
      section: StaffMenuSection.more,
      glyph: StaffGlyphs.doc,
      accent: StaffAccent.blue,
    ),
  ),
  (
    'inventory',
    StaffMenuStyle(
      section: StaffMenuSection.more,
      glyph: StaffGlyphs.box,
      accent: StaffAccent.amber,
    ),
  ),
  (
    'calendar',
    StaffMenuStyle(
      section: StaffMenuSection.more,
      glyph: StaffGlyphs.cal,
      accent: StaffAccent.pink,
    ),
  ),
  (
    'setting',
    StaffMenuStyle(
      section: StaffMenuSection.more,
      glyph: StaffGlyphs.sliders,
      accent: StaffAccent.violet,
    ),
  ),
];

const StaffMenuStyle _fallbackStyle = StaffMenuStyle(
  section: StaffMenuSection.more,
  glyph: StaffGlyphs.grid,
  accent: StaffAccent.violet,
);

/// Fallback only — the tile draws [MenuModel.networkIconUrl] from the API.
const StaffMenuStyle _internalWebStyle = StaffMenuStyle(
  section: StaffMenuSection.more,
  glyph: StaffGlyphs.globe,
  accent: StaffAccent.violet,
);

/// Resolves the Hub style for an API menu item. Unknown items land in MORE
/// with a default tile so a new module from the API never disappears.
///
/// Internal-web modules keep a globe fallback; their real icon is `icon_url`.
StaffMenuStyle staffMenuStyleFor(MenuModel item) {
  if (item.isInternalWeb) return _internalWebStyle;
  final page = item.page;
  if (page != null && _pageStyles.containsKey(page)) return _pageStyles[page]!;
  final name = item.menuName.toLowerCase();
  for (final (keyword, style) in _keywordStyles) {
    if (name.contains(keyword)) return style;
  }
  return _fallbackStyle;
}

String _label(MenuModel item) {
  final name = item.menuName.trim();
  if (name.isNotEmpty) return name;
  return item.menuVal.trim();
}

List<MenuModel> _visible(List<MenuModel> items) {
  return [
    for (final item in items)
      if (_hasPageOrChildren(item)) item,
  ];
}

bool _hasPageOrChildren(MenuModel item) {
  if (item.subMenu.isNotEmpty) return true;
  if (item.isInternalWeb) return item.webUrl?.trim().isNotEmpty ?? false;
  return item.page?.trim().isNotEmpty ?? false;
}

StaffMenuEntry _entry(MenuModel item) {
  final style = staffMenuStyleFor(item);
  return StaffMenuEntry(
    label: _label(item),
    style: style,
    menu: item,
    soon: menuOpensSoon(item) ? _soonFor(item) : null,
  );
}

ComingSoonArgs _soonFor(MenuModel item) {
  switch (item.page) {
    case 'leave':
      return ComingSoonArgs.leave;
    case 'settings':
      return ComingSoonArgs.settings;
    case 'notificationSettings':
      return ComingSoonArgs.notificationSettings;
    case 'tasks':
      return ComingSoonArgs.tasks;
    case 'events':
      return ComingSoonArgs.events;
    default:
      final style = staffMenuStyleFor(item);
      return ComingSoonArgs(
        title: _label(item),
        glyph: style.glyph,
        accent: style.accent,
      );
  }
}

/// Opens an API menu row. Pages this build cannot open yet show Coming soon.
void openStaffMenu(BuildContext context, MenuModel item) {
  if (item.isInternalWeb) {
    final url = item.webUrl?.trim() ?? '';
    if (url.isEmpty) return;
    openInternalWeb(context, item);
    return;
  }
  if (menuOpensSoon(item)) {
    openComingSoon(context, _soonFor(item));
    return;
  }
  openMenuItem(context, item);
}

/// Groups the role menu the way `userMenu` sends it.
///
/// A row with children is a section titled by that row's name. A top-level
/// row with a page is a module of its own. [query] filters by title or label.
List<StaffMenuGroup> buildStaffMenu(
  List<MenuModel> apiMenus, {
  String query = '',
}) {
  final groups = <StaffMenuGroup>[];
  final loose = <StaffMenuEntry>[];

  void flushLoose() {
    if (loose.isEmpty) return;
    groups.add(StaffMenuGroup(title: '', items: [...loose]));
    loose.clear();
  }

  for (final item in _visible(apiMenus)) {
    final children = _visible(item.subMenu);
    if (children.isNotEmpty) {
      flushLoose();
      groups.add(
        StaffMenuGroup(
          title: _label(item),
          items: [for (final child in children) _entry(child)],
        ),
      );
    } else {
      final page = item.page?.trim() ?? '';
      if (page.isNotEmpty || item.isInternalWeb) loose.add(_entry(item));
    }
  }
  flushLoose();

  final q = query.trim().toLowerCase();
  if (q.isEmpty) return groups;

  return [
    for (final group in groups)
      if (_matching(group, q) case final matched?) matched,
  ];
}

StaffMenuGroup? _matching(StaffMenuGroup group, String query) {
  final titleHit = group.title.toLowerCase().contains(query);
  final items = titleHit
      ? group.items
      : group.items
            .where((entry) => entry.label.toLowerCase().contains(query))
            .toList();
  if (items.isEmpty) return null;
  return StaffMenuGroup(title: group.title, items: items);
}
