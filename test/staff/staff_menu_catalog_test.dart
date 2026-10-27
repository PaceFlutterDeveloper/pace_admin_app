import 'package:admin_app/staff/home/menu/staff_menu_catalog.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
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
