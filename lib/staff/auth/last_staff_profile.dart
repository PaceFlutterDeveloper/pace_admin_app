import 'dart:convert';

import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:hive/hive.dart';

/// Settings key for the profile a switch left behind.
const lastStaffProfileKey = 'lastStaffProfile';

/// Stable identity for one saved profile. The same person at two schools
/// is two profiles.
String staffProfileToken({
  required String userId,
  required String schoolCode,
  required String userName,
}) {
  return jsonEncode([userId, schoolCode, userName]);
}

/// Token to store when [previous] is the profile being left. Null when there
/// was nobody to leave, or the next login is that same profile.
String? tokenForProfileLeftBehind({
  required AuthModel? previous,
  required String userId,
  required String schoolCode,
  required String userName,
}) {
  if (previous == null) return null;
  if (_sameAccount(previous, userId, schoolCode, userName)) return null;
  return staffProfileToken(
    userId: previous.userId,
    schoolCode: previous.schoolCode,
    userName: previous.userName,
  );
}

/// Profile a double tap should open.
///
/// Prefers the profile recorded by the last switch. With no record and
/// exactly one other profile, that profile is the only place to go. With
/// several and no record, returns null so the caller can open the list.
AuthModel? lastSwitchedStaffProfile({
  required Iterable<AuthModel> accounts,
  required String? token,
}) {
  final others = [
    for (final user in accounts)
      if (!user.isActive) user,
  ];
  final remembered = _accountForToken(accounts, token);
  if (remembered != null && !remembered.isActive) return remembered;
  if (others.length == 1) return others.first;
  return null;
}

String? storedLastStaffProfileToken() {
  final raw = Hive.box('settingsBox').get(lastStaffProfileKey);
  return raw is String ? raw : null;
}

void storeLastStaffProfileToken(String? token) {
  if (token == null) return;
  Hive.box('settingsBox').put(lastStaffProfileKey, token);
}

void clearLastStaffProfile() {
  Hive.box('settingsBox').delete(lastStaffProfileKey);
}

AuthModel? _accountForToken(Iterable<AuthModel> accounts, String? token) {
  final parsed = _parseToken(token);
  if (parsed == null) return null;
  for (final user in accounts) {
    if (_sameAccount(user, parsed.$1, parsed.$2, parsed.$3)) return user;
  }
  return null;
}

(String, String, String)? _parseToken(String? token) {
  if (token == null || token.isEmpty) return null;
  try {
    final decoded = jsonDecode(token);
    if (decoded is! List || decoded.length != 3) return null;
    return (
      decoded[0].toString(),
      decoded[1].toString(),
      decoded[2].toString(),
    );
  } catch (_) {
    return null;
  }
}

bool _sameAccount(
  AuthModel user,
  String userId,
  String schoolCode,
  String userName,
) {
  return user.userId == userId &&
      user.schoolCode == schoolCode &&
      user.userName == userName;
}
