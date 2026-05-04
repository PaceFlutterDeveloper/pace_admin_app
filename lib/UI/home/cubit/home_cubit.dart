import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/home/data/dummy_home_menu.dart';
import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/UI/home/repository/home_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

/// Expands grouped menu items so leaf routes (e.g. Attendance) appear as top-level tiles.
///
/// Two attendance entries are supported side by side:
/// - **[userAttendance]** — original calendar / history view (`EmpAttendancePage`).
/// - **[faceAttendance]** — face + location check-in (`AttendancePage`), labelled “Mark attendance”.
///
/// If the API omits either route, a local tile is added so both options stay available.
/// Sort order: legacy **Attendance** first, **Mark attendance** second, then other menus.
List<MenuModel> homeMenuTilesForGrid(List<MenuModel> apiMenus) {
  final tiles = <MenuModel>[];
  for (final item in apiMenus) {
    if (item.subMenu.isNotEmpty) {
      tiles.addAll(item.subMenu);
    } else {
      tiles.add(item);
    }
  }

  final hasLegacyAttendance =
      tiles.any((t) => t.page == 'userAttendance');
  if (!hasLegacyAttendance) {
    tiles.add(
      MenuModel(
        id: 'local-legacy-attendance',
        menuKey: 'attendance_calendar',
        menuVal: 'attendance_calendar',
        menuName: 'Attendance',
        page: 'userAttendance',
        iconUrl: '',
        parentId: '',
        subMenu: const [],
      ),
    );
  }

  final hasMarkAttendance = tiles.any((t) => t.page == 'faceAttendance');
  if (!hasMarkAttendance) {
    tiles.add(
      MenuModel(
        id: 'local-face-attendance',
        menuKey: 'mark_attendance_face',
        menuVal: 'mark_attendance_face',
        menuName: 'Mark attendance',
        page: 'faceAttendance',
        iconUrl: '',
        parentId: '',
        subMenu: const [],
      ),
    );
  }

  int attendanceRank(MenuModel m) {
    switch (m.page) {
      case 'userAttendance':
        return 0;
      case 'faceAttendance':
        return 1;
      default:
        return 2;
    }
  }

  tiles.sort((a, b) {
    final cmp = attendanceRank(a).compareTo(attendanceRank(b));
    if (cmp != 0) return cmp;
    return a.menuName.compareTo(b.menuName);
  });
  return tiles;
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository = locator<HomeRepository>();

  HomeCubit() : super(const HomeState.initial());
  Future<void> getMenu() async {
    emit(const HomeState.loading());

    var res = await _homeRepository.getMenu();

    res.fold(
      (error) => emit(HomeState.error(error.message ?? "Something went wrong")),
      (menuData) async {
        AuthModel? auth = await AuthData.getActiveUser();
        if (auth != null && menuData.count != null) {
          if (menuData.count > auth.notificationCount) {
            // 🔄 Replace with new count
            await AuthData.updateNotificationCount(
              appCode: auth.schoolCode,
              userId: auth.userId.toString(),
              notificationCount: menuData.count,
              mode: NotificationUpdateMode.replace,
            );
          }
        }

        var tiles = homeMenuTilesForGrid(menuData.data);
        if (kDebugMode) {
          final usedPages =
              tiles.map((t) => t.page).whereType<String>().toSet();
          final dummyTiles = homeMenuTilesForGrid(kDebugDummyHomeMenu());
          final extras = dummyTiles
              .where(
                (d) => d.page != null && !usedPages.contains(d.page),
              )
              .toList();
          tiles = [...tiles, ...extras];
        }

        emit(HomeState.success(tiles));
      },
    );
  }
}
