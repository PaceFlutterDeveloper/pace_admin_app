import 'dart:convert';

class AttendanceModel {
  final String userId;
  final DateTime attDate;
  final int checkIn;
  final int checkOut;
  final String checkInTime;
  final String checkOutTime;
  final String status;

  AttendanceModel({
    required this.userId,
    required this.attDate,
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
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
  };
}

int _asFlag(dynamic value) {
  if (value is bool) return value ? 1 : 0;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '') ?? 0;
}
