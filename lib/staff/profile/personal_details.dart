import 'package:admin_app/staff/profile/model/doc_model.dart';
import 'package:admin_app/staff/profile/model/profile_data_model.dart';
import 'package:admin_app/staff/shared/read_json.dart';

const _acronyms = {'HR', 'IT', 'LLC', 'PO', 'UAE'};
const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Turns shouted ERP text into readable words. Short acronyms and mixed-case
/// words stay as stored.
String staffDisplayText(String raw) {
  var text = raw.trim().replaceAll(RegExp(r',\s*'), ', ');
  if (text.isEmpty) return text;
  final letters = text.replaceAll(RegExp(r'[^A-Za-z]'), '');
  final shouting = letters.isNotEmpty && letters == letters.toUpperCase();
  return text.replaceAllMapped(RegExp(r'[A-Za-z]+'), (match) {
    final word = match.group(0)!;
    if (word != word.toUpperCase()) return word;
    if (_acronyms.contains(word)) return word;
    if (!shouting && word.length <= 3) return word;
    return word[0] + word.substring(1).toLowerCase();
  });
}

/// Like [staffDisplayText], and capitalises a fully lowercase value.
String staffWord(String raw) {
  final text = staffDisplayText(raw);
  if (text.isEmpty) return text;
  final letters = text.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty || letters != letters.toLowerCase()) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String formatStaffDate(String raw, {String empty = 'N/A'}) {
  final text = raw.trim();
  if (text.isEmpty) return empty;
  final date = readDate(text);
  if (date == null) return text;
  return _date(date) ?? text;
}

/// Prefers a real portrait over the generic ERP placeholders.
String profilePhotoUrl({
  required String rootPhoto,
  required dynamic userPhoto,
  required String sessionPhoto,
}) {
  final root = rootPhoto.trim();
  final user = userPhoto is String ? userPhoto.trim() : '';
  final session = sessionPhoto.trim();
  for (final url in [root, user, session]) {
    if (url.isNotEmpty && !_placeholderPhoto(url)) return url;
  }
  if (root.isNotEmpty) return root;
  if (user.isNotEmpty) return user;
  return session;
}

class ProfileDetailLine {
  const ProfileDetailLine(this.label, this.value);

  final String label;
  final String value;
}

class ProfileDetailGroup {
  const ProfileDetailGroup(this.title, this.lines);

  final String title;
  final List<ProfileDetailLine> lines;
}

