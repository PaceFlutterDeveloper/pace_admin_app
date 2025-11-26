import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/UI/home/repository/home_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

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

        emit(HomeState.success(menuData.data));
      },
    );
  }
}
