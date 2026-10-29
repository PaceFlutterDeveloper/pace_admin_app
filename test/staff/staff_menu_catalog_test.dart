import 'package:admin_app/staff/home/menu/staff_menu_catalog.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter_test/flutter_test.dart';

MenuModel _menu(
  String name, {
  String? page,
  int badge = 0,
  List<MenuModel> subMenu = const [],
}) => MenuModel(
  id: name,
  menuKey: name,
  menuVal: name,
  menuName: name,
  page: page,
  iconUrl: '',
  parentId: '0',
  badge: badge,
  subMenu: subMenu,
);

List<StaffMenuEntry> _all(List<StaffMenuGroup> groups) => [
  for (final group in groups) ...group.items,
];

void main() {
  test('parses integer ids and nests items under the API title', () {
    final model = MenuModel.fromMap({
      'id': 1,
      'menu_key': '1',
      'menu_val': 'My Profile',
      'menu_name': 'My Profile',
      'page': '',
      'icon_url': 'https://example.com/a.png',
      'parent_id': 0,
      'pos': 1,
      'badge': 0,
      'sub_menu': [
        {
          'id': 8,
          'menu_key': '8',
          'menu_val': 'Notifications',
          'menu_name': 'Notifications',
          'page': 'getNotifications',
          'icon_url': '',
          'parent_id': 1,
          'pos': 1,
          'badge': 0,
          'sub_menu': [],
        },
        {
          'id': 9,
          'menu_key': '9',
          'menu_val': 'Tickets',
          'menu_name': 'Tickets',
          'page': 'tickets',
          'icon_url': '',
          'parent_id': 1,
          'pos': 2,
          'badge': 1,
          'sub_menu': [],
        },
      ],
    });

    expect(model.parentId, '0');
    expect(model.subMenu.first.parentId, '1');

    final menu = buildStaffMenu([
      model,
      _menu('Events', page: 'events'),
    ]);

    expect(menu.first.title, 'My Profile');
    expect(menu.first.items.map((e) => e.label), [
      'Notifications',
      'Tickets',
    ]);
    expect(menu.first.items.last.menu?.badge, 1);
    expect(menu.last.title, isEmpty);
    expect(menu.last.items.single.label, 'Events');
    expect(menu.last.items.single.isSoon, isFalse);
  });

  test('unknown page still appears and is marked soon', () {
    final menu = buildStaffMenu([
      _menu('Zebra Module', page: 'zebra'),
    ]);
    final entry = menu.single.items.single;
    expect(entry.label, 'Zebra Module');
    expect(entry.isSoon, isTrue);
    expect(entry.menu?.page, 'zebra');
    expect(menu.single.title, isEmpty);
  });

  test('name keywords style items with an unknown page', () {
    final style = staffMenuStyleFor(_menu('Fee collection', page: null));
    expect(style.section, StaffMenuSection.management);
    expect(style.glyph, isNotEmpty);
  });

  test('menu contains only what the API returned', () {
    expect(_all(buildStaffMenu([])), isEmpty);
  });

  test('shows every page the API returned', () {
    final menu = buildStaffMenu([
      _menu(
        'My Profile',
        subMenu: [
          _menu('Mark attendance', page: 'faceAttendance'),
          _menu('Attendance', page: 'userAttendance'),
        ],
      ),
    ]);
    final pages = _all(menu).map((e) => e.menu?.page);
    expect(pages, containsAll(['faceAttendance', 'userAttendance']));
    expect(menu.single.title, 'My Profile');
  });

  test('a page this build cannot open is soon, under its API title', () {
    final menu = buildStaffMenu([
      _menu(
        'My Profile',
        subMenu: [
          _menu('Profile', page: 'userProfile'),
          _menu('Leave', page: 'leave'),
          _menu('Fees', page: 'fees'),
        ],
      ),
    ]);
    final myProfile = menu.single;
    expect(myProfile.title, 'My Profile');
    expect(myProfile.items.firstWhere((e) => e.label == 'Fees').isSoon, isTrue);
    // Leave has a screen now, so it opens instead of showing Coming soon.
    expect(
      myProfile.items.firstWhere((e) => e.label == 'Leave').isSoon,
      isFalse,
    );
    expect(
      myProfile.items.firstWhere((e) => e.label == 'Profile').isSoon,
      isFalse,
    );
  });

  test('search filters by label and drops empty sections', () {
    final menu = buildStaffMenu([
      _menu(
        'My Profile',
        subMenu: [_menu('Profile', page: 'userProfile')],
      ),
      _menu('Events', page: 'events'),
    ], query: 'event');
    expect(menu.single.title, isEmpty);
    expect(menu.single.items.single.label, 'Events');
  });

  test('internal web without a native page is listed and is not soon', () {
    final item = MenuModel.fromMap({
      'id': 4,
      'menu_key': 'internalWeb',
      'menu_val': 'Activity Fee',
      'menu_name': 'Activity Fee',
      'page': '',
      'icon_url': 'https://example.com/fee.png',
      'url': 'https://example.com/fee',
      'parent_id': 0,
      'sub_menu': [],
    });

    expect(item.isInternalWeb, isTrue);
    expect(item.webUrl, 'https://example.com/fee');
    expect(item.networkIconUrl, 'https://example.com/fee.png');

    final entry = buildStaffMenu([item]).single.items.single;
    expect(entry.label, 'Activity Fee');
    expect(entry.isSoon, isFalse);
    expect(entry.iconUrl, 'https://example.com/fee.png');
    // Do not invent a local glyph from the name — icon comes from the API.
    expect(entry.style.glyph, StaffGlyphs.globe);
  });

  test('internal web prefers url and falls back to web_url', () {
    final preferred = MenuModel.fromMap({
      'menu_key': 'internal_web',
      'menu_val': 'A',
      'menu_name': 'A',
      'url': 'https://example.com/one',
      'web_url': 'https://example.com/two',
    });
    final fallback = MenuModel.fromMap({
      'menu_key': 'internal web',
      'menu_val': 'B',
      'menu_name': 'B',
      'web_url': 'https://example.com/two',
    });

    expect(preferred.webUrl, 'https://example.com/one');
    expect(preferred.isInternalWeb, isTrue);
    expect(fallback.webUrl, 'https://example.com/two');
    expect(fallback.isInternalWeb, isTrue);
  });

  test('internal web with no url is hidden, even with an unknown page', () {
    final hidden = MenuModel.fromMap({
      'menu_key': 'internalWeb',
      'menu_val': 'Missing',
      'menu_name': 'Missing',
      'page': 'not-a-route',
    });
    expect(buildStaffMenu([hidden]), isEmpty);
    expect(menuOpensSoon(hidden), isFalse);
  });

  test('internal web inside a group stays openable', () {
    final menu = buildStaffMenu([
      _menu(
        'School',
        subMenu: [
          MenuModel.fromMap({
            'menu_key': 'internalWeb',
            'menu_val': 'Consent',
            'menu_name': 'Consent',
            'page': 'temporary-consent',
            'icon_url': '',
            'url': 'https://example.com/consent',
          }),
        ],
      ),
    ]);

    final entry = menu.single.items.single;
    expect(menu.single.title, 'School');
    expect(entry.label, 'Consent');
    expect(entry.isSoon, isFalse);
  });

  test('search can match a section title', () {
    final menu = buildStaffMenu([
      _menu(
        'My Profile',
        subMenu: [
          _menu('Profile', page: 'userProfile'),
          _menu('Leave', page: 'leave'),
        ],
      ),
    ], query: 'my pro');
    expect(menu.single.items.map((e) => e.label), ['Profile', 'Leave']);
  });
}
