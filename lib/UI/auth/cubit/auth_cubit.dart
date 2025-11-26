import 'dart:io';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/repository/auth_repository.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository = locator<AuthRepository>();
  AuthCubit() : super(const AuthState.initial());

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

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      print('APNS Token: $apnsToken');
      await Future.delayed(const Duration(seconds: 2));
    }
    String? fcmToken = await messaging.getToken();
    var res = await authRepository.login(
      userName: userName,
      password: password,
      fcmToken: fcmToken ?? "NO TOKEN",
    );
    if (res.isLeft) {
      emit(AuthState.loginFailure(res.left.message ?? "Something went wrong"));
    } else {
      if (res.right['status']) {
        final exists = await AuthData.doesUserExist(
          schoolCode: schoolCode,
          userName: userName,
          userId: res.right['data']['id'],
        );
        if (exists) {
          emit(AuthState.loginFailure('User already exists'));
        } else {
          // Authentication is successful
          // Add new user information without deactivating others
          await AuthData.addNewUser(
            schoolCode: schoolCode,
            userName: userName,
            password: password,
            token: res.right['data']['token'],
            designation: res.right['data']['designation'],
            profilePicture: res.right['data']['photo'],
            name: res.right['data']['name'],
            userId: res.right['data']['id'],
            logo: res.right['data']['sch_logo'],
            schoolName: res.right['data']['sch_name'],
          );

          // After adding the new user, deactivate other users and set this one as active
          // await AuthData.deactivateAllUsersExcept(
          //   userName,
          //   schoolCode,
          //   res.right['data']['id'],
          // );

          // Emit loginSuccess to trigger GoRouter redirect
          emit(const AuthState.loginSuccess());
        }
      } else {
        emit(AuthState.loginFailure(res.right['message']));
      }
    }
  }

  switchUser(
      {required String userName,
      required String schoolCode,
      required String userId,
      required BuildContext context}) async {
    emit(const AuthState.loading());
    // After adding the new user, deactivate other users and set this one as active
    await AuthData.deactivateAllUsersExcept(userName, schoolCode, userId);
    var box = await Hive.openBox('settingsBox');
    await box.put(
        'schoolCode', schoolCode); // Retrieve the selected school code
    context.read<HomeCubit>().getMenu();
    // Emit loginSuccess to trigger GoRouter redirect
    emit(const AuthState.userSwitch());
  }

  /// Logs out the active user by deactivating them
  void logout() async {
    await AuthData.logoutCurrentUser();
    emit(const AuthState.loggedOut());
  }
}
