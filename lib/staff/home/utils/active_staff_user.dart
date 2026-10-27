import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// The signed-in staff member, or an empty model when nobody is active.
AuthModel activeStaffUser() {
  return locator<Box<AuthModel>>().values.firstWhere(
    (u) => u.isActive,
    orElse: AuthModel.empty,
  );
}

/// Rebuilds when the staff session box changes (name, notification count).
ValueListenable<Box<AuthModel>> staffSessionListenable() {
  return locator<Box<AuthModel>>().listenable();
}

/// First word of [name], or empty.
String firstNameOf(String name) {
  for (final part in name.trim().split(RegExp(r'\s+'))) {
    if (part.isNotEmpty) return part;
  }
  return '';
}

String greetingForNow([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}
