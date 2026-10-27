import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/repository/home_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository = locator<HomeRepository>();

  final LoadMarker _loaded = LoadMarker();
  final SessionScope _scope = SessionScope();

  HomeCubit() : super(const HomeState.initial());

  /// Whether the menu was loaded recently for the active user.
  bool get isFresh => _loaded.isFresh();

  /// Drops the menu so the next account cannot see it.
  void dropSession() {
    _scope.invalidate();
    _loaded.clear();
    if (!isClosed) emit(const HomeState.initial());
  }

  /// With [quiet] the menu already on screen stays visible while it
  /// refreshes; no loading state is emitted and errors are ignored.
  Future<void> getMenu({bool quiet = false}) async {
    final keep =
        quiet &&
        _loaded.holds() &&
        state.maybeWhen(success: (_) => true, orElse: () => false);
    final stamp = _scope.begin();
    if (!keep) emit(const HomeState.loading());

    var res = await _homeRepository.getMenu();
    if (isClosed || !_scope.current(stamp)) return;

    res.fold(
      (error) {
        if (!keep && !isClosed && _scope.current(stamp)) {
          emit(HomeState.error(error.message ?? "Something went wrong"));
        }
      },
      (menuData) async {
        AuthModel? auth = await AuthData.getActiveUser();
        if (isClosed || !_scope.current(stamp)) return;
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

        if (isClosed || !_scope.current(stamp)) return;
        _loaded.mark();
        emit(HomeState.success(menuData.data));
      },
    );
  }
}
