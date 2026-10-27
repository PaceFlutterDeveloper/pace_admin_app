part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.loginSuccess() = _LoginSuccess;
  const factory AuthState.loginFailure(String myError) = _LoginFailure;
  const factory AuthState.userSwitch() = _UserSwith;
  const factory AuthState.loggedOut() = _LogOut;
}
