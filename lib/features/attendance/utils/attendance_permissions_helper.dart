import 'package:hive/hive.dart';

/// Outcome of requesting location + camera for mark attendance.
class AttendancePermissionOutcome {
  final bool granted;
  final bool permanentlyDenied;
  final String message;

  const AttendancePermissionOutcome({
    required this.granted,
    this.permanentlyDenied = false,
    this.message = '',
  });
}

/// Hive flag: user has seen the one-time home-screen intro for mark-attendance permissions.
class AttendancePermissionsPrefs {
  static const String _boxName = 'settingsBox';
  static const String _introKey = 'mark_attendance_perm_intro_v1';

  static Future<bool> isIntroCompleted() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_introKey) == true;
  }

  static Future<void> setIntroCompleted() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_introKey, true);
  }
}

/// Location services are omitted from the careers store build.
Future<bool> areMarkAttendancePermissionsGranted() async {
  return false;
}

/// Location services are omitted from the careers store build.
Future<AttendancePermissionOutcome> requestMarkAttendancePermissions() async {
  return const AttendancePermissionOutcome(
    granted: false,
    message: 'Location services are not available in this version.',
  );
}
