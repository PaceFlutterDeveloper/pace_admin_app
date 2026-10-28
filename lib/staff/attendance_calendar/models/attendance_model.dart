import 'dart:convert';

class AttendanceModel {
  final String userId;
  final DateTime attDate;
  final int checkIn;
  final int checkOut;
  final String checkInTime;
  final String checkOutTime;
  final String status;

  /// From `leave_type`, for example "Emergency Leave (CL)". Empty when the
  /// day is not leave.
  final String leaveType;

  /// From `late_minutes`. Null when the server sends nothing or zero.
  final int? lateMinutes;

  /// Minutes before the shift end, when the server sends them.
  final int? earlyMinutes;

  /// A real punch-in: the flag is set, or a clock time was sent.
  bool get hasPunchIn => _hasPunch(checkIn, checkInTime);

  /// A real punch-out: the flag is set, or a clock time was sent.
  bool get hasPunchOut => _hasPunch(checkOut, checkOutTime);

  AttendanceModel({
    required this.userId,
    required this.attDate,
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
    this.leaveType = '',
    this.lateMinutes,
    this.earlyMinutes,
  });

  factory AttendanceModel.fromJson(String str) =>
      AttendanceModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromMap(Map<String, dynamic> json) {
    final attDate = DateTime.tryParse(json['attDate']?.toString() ?? '');
    if (attDate == null) {
      throw const FormatException('Attendance row has no attDate');
    }
    return AttendanceModel(
      userId: json['user_id']?.toString() ?? '',
      attDate: attDate,
      checkIn: _asFlag(json['check_in']),
      checkOut: _asFlag(json['check_out']),
      checkInTime: json['check_in_time']?.toString() ?? '',
      checkOutTime: json['check_out_time']?.toString() ?? '',
      status: json['stat']?.toString() ?? '',
      leaveType: json['leave_type']?.toString().trim() ?? '',
      lateMinutes: _optionalMinutes(
        json['late_min'] ?? json['late_minutes'] ?? json['late_by'],
      ),
      earlyMinutes: _optionalMinutes(
        json['early_min'] ?? json['early_minutes'] ?? json['early_by'],
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    "user_id": userId,
    "attDate":
        "${attDate.year.toString().padLeft(4, '0')}-${attDate.month.toString().padLeft(2, '0')}-${attDate.day.toString().padLeft(2, '0')}",
    "check_in": checkIn,
    "check_out": checkOut,
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "stat": status,
    if (leaveType.isNotEmpty) "leave_type": leaveType,
    if (lateMinutes != null) "late_minutes": lateMinutes,
    if (earlyMinutes != null) "early_minutes": earlyMinutes,
  };
}

int? _optionalMinutes(dynamic value) {
  if (value == null) return null;
  final parsed = value is num
      ? value.toInt()
      : int.tryParse(value.toString().trim());
  if (parsed == null || parsed <= 0) return null;
  return parsed;
}

bool _hasPunch(int flag, String time) {
  if (flag == 1) return true;
  final text = time.trim();
  if (text.isEmpty || text == '-' || text == '—') return false;
  return text.toUpperCase() != 'N/A';
}

int _asFlag(dynamic value) {
  if (value is bool) return value ? 1 : 0;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '') ?? 0;
}
