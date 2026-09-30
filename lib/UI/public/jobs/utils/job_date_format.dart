import 'package:intl/intl.dart';

/// Formatting helpers for the dates already present on job models.
class JobDateFormat {
  const JobDateFormat._();

  static final DateFormat _long = DateFormat('d MMM yyyy');

  /// Short, human relative label for a posted date, e.g. `Today`, `3d ago`,
  /// `12 Jan 2026`. Returns null when the raw date could not be parsed.
  static String? relative(DateTime? date) {
    if (date == null) return null;
    final now = DateTime.now();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;

    if (days < 0) return _long.format(date);
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '${days}d ago';
    if (days < 30) return '${days ~/ 7}w ago';
    return _long.format(date);
  }

  /// Absolute date label, falling back to the raw string when unparseable.
  static String? absolute(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return _long.format(parsed);
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length == 3) {
        final iso = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
        if (iso != null) return _long.format(iso);
      }
    }
    return trimmed;
  }
}
