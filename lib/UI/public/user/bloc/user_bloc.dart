import 'dart:developer';

import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:admin_app/UI/public/user/services/auth_api_service.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc for candidate (careers) authentication: login, signup, logout,
/// password recovery and email verification.
///
/// Profile data is handled by `CareersProfileBloc`.
class UserBloc extends Bloc<UserEvent, UserState> {
  final CareersUserService _careersUserService;
  final AuthApiService _authApiService;

  UserBloc({
    required AuthApiService authApiService,
    required CareersUserService careersUserService,
  }) : _careersUserService = careersUserService,
       _authApiService = authApiService,
       super(const UserInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<LogoutEvent>(_onLogout);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ResendVerificationEvent>(_onResendVerification);
    on<VerifyEmailEvent>(_onVerifyEmail);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<UserState> emit) async {
    emit(const LoginLoading());

    final result = await _authApiService.login(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (error) async {
        log('UserBloc: Login failed - ${error.message}');
        emit(LoginError(message: error.message));
      },
      (data) async {
        final userJson = data['user'];
        userJson['session_token'] = data['session_token'];

        final user = CareersUserModel.fromJson(userJson);
        await _careersUserService.setCurrentCareersUser(user);
        await _careersUserService.updateLastLogin();

        emit(LoginSuccess(user: user));
      },
    );
  }

  Future<void> _onSignup(SignupEvent event, Emitter<UserState> emit) async {
    emit(const SignupLoading());

    final result = await _authApiService.signup(
      name: event.name,
      email: event.email,
      phone: event.phone ?? '',
      password: event.password,
      confirmPassword: event.password,
    );

    result.fold((error) {
      log('UserBloc: Signup failed - ${error.message}');
      emit(SignupError(message: error.message));
    }, (_) => emit(const SignupSuccess()));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<UserState> emit) async {
    try {
      await _careersUserService.clearCurrentCareersUser();
      emit(const LogoutSuccess());
    } catch (e) {
      log('UserBloc: Logout error - $e');
      emit(LogoutError(message: 'Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const ForgotPasswordLoading());

    final result = await _authApiService.forgotPassword(email: event.email);

    result.fold(
      (error) => emit(ForgotPasswordError(message: error.message)),
      (_) => emit(
        const ForgotPasswordSuccess(
          message: 'Password reset link sent to your email',
        ),
      ),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const ResetPasswordLoading());

    final result = await _authApiService.resetPassword(
      token: event.token,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (error) => emit(ResetPasswordError(message: error.message)),
      (_) => emit(
        const ResetPasswordSuccess(
          message: 'Password has been reset successfully',
        ),
      ),
    );
  }

  Future<void> _onResendVerification(
    ResendVerificationEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const ResendVerificationLoading());

    final result = await _authApiService.resendVerification(email: event.email);

    result.fold(
      (error) => emit(ResendVerificationError(message: error.message)),
      (_) => emit(
        const ResendVerificationSuccess(
          message: 'Verification email sent to your inbox',
        ),
      ),
    );
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const VerifyEmailLoading());

    final result = await _authApiService.verifyEmail(token: event.token);

    await result.fold(
      (error) async => emit(VerifyEmailError(message: error.message)),
      (_) async {
        final currentUser = _careersUserService.getCurrentCareersUser();
        if (currentUser != null) {
          await _careersUserService.updateCurrentCareersUser(
            currentUser.copyWith(isEmailVerified: true),
          );
        }
        emit(
          const VerifyEmailSuccess(
            message: 'Email has been verified successfully',
          ),
        );
      },
    );
  }
}
