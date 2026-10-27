import 'package:equatable/equatable.dart';

/// Candidate (careers) authentication events.
///
/// Profile data events live in `bloc/profile/careers_profile_events.dart`.
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends UserEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupEvent extends UserEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const SignupEvent({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, phone];
}

class LogoutEvent extends UserEvent {
  const LogoutEvent();
}

class ForgotPasswordEvent extends UserEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends UserEvent {
  final String token;
  final String password;
  final String confirmPassword;

  const ResetPasswordEvent({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, password, confirmPassword];
}

class ResendVerificationEvent extends UserEvent {
  final String email;

  const ResendVerificationEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyEmailEvent extends UserEvent {
  final String token;

  const VerifyEmailEvent({required this.token});

  @override
  List<Object?> get props => [token];
}
