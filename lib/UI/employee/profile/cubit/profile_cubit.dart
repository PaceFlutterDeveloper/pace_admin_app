import 'package:admin_app/UI/employee/profile/model/profile_data_model.dart';
import 'package:admin_app/UI/employee/profile/repository/profile_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository = locator<ProfileRepository>();
  ProfileCubit() : super(const ProfileState.initial());

  Future<void> getEmpProfile() async {
    emit(const ProfileState.loading());

    var res = await _profileRepository.getEmpProfile();

    return res.fold(
      (error) =>
          emit(ProfileState.error(error.message ?? "Something went wrong")),
      (profile) => emit(ProfileState.success(profile.data)),
    );

    // To parse this JSON data, do
  }
}
