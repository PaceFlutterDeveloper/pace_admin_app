import 'package:admin_app/core/utils/debug_logger.dart';

/// Tagged attendance logs — only in debug builds ([DebugLogger] / [kDebugMode]).
///
/// Filter your IDE/console by `[Attendance]` or `[Network]` (Dio mapper uses the latter).
abstract final class AttendanceLogger {
  static const String tag = '[Attendance]';

  static void log(String message) {
    DebugLogger.log('$tag $message');
  }
}
