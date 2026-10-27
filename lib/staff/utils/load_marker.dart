import 'package:admin_app/staff/home/utils/active_staff_user.dart';

/// Identifies the signed-in staff member, so cached data never leaks to
/// another account after a user switch.
String activeStaffKey() {
  final u = activeStaffUser();
  return '${u.schoolCode}:${u.userId}';
}

/// Remembers who and what a cubit's data was loaded for, and when.
///
/// Tabs are rebuilt every time the user switches back to them. A cubit that
/// emits `loading` on each visit blanks the screen and refetches, which reads
/// as lag. With a marker a cubit keeps showing its data and refreshes quietly.
class LoadMarker {
  /// Who is signed in. Tests replace this; the app reads the Hive session.
  static String Function() sessionKey = activeStaffKey;

  String? _key;
  Object? _arg;
  DateTime? _at;

  /// True when data was loaded for the active user and the same [arg].
  bool holds({Object? arg}) =>
      _key == sessionKey() && _arg == arg && _at != null;

  /// True when [holds] and the data is younger than [maxAge].
  bool isFresh({Object? arg, Duration maxAge = const Duration(seconds: 45)}) =>
      holds(arg: arg) && DateTime.now().difference(_at!) < maxAge;

  void mark({Object? arg}) {
    _key = sessionKey();
    _arg = arg;
    _at = DateTime.now();
  }

  void clear() => _at = null;
}
