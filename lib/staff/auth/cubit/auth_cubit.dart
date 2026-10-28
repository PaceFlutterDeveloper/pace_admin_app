import 'dart:async';

import 'package:admin_app/careers/notification/careers_fcm_service.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/auth/repository/auth_repository.dart';
import 'package:admin_app/staff/home/cubit/home_cubit.dart';
import 'package:admin_app/staff/notification/services/staff_fcm.dart';
import 'package:admin_app/staff/session/staff_memory.dart';
import 'package:admin_app/staff/session/staff_session_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

/// Login JSON uses ints for ids and sometimes null for optional text.
String _loginText(dynamic value) => value?.toString() ?? '';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final StaffSessionService? session;

  /// Opens the staff login screen. Set from app startup; the cubit cannot
  /// import the router.
  final void Function()? openLogin;

  AuthCubit({required this.authRepository, this.session, this.openLogin})
    : super(const AuthState.initial());

  /// Logs in a user with the provided credentials and school code.
  ///
  /// This function attempts to authenticate a user using the given
  /// [userName], [password], and [schoolCode]. It stores the selected
  /// school code in a [Hive] box for global usage. Upon successful login,
  /// it saves the login data in a [Hive] box and emits a success state.
  /// If the login fails, it emits a failure state.
  ///
  /// Throws an exception if the authentication process encounters an error.
  ///
  /// Parameters:
  /// - [userName]: The username of the user attempting to log in.
  /// - [password]: The password of the user attempting to log in.
  /// - [schoolCode]: The code of the school the user is associated with.
  login({
    required String userName,
    required String password,
    required String schoolCode,
  }) async {
    // Store the selected school in Hive for global usage
    var box = Hive.box('settingsBox');
    box.put('schoolCode', schoolCode); // Save the selected school
    emit(const AuthState.loading());

    final fcmToken = await CareersFcmService.getFcmToken();
    var res = await authRepository.login(
      userName: userName,
      password: password,
      fcmToken: fcmToken ?? '',
    );
    if (res.isLeft) {
      emit(AuthState.loginFailure(res.left.message ?? "Something went wrong"));
    } else {
      if (res.right['status']) {
        // The login payload mixes strings, ints, and nulls. Hive stores
        // every account field as text, so coerce here.
        final data = res.right['data'];
        clearStaffSessionMemory();
        await AuthData.addNewUser(
          schoolCode: schoolCode,
          userName: userName,
          password: password,
          token: _loginText(data['token']),
          designation: _loginText(data['designation']),
          profilePicture: _loginText(data['photo']),
          name: _loginText(data['name']),
          userId: _loginText(data['id']),
          logo: _loginText(data['sch_logo']),
          schoolName: _loginText(data['sch_name']),
        );

        Hive.box('settingsBox').put('signedInSurface', 'staff');
        emit(const AuthState.loginSuccess());
        unawaited(session?.registerDevice(force: true));
        unawaited(StaffFcm.subscribeIfPresent(res.right));
      } else {
        emit(AuthState.loginFailure(res.right['message']));
      }
    }
  }

  switchUser({
    required String userName,
    required String schoolCode,
    required String userId,
  }) async {
    emit(const AuthState.loading());
    // Drop the previous account before Hive points at the next one, so a
    // screen that is still mounted cannot paint that account's rows.
    clearStaffSessionMemory();
    await AuthData.deactivateAllUsersExcept(userName, schoolCode, userId);
    var box = await Hive.openBox('settingsBox');
    await box.put(
      'schoolCode',
      schoolCode,
    ); // Retrieve the selected school code
    final now = DateTime.now();
    await Future.wait([
      locator<HomeCubit>().getMenu(),
      locator<AttendanceCubit>().getAttendance(
        month: now.month,
        year: now.year,
      ),
    ]);
    Hive.box('settingsBox').put('signedInSurface', 'staff');
    emit(const AuthState.userSwitch());
    unawaited(StaffFcm.clearTopics());
    unawaited(session?.registerDevice(force: true));
  }

  /// Signs the active profile out. Other profiles saved on this phone stay,
  /// and the router sends the person to choose one. Returns true when at
  /// least one other profile remains.
  ///
  /// The server revokes the token and drops this phone's push token first,
  /// unless the token is already dead ([notifyServer] false). When this was
  /// the last profile, the staff login screen opens.
  Future<bool> logout({bool notifyServer = true}) async {
    if (notifyServer) {
      await session?.signOutOnServer();
    } else {
      unawaited(StaffFcm.clearTopics());
    }
    await AuthData.logoutCurrentUser();
    final othersRemain = locator<Box<AuthModel>>().isNotEmpty;
    _finishLocalSignOut(othersRemain: othersRemain);
    return othersRemain;
  }

  /// Signs every saved profile out and opens the staff login screen.
  Future<void> logoutAll({bool notifyServer = true}) async {
    if (notifyServer) {
      await session?.signOutAllOnServer();
    } else {
      unawaited(StaffFcm.clearTopics());
    }
    await AuthData.deactivateAllUsers();
    _finishLocalSignOut(othersRemain: false);
  }

  void _finishLocalSignOut({required bool othersRemain}) {
    clearStaffSessionMemory();
    if (!othersRemain) {
      Hive.box('settingsBox').delete('signedInSurface');
      openLogin?.call();
    }
    emit(const AuthState.loggedOut());
  }
}
