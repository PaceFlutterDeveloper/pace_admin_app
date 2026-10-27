import 'package:admin_app/staff/shared/read_json.dart';

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.photo,
    required this.phone,
    required this.email,
    required this.active,
    this.todayStatus = '',
    this.checkIn = '',
    this.checkOut = '',
  });

  final String id;
  final String name;
  final String designation;
  final String department;
  final String photo;
  final String phone;
  final String email;
  final bool active;

  /// Only present for roles that may see attendance (from `detail`).
  final String todayStatus;
  final String checkIn;
  final String checkOut;

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    final today = map['today'];
    return StaffMember(
      id: readString(map['id'] ?? map['staff_id']),
      name: readString(map['name']),
      designation: readString(map['designation']),
      department: readString(map['department']),
      photo: readString(map['photo']),
      phone: readString(map['phone']),
      email: readString(map['email']),
      active: readString(map['status']).toLowerCase() != 'inactive',
      todayStatus: today is Map ? readString(today['status']) : '',
      checkIn: today is Map ? readString(today['check_in']) : '',
      checkOut: today is Map ? readString(today['check_out']) : '',
    );
  }
}

class StaffPageResult {
  const StaffPageResult({
    required this.items,
    required this.hasMore,
    required this.total,
  });

  final List<StaffMember> items;
  final bool hasMore;
  final int total;
}
