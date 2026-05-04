import 'package:admin_app/UI/home/models/menu_model.dart';

/// Preview-only menu roots merged on the home grid in debug builds.
///
/// Items use real [MenuModel.page] route names so taps navigate like production.
List<MenuModel> kDebugDummyHomeMenu() {
  return [
    MenuModel(
      id: 'dummy-hub',
      menuKey: 'dummy_hub',
      menuVal: 'dummy_hub',
      menuName: 'Dummy preview hub',
      page: null,
      iconUrl: '',
      parentId: '',
      subMenu: [
        MenuModel(
          id: 'dummy-manage-tickets',
          menuKey: 'dummy_manage_tickets',
          menuVal: 'manage_tickets',
          menuName: 'Manage tickets',
          page: 'manageTickets',
          iconUrl: '',
          parentId: 'dummy-hub',
          subMenu: const [],
        ),
        MenuModel(
          id: 'dummy-my-tickets',
          menuKey: 'dummy_my_tickets',
          menuVal: 'my_tickets',
          menuName: 'My tickets',
          page: 'tickets',
          iconUrl: '',
          parentId: 'dummy-hub',
          subMenu: const [],
        ),
        MenuModel(
          id: 'dummy-class-attendance',
          menuKey: 'dummy_class_attendance',
          menuVal: 'class_attendance',
          menuName: 'Class attendance',
          page: 'classAttendance',
          iconUrl: '',
          parentId: 'dummy-hub',
          subMenu: const [],
        ),
        MenuModel(
          id: 'dummy-profile',
          menuKey: 'dummy_profile',
          menuVal: 'profile',
          menuName: 'Staff profile',
          page: 'userProfile',
          iconUrl: '',
          parentId: 'dummy-hub',
          subMenu: const [],
        ),
        MenuModel(
          id: 'dummy-nfc',
          menuKey: 'dummy_nfc',
          menuVal: 'nfc_mapping',
          menuName: 'NFC mapping',
          page: 'nfcMapping',
          iconUrl: '',
          parentId: 'dummy-hub',
          subMenu: const [],
        ),
      ],
    ),
  ];
}