/// Staff-facing rows for the personal information sheet.
///
/// Blank values, numeric lookup codes, and payroll fields are left out.
List<ProfileDetailGroup> personalDetailGroups(ProfileDataModel data) {
  final emp = data.emp;
  final user = data.user;
  final groups = <ProfileDetailGroup>[];

  void add(String title, List<ProfileDetailLine?> rows) {
    final lines = [
      for (final row in rows)
        if (row != null) row,
    ];
    if (lines.isNotEmpty) groups.add(ProfileDetailGroup(title, lines));
  }

  final fullName = _text(emp?.emplName);
  final shortName = _text(user.name);
  final displayName = fullName ?? shortName;

  add('IDENTITY', [
    _line('Title', _title(emp?.mrMs) ?? _title(user.title)),
    _line('Full name', displayName),
    _line('Known as', _knownAs(fullName, shortName)),
    _line(
      'Alias',
      _distinct(_text(emp?.alias) ?? _text(user.alias), displayName),
    ),
    _line("Father's name", _text(emp?.emplFname)),
    _line("Mother's name", _text(emp?.emplMname)),
    _line('Spouse', _text(emp?.emplSpouse)),
    _line('Gender', _gender(emp?.sex ?? user.gender)),
    _line('Date of birth', _date(emp?.dob)),
    _line('Marital status', _word(emp?.mStatus)),
    _line('Nationality', _coded(emp?.nationality)),
    _line('Birth place', _text(emp?.birthPlace)),
    _line('Birth country', _coded(emp?.birthCountry)),
    _line('Religion', _coded(emp?.religion)),
    _line('Food preference', _coded(emp?.foodPref)),
  ]);

  add('WORK', [
    _line('Employee ID', _code(emp?.empId) ?? _code(user.empId)),
    _line('Personal code', _code(emp?.personalCode)),
    _line(
      'Employee code',
      emp == null ? null : _code(readString(emp.emplCode)),
    ),
    _line('File number', emp == null ? null : _code(readString(emp.fileNo))),
    _line('Designation', _text(emp?.designation) ?? _text(user.designation)),
    _line('Department', _text(emp?.department)),
    _line('Ministry role', _text(emp?.ministryDesignation)),
    _line('Ministry status', _coded(emp?.moeStat)),
    _line('Occupation', _text(emp?.occupation)),
    _line('Username', _plain(user.adUsername)),
    _line('Role', _word(user.role)),
    _line('Status', _word(emp?.stat)),
    _line('School', _text(data.schoolName)),
    _line('Joined', _date(emp?.joinDate)),
    _line('School joined', _date(emp?.schoolJoinDate)),
    _line('Labour joined', _date(emp?.labourJoinDate)),
    _line('Probation', _monthCount(emp?.prob)),
    _line('Confirmed', _date(emp?.jobConf)),
    _line('Confirmed by', _text(emp?.jobConfBy)),
    _line('Visa type', _word(emp?.visaType)),
    _line('Ministry approval', _dateText(emp?.moeAppDate)),
    _line('Yearly leave', _days(emp?.yearlyLeave)),
    _line('Bus', _code(emp?.busNo)),
    _line('Biometric ID', _code(emp?.biometricId)),
  ]);

  final phones = <String>[];
  String? phone(String? value) {
    final raw = _plain(value);
    if (raw == null) return null;
    final key = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (phones.any((item) => item.replaceAll(RegExp(r'[\s\-()]'), '') == key)) {
      return null;
    }
    phones.add(raw);
    return raw;
  }

  final emails = <String>[];
  String? email(String? value) {
    final raw = _plain(value);
    if (raw == null) return null;
    final key = raw.toLowerCase();
    if (emails.contains(key)) return null;
    emails.add(key);
    return raw;
  }

  add('CONTACT', [
    _line('Mobile', phone(emp?.phone1) ?? phone(user.phone)),
    _line('Other phone', phone(emp?.phone2)),
    _line('CUG', phone(emp?.phoneCug)),
    _line('Extension', _code(emp?.phoneExt)),
    _line('Personal email', email(emp?.email) ?? email(user.email)),
    _line('School email', email(emp?.schoolEmail)),
    _line('WhatsApp', phone(emp?.whatsapp)),
  ]);

  add('LOCAL ADDRESS', [
    _line('Emirate', _coded(emp?.localEmirate)),
    _line('Area', _text(emp?.localRegion)),
    _line('Street', _text(emp?.localStreet)),
    _line('Building', _text(emp?.localBuilding)),
    _line('Landmark', _text(emp?.localLandmark)),
    _line('Address', _text(emp?.address)),
  ]);

  add('PERMANENT ADDRESS', [
    _line('House', _text(emp?.perHouse)),
    _line('Town', _text(emp?.perTown)),
    _line('City', _text(emp?.perCity)),
    _line('Country', _coded(emp?.perCountry)),
    _line('Nearest airport', _text(emp?.nearestAirport)),
    _line('Home mobile', phone(emp?.perTelMob)),
    _line('Home phone', phone(emp?.perTelRes)),
  ]);

  add('EMERGENCY CONTACT', [
    _line('Name', _text(emp?.relName)),
    _line('Relation', _word(emp?.relRelation)),
    _line('Mobile', _plain(emp?.relTelMob)),
    _line('Residence', _distinctPhone(emp?.relTelRes, emp?.relTelMob)),
    _line(
      'Office',
      _distinctPhone(emp?.relTelOff, emp?.relTelMob, emp?.relTelRes),
    ),
  ]);

  add('ONLINE', [
    _line('LinkedIn', _plain(emp?.linkedin)),
    _line('Facebook', _plain(emp?.facebook)),
    _line('Instagram', _plain(emp?.instagram)),
  ]);

  add('RECORDS', _recordLines(data));

  add('NOTES', [_line('Remarks', _text(emp?.remarks))]);

  return groups;
}

