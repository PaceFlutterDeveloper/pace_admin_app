import 'package:admin_app/staff/shared/read_json.dart';

/// One phone that has signed in to this staff account.
class LoginSession {
  const LoginSession({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.location,
    required this.ip,
    required this.lastSeen,
    required this.current,
  });

  final String id;
  final String deviceId;
  final String deviceName;
  final String platform;
  final String location;
  final String ip;
  final DateTime? lastSeen;

  /// Server says this row is the token making the request.
  final bool current;

  factory LoginSession.fromMap(Map<String, dynamic> json) {
    return LoginSession(
      id: readString(json['id'] ?? json['session_id']),
      deviceId: readString(json['device_id']),
      deviceName: readString(
        json['device_name'] ?? json['device'] ?? json['name'],
      ),
      platform: readString(json['platform']).toLowerCase(),
      location: readString(json['location'] ?? json['place']),
      ip: readString(json['ip'] ?? json['ip_address']),
      lastSeen: readDate(
        json['last_seen'] ??
            json['last_active'] ??
            json['logged_in_at'] ??
            json['created_at'],
      ),
      current: readBool(
        json['is_current'] ?? json['current'] ?? json['this_device'],
      ),
    );
  }
}

/// Sessions split the way the profile screen shows them.
class LoginActivity {
  const LoginActivity({required this.here, required this.others});

  final List<LoginSession> here;
  final List<LoginSession> others;

  bool get isEmpty => here.isEmpty && others.isEmpty;
}

bool sessionIsThisPhone(LoginSession session, String deviceId) {
  final ours = deviceId.trim();
  final theirs = session.deviceId.trim();
  if (ours.isNotEmpty && theirs.isNotEmpty) return ours == theirs;
  return session.current;
}

LoginActivity groupLoginSessions(
  List<LoginSession> sessions, {
  required String deviceId,
}) {
  final here = <LoginSession>[];
  final others = <LoginSession>[];
  for (final session in sessions) {
    if (sessionIsThisPhone(session, deviceId)) {
      here.add(session);
    } else {
      others.add(session);
    }
  }
  int newestFirst(LoginSession a, LoginSession b) {
    final at = a.lastSeen;
    final bt = b.lastSeen;
    if (at == null && bt == null) return 0;
    if (at == null) return 1;
    if (bt == null) return -1;
    return bt.compareTo(at);
  }

  here.sort(newestFirst);
  others.sort(newestFirst);
  return LoginActivity(here: here, others: others);
}

String sessionTitle(LoginSession session) {
  final name = session.deviceName.trim();
  if (name.isNotEmpty) return name;
  switch (session.platform) {
    case 'ios':
      return 'iPhone';
    case 'android':
      return 'Android';
    default:
      return 'Unknown device';
  }
}

const _months = [
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

/// `Active now`, `2 hours ago`, `Yesterday`, or a short date.
String sessionWhen(DateTime? at, {required DateTime now, required bool here}) {
  if (at == null) return here ? 'Active now' : '';
  final diff = now.difference(at);
  if (diff.isNegative || diff < const Duration(minutes: 2)) return 'Active now';
  if (diff.inMinutes < 60) {
    final minutes = diff.inMinutes;
    return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
  }
  if (diff.inHours < 24) {
    final hours = diff.inHours;
    return hours == 1 ? '1 hour ago' : '$hours hours ago';
  }
  final days = diff.inDays;
  if (days == 1) return 'Yesterday';
  if (days < 7) return '$days days ago';
  final month = _months[at.month - 1];
  if (at.year == now.year) return '${at.day} $month';
  return '${at.day} $month ${at.year}';
}

/// Place and time on one line: `Dubai, United Arab Emirates · Active now`.
String sessionDetail(
  LoginSession session, {
  required DateTime now,
  required bool here,
}) {
  final place = session.location.trim().isNotEmpty
      ? session.location.trim()
      : session.ip.trim();
  final when = sessionWhen(session.lastSeen, now: now, here: here);
  if (place.isEmpty) return when;
  if (when.isEmpty) return place;
  return '$place · $when';
}
