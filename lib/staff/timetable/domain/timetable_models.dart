import 'package:admin_app/staff/shared/read_json.dart';

class TimetablePeriod {
  const TimetablePeriod({
    required this.weekday,
    required this.periodNo,
    required this.start,
    required this.end,
    required this.subject,
    required this.classLabel,
    required this.room,
  });

  /// 1 = Monday ... 7 = Sunday, 0 when the server value could not be read.
  final int weekday;
  final int periodNo;
  final String start;
  final String end;
  final String subject;
  final String classLabel;
  final String room;

  factory TimetablePeriod.fromMap(Map<String, dynamic> map) {
    final klass = readString(map['class_key'] ?? map['class']);
    final section = readString(map['section']);
    return TimetablePeriod(
      weekday: weekdayOf(map['day'] ?? map['date']),
      periodNo: readInt(map['period_no'] ?? map['period']),
      start: clock(readString(map['start_time'])),
      end: clock(readString(map['end_time'])),
      subject: readString(map['subject']),
      classLabel: [klass, section].where((e) => e.isNotEmpty).join(' '),
      room: readString(map['room']),
    );
  }

  /// Accepts "Monday", "Mon", 1..7 or a date.
  static int weekdayOf(dynamic raw) {
    final text = readString(raw).toLowerCase();
    if (text.isEmpty) return 0;
    final number = int.tryParse(text);
    if (number != null)
      return number == 0 ? 7 : (number >= 1 && number <= 7 ? number : 0);
    const names = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final index = names.indexOf(text.length >= 3 ? text.substring(0, 3) : text);
    if (index >= 0) return index + 1;
    final date = DateTime.tryParse(text);
    return date?.weekday ?? 0;
  }

  /// "08:30:00" becomes "08:30".
  static String clock(String raw) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw);
    return match == null
        ? raw
        : '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }
}
