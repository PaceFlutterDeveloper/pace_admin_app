import 'package:admin_app/staff/sessions/domain/login_session.dart';

/// Saved sign-ins for the active staff account (`page=loginSessions`).
abstract class LoginSessionsRepository {
  Future<List<LoginSession>> load();

  /// Signs that phone out. This phone's token stays valid.
  Future<void> revoke(String sessionId);

  /// Signs out every phone except this one.
  Future<void> revokeOthers();
}
