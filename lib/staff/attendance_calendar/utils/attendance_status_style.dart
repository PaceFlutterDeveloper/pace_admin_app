import 'package:admin_app/staff/attendance_calendar/utils/attendance_record_status.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter/material.dart';

/// How one attendance status is drawn: tile, pill, chip, legend.
///
/// Late and Leave do not share a hue. Late is amber-orange with a clock.
/// Leave is violet with a calendar, the same accent family as Events on
/// the home screen, so the two stay apart in grayscale too.
class AttendanceMarkStyle {
  const AttendanceMarkStyle({
    required this.background,
    required this.foreground,
    this.badge,
  });

  /// Null means no tile fill (weekend, future, unmarked).
  final Color? background;
  final Color foreground;

  /// Staff glyph drawn with the status. Only Late and Leave have one.
  final String? badge;

  static AttendanceMarkStyle of(
    AttendanceDayKind kind, {
    required bool isDark,
  }) {
    switch (kind) {
      case AttendanceDayKind.present:
        return isDark ? _presentDark : _presentLight;
      case AttendanceDayKind.absent:
        return isDark ? _absentDark : _absentLight;
      case AttendanceDayKind.late:
        return isDark ? _lateDark : _lateLight;
      case AttendanceDayKind.leave:
        return isDark ? _leaveDark : _leaveLight;
      case AttendanceDayKind.holiday:
        return isDark ? _holidayDark : _holidayLight;
      case AttendanceDayKind.weekend:
        return AttendanceMarkStyle(
          background: null,
          foreground: _weekend(isDark),
        );
      case AttendanceDayKind.unmarked:
        return AttendanceMarkStyle(
          background: null,
          foreground: _plain(isDark),
        );
    }
  }

  static const _presentDark = AttendanceMarkStyle(
    background: Color(0xFF1E3A2A),
    foreground: Color(0xFF7EE0A0),
  );
  static const _presentLight = AttendanceMarkStyle(
    background: Color(0xFFE5F6EC),
    foreground: Color(0xFF1F8A4C),
  );
  static const _absentDark = AttendanceMarkStyle(
    background: Color(0xFF3E1F22),
    foreground: Color(0xFFFF8A80),
  );
  static const _absentLight = AttendanceMarkStyle(
    background: Color(0xFFFDECEC),
    foreground: Color(0xFFE15B54),
  );
  static const _lateDark = AttendanceMarkStyle(
    background: Color(0xFF3A2A14),
    foreground: Color(0xFFFFB547),
    badge: StaffGlyphs.clock,
  );
  static const _lateLight = AttendanceMarkStyle(
    background: Color(0xFFF8EBD0),
    foreground: Color(0xFFB86E00),
    badge: StaffGlyphs.clock,
  );
  static const _leaveDark = AttendanceMarkStyle(
    background: Color(0xFF2A2342),
    foreground: Color(0xFFB9A4FF),
    badge: StaffGlyphs.leave,
  );
  static const _leaveLight = AttendanceMarkStyle(
    background: Color(0xFFE8E4F8),
    foreground: Color(0xFF6D5BD0),
    badge: StaffGlyphs.leave,
  );
  static const _holidayDark = AttendanceMarkStyle(
    background: Color(0xFF1B2A44),
    foreground: Color(0xFF9ECAFF),
  );
  static const _holidayLight = AttendanceMarkStyle(
    background: Color(0xFFE4EEF8),
    foreground: Color(0xFF2E6CAD),
  );

  static Color _weekend(bool isDark) =>
      isDark ? const Color(0xFF5C6273) : const Color(0xFF9AA0AE);

  static Color _plain(bool isDark) =>
      isDark ? const Color(0xFFB9BECB) : const Color(0xFF3D4454);
}
