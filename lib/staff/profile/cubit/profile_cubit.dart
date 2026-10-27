import 'package:admin_app/staff/profile/model/profile_data_model.dart';
import 'package:admin_app/staff/profile/repository/profile_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository = locator<ProfileRepository>();
  final LoadMarker _loaded = LoadMarker();
  final SessionScope _scope = SessionScope();

  ProfileCubit() : super(const ProfileState.initial());

  /// Whether the profile was loaded recently for the active user.
  bool get isFresh => _loaded.isFresh();

  /// Drops the profile so the next account cannot see it.
  void dropSession() {
    _scope.invalidate();
    _loaded.clear();
    if (!isClosed) emit(const ProfileState.initial());
  }

  /// With [quiet] the profile already on screen stays visible while it
  /// refreshes; no loading state is emitted and errors are ignored.
  Future<void> getEmpProfile({bool quiet = false}) async {
    final keep =
        quiet &&
        _loaded.holds() &&
        state.maybeWhen(success: (_) => true, orElse: () => false);
    final stamp = _scope.begin();
    if (!keep) emit(const ProfileState.loading());

    var res = await _profileRepository.getEmpProfile();
    if (isClosed || !_scope.current(stamp)) return;

    return res.fold(
      (error) {
        if (!keep) {
          emit(ProfileState.error(error.message ?? "Something went wrong"));
        }
      },
      (profile) {
        _loaded.mark();
        emit(ProfileState.success(profile.data));
      },
    );

    // To parse this JSON data, do
  }
}
