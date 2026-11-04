import 'package:admin_app/staff/shared/read_json.dart';

class StaffContact {
  const StaffContact({required this.label, required this.value});

  final String label;
  final String value;
}

class StaffRelative {
  const StaffRelative({
    required this.name,
    required this.relation,
    required this.phones,
  });

  final String name;
  final String relation;
  final List<StaffContact> phones;

  String get line =>
      [name, relation].where((part) => part.isNotEmpty).join(' · ');
}

class StaffSocial {
  const StaffSocial({required this.medium, required this.value});

  /// API key, such as `whatsapp` or `instagram`.
  final String medium;
  final String value;
}

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
    this.empId = '',
    this.status = '',
    this.phones = const [],
    this.emails = const [],
    this.social = const [],
    this.relative,
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
  final String empId;
  final String status;
  final List<StaffContact> phones;
  final List<StaffContact> emails;
  final List<StaffSocial> social;
  final StaffRelative? relative;

  /// Only present for roles that may see attendance (from `detail`).
  final String todayStatus;
  final String checkIn;
  final String checkOut;

  String get statusLabel {
    final words = status.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (words.isEmpty) return '';
    return words
        .split(RegExp(r'\s+'))
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  bool get hasContact =>
      phones.isNotEmpty ||
      emails.isNotEmpty ||
      social.isNotEmpty ||
      relative != null;

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    final today = map['today'];
    final phone = readString(map['phone']);
    final email = readString(map['email']);
    final id = readString(map['id'] ?? map['staff_id']);
    final empId = readString(map['emp_id']);
    final status = readString(map['status']);
    final phones = _contacts(map['phones'], 'Phone');
    final emails = _contacts(map['emails'], 'Email');
    return StaffMember(
      id: id,
      name: readString(map['name']),
      designation: readString(map['designation']),
      department: readString(map['department']),
      photo: readString(map['photo']),
      phone: phone,
      email: email,
      active: status.toLowerCase() != 'inactive',
      empId: empId.isEmpty ? id : empId,
      status: status,
      phones: phones.isEmpty && phone.isNotEmpty
          ? [StaffContact(label: 'Phone', value: phone)]
          : phones,
      emails: emails.isEmpty && email.isNotEmpty
          ? [StaffContact(label: 'Email', value: email)]
          : emails,
      social: _social(map['social']),
      relative: _relative(map['relative']),
      todayStatus: today is Map ? readString(today['status']) : '',
      checkIn: today is Map ? readString(today['check_in']) : '',
      checkOut: today is Map ? readString(today['check_out']) : '',
    );
  }
}

const _socialOrder = ['whatsapp', 'instagram', 'facebook', 'linkedin'];

List<StaffContact> _contacts(dynamic raw, String fallbackLabel) {
  final items = <StaffContact>[];
  for (final row in objectList(raw)) {
    final value = readString(row['value']);
    if (value.isEmpty) continue;
    final label = readString(row['label']);
    items.add(
      StaffContact(
        label: label.isEmpty ? fallbackLabel : label,
        value: value,
      ),
    );
  }
  return items;
}

StaffRelative? _relative(dynamic raw) {
  if (raw is! Map) return null;
  final name = readString(raw['name']);
  final relation = readString(raw['relation']);
  final phones = _contacts(raw['phones'], 'Mobile');
  if (name.isEmpty && phones.isEmpty) return null;
  return StaffRelative(name: name, relation: relation, phones: phones);
}

List<StaffSocial> _social(dynamic raw) {
  if (raw is! Map) return const [];
  final values = <String, String>{};
  for (final entry in raw.entries) {
    final value = readString(entry.value);
    if (value.isEmpty) continue;
    values[entry.key.toString().toLowerCase()] = value;
  }
  if (values.isEmpty) return const [];
  final items = <StaffSocial>[];
  for (final medium in _socialOrder) {
    final value = values.remove(medium);
    if (value == null) continue;
    items.add(StaffSocial(medium: medium, value: value));
  }
  for (final entry in values.entries) {
    items.add(StaffSocial(medium: entry.key, value: entry.value));
  }
  return items;
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