List<ProfileDetailLine?> _recordLines(ProfileDataModel data) {
  final emp = data.emp;
  if (emp == null) return const [];
  final lines = <ProfileDetailLine?>[
    if (!_covered(data.doc, const ['passport', 'pp'])) ...[
      _line('Passport', _plain(emp.ppNo)),
      _line('Passport expiry', _dateText(emp.ppExpDate)),
    ],
    _line('Passport issued in', _text(emp.ppIssuePlace)),
    if (!_covered(data.doc, const ['labour', 'lc'])) ...[
      _line('Labour card', _plain(emp.lcNo)),
      _line('Labour card expiry', _dateText(emp.lcExpDate)),
    ],
    if (!_covered(data.doc, const ['visa'])) ...[
      _line('Visa', _plain(emp.visaNo)),
      _line('Visa expiry', _dateText(emp.visaExpDate)),
    ],
    if (!_covered(data.doc, const ['emirates', 'eid'])) ...[
      _line('Emirates ID', _plain(emp.eidNo)),
      _line('Emirates ID expiry', _dateText(emp.eidExpDate)),
    ],
    if (!_covered(data.doc, const ['licen', 'dl'])) ...[
      _line('Driving licence', _plain(emp.dlNo)),
      _line('Licence expiry', _dateText(emp.dlExpDate)),
    ],
    if (!_covered(data.doc, const ['health', 'insur', 'hins']))
      _line('Health expiry', _dateText(emp.healthExpDate)),
  ];
  return lines;
}

bool _covered(List<DocModel> docs, List<String> keys) {
  return docs.any((doc) {
    final tokens = '${doc.doc} ${doc.alias}'
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty);
    return keys.any(
      (key) => tokens.any((token) => token == key || token.startsWith(key)),
    );
  });
}

ProfileDetailLine? _line(String label, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return ProfileDetailLine(label, text);
}

String? _plain(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty || text.toLowerCase() == 'null' || text.startsWith('0000')) {
    return null;
  }
  return text;
}

String? _text(String? value) {
  final text = _plain(value);
  if (text == null) return null;
  return staffDisplayText(text);
}

String? _word(String? value) {
  final text = _plain(value);
  if (text == null) return null;
  return staffWord(text);
}

String? _coded(String? value) {
  final text = _plain(value);
  if (text == null || RegExp(r'^\d+$').hasMatch(text)) return null;
  return staffDisplayText(text);
}

String? _code(String? value) {
  final text = _plain(value);
  if (text == null || text == '0') return null;
  return text;
}

String? _title(String? value) {
  final text = _plain(value)?.replaceAll('.', '');
  if (text == null || text.isEmpty) return null;
  return staffWord(text);
}

String? _gender(String value) {
  switch (value.trim().toUpperCase()) {
    case 'M':
    case 'MALE':
      return 'Male';
    case 'F':
    case 'FEMALE':
      return 'Female';
    default:
      return _word(value);
  }
}

String? _date(DateTime? date) {
  if (date == null) return null;
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

String? _dateText(String? value) {
  final text = _plain(value);
  if (text == null) return null;
  return _date(readDate(text));
}

String? _monthCount(String? value) {
  final text = _plain(value);
  if (text == null) return null;
  final count = int.tryParse(text);
  if (count == null) return staffWord(text);
  if (count <= 0) return null;
  return count == 1 ? '1 month' : '$count months';
}

String? _days(String? value) {
  final text = _plain(value);
  if (text == null) return null;
  final count = int.tryParse(text);
  if (count == null) return staffWord(text);
  if (count <= 0) return null;
  return count == 1 ? '1 day' : '$count days';
}

String? _distinct(String? value, String? other) {
  if (value == null) return null;
  if (other != null && value.toLowerCase() == other.toLowerCase()) return null;
  return value;
}

String? _distinctPhone(String? value, String? first, [String? second]) {
  final raw = _plain(value);
  if (raw == null) return null;
  final key = _phoneKey(raw);
  if (first != null && _phoneKey(first) == key) return null;
  if (second != null && _phoneKey(second) == key) return null;
  return raw;
}

String _phoneKey(String value) => value.replaceAll(RegExp(r'[\s\-()]'), '');

String? _knownAs(String? full, String? short) {
  if (full == null || short == null || _samePerson(full, short)) return null;
  return short;
}

bool _samePerson(String full, String short) {
  final a = full.toLowerCase();
  final b = short.toLowerCase();
  return a == b || a.startsWith('$b ');
}

bool _placeholderPhoto(String url) {
  final lower = url.toLowerCase();
  return lower.contains('no_img') ||
      lower.contains('noimage') ||
      lower.contains('no_image') ||
      lower.endsWith('/male.png') ||
      lower.endsWith('/female.png');
}
