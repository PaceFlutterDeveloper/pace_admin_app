/// Date helpers for the careers API, which uses `d/m/Y` for some profile fields.
class CareersApiDates {
  CareersApiDates._();

  static const _invalidSentinels = {'0000-00-00', '0000-00-00 00:00:00'};

  /// Converts a UI date (`Y-m-d` or `d/m/Y`) to `d/m/Y` for update-profile.
  static String? formatForApi(String? value) {
    final parsed = parseFlexible(value);
    if (parsed == null) return null;

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month/${parsed.year}';
  }

  /// Normalizes API date text to `Y-m-d` for forms and display.
  static String? normalizeFromApi(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    if (isInvalidApiDate(text)) return null;

    final parsed = parseFlexible(text);
    if (parsed == null) return text;

    return _toIsoDate(parsed);
  }

  static bool isInvalidApiDate(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return true;
    if (_invalidSentinels.contains(text)) return true;
    return text.startsWith('0000-');
  }

  static DateTime? parseFlexible(String? value) {
    if (value == null) return null;
    final text = value.trim();
    if (text.isEmpty) return null;

    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length == 3) {
        return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      }
    }

    if (text.contains('-')) {
      final parts = text.split('-');
      if (parts.length == 3 && parts[0].length <= 2) {
        return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      }
    }

    return DateTime.tryParse(text);
  }

  static String _toIsoDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
