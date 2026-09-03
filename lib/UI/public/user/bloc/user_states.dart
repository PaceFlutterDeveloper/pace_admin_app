import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:equatable/equatable.dart';

/// Candidate (careers) authentication states.
///
/// Profile data states live in `bloc/profile/careers_profile_states.dart`.
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

// Login states
class LoginLoading extends UserState {
  const LoginLoading();
}

class LoginSuccess extends UserState {
  final CareersUserModel user;

  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginError extends UserState {
  final String message;

  const LoginError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Login blocked because the account email has not been verified yet
/// (Careers API returns HTTP 403 until `auth-verify-email` succeeds).
class LoginEmailNotVerified extends UserState {
  final String email;
  final String message;

  const LoginEmailNotVerified({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

// Signup states
class SignupLoading extends UserState {
  const SignupLoading();
}

class SignupSuccess extends UserState {
  const SignupSuccess();
}

class SignupError extends UserState {
  final String message;

  const SignupError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Logout states
class LogoutSuccess extends UserState {
  const LogoutSuccess();
}

class LogoutError extends UserState {
  final String message;

  const LogoutError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Forgot password states
class ForgotPasswordLoading extends UserState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends UserState {
  final String message;

  const ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends UserState {
  final String message;

  const ForgotPasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Reset password states
class ResetPasswordLoading extends UserState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends UserState {
  final String message;

  const ResetPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResetPasswordError extends UserState {
  final String message;

  const ResetPasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Resend verification states
class ResendVerificationLoading extends UserState {
  const ResendVerificationLoading();
}

class ResendVerificationSuccess extends UserState {
  final String message;

  const ResendVerificationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResendVerificationError extends UserState {
  final String message;

  const ResendVerificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Verify email states
class VerifyEmailLoading extends UserState {
  const VerifyEmailLoading();
}

class VerifyEmailSuccess extends UserState {
  final String message;

  const VerifyEmailSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class VerifyEmailError extends UserState {
  final String message;

  const VerifyEmailError({required this.message});

  @override
  List<Object?> get props => [message];
}
