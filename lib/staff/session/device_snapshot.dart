import 'dart:io' show Platform;
import 'dart:math';

import 'package:admin_app/staff/shared/read_json.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// What this phone tells the login API.
///
/// [deviceName] is the name a person would recognise, such as `iPhone 12 Pro`.
/// [ip] and [location] come from the public IP. Both stay empty when that
/// lookup does not answer, and sign-in still goes ahead.
class DeviceSnapshot {
  const DeviceSnapshot({
    required this.deviceId,
    required this.platform,
    required this.deviceName,
    required this.appVersion,
    this.ip = '',
    this.location = '',
  });

  final String deviceId;
  final String platform;
  final String deviceName;
  final String appVersion;
  final String ip;
  final String location;

  /// Form fields for `login` and `registerDevice`. Empty values are left out.
  Map<String, String> get fields => {
    if (deviceId.isNotEmpty) 'device_id': deviceId,
    if (platform.isNotEmpty) 'platform': platform,
    if (deviceName.isNotEmpty) 'device_name': deviceName,
    if (appVersion.isNotEmpty) 'app_version': appVersion,
    if (ip.isNotEmpty) 'ip': ip,
    if (location.isNotEmpty) 'location': location,
  };
}

/// Stable id of this install, created on first use.
String staffDeviceId() {
  final box = Hive.box('settingsBox');
  final saved = box.get('staffDeviceId') as String?;
  if (saved != null && saved.isNotEmpty) return saved;
  final random = Random.secure();
  final id = List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  box.put('staffDeviceId', id);
  return id;
}

/// Reads this phone for sign-in. A resolved place is reused for the launch.
/// A missed place is looked up once more.
class DeviceInfo {
  DeviceInfo._();

  static DeviceSnapshot? _cached;
  static Future<DeviceSnapshot>? _pending;

  /// Failed place lookups are tried once more, so a slow network at the
  /// moment the login screen opens does not drop the city from sign-in.
  static int _placeTries = 0;

  static Future<DeviceSnapshot> capture() {
    final cached = _cached;
    if (cached != null && (cached.ip.isNotEmpty || _placeTries >= 2)) {
      return Future.value(cached);
    }
    return _pending ??= _load(cached);
  }

  static Future<DeviceSnapshot> _load(DeviceSnapshot? previous) async {
    try {
      _placeTries++;
      if (previous != null) {
        final place = await _place();
        final snapshot = DeviceSnapshot(
          deviceId: previous.deviceId,
          platform: previous.platform,
          deviceName: previous.deviceName,
          appVersion: previous.appVersion,
          ip: place['ip'] ?? '',
          location: place['location'] ?? '',
        );
        _cached = snapshot;
        return snapshot;
      }
      final placeFuture = _place();
      final nameFuture = _name();
      final versionFuture = _version();
      final place = await placeFuture;
      final snapshot = DeviceSnapshot(
        deviceId: _deviceId(),
        platform: devicePlatform(),
        deviceName: await nameFuture,
        appVersion: await versionFuture,
        ip: place['ip'] ?? '',
        location: place['location'] ?? '',
      );
      _cached = snapshot;
      return snapshot;
    } catch (e) {
      debugPrint('device info skipped: $e');
      final platform = devicePlatform();
      final snapshot = DeviceSnapshot(
        deviceId: _deviceId(),
        platform: platform,
        deviceName: platform == 'ios' ? 'iPhone' : 'Android',
        appVersion: '',
      );
      _cached = snapshot;
      return snapshot;
    } finally {
      _pending = null;
    }
  }

  static String _deviceId() {
    try {
      return staffDeviceId();
    } catch (_) {
      return '';
    }
  }

  static Future<String> _name() async {
    final platform = devicePlatform();
    final fallback = platform == 'ios' ? 'iPhone' : 'Android';
    try {
      final raw = await DeviceMarketingNames().getSingleName();
      return presentableDeviceName(raw, fallback: fallback);
    } catch (e) {
      debugPrint('device name skipped: $e');
      return fallback;
    }
  }

  static Future<String> _version() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      return '';
    }
  }

  static Future<Map<String, String>> _place() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              'https://ipwho.is/?fields=ip,success,city,region,country',
            ),
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'SmartPACE',
            },
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode != 200) return const {};
      return placeFromIpLookup(decodeJsonMap(res.body));
    } catch (e) {
      debugPrint('ip lookup skipped: $e');
      return const {};
    }
  }
}

String devicePlatform() {
  try {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return Platform.operatingSystem;
  } catch (_) {
    return '';
  }
}

final _appleMachine = RegExp(r'^(iPhone|iPad|iPod)\d+,\d+$');
const _notAName = {'arm64', 'x86_64', 'i386', 'aarch64'};

/// Turns a hardware code into a name a person would say.
/// An Apple code such as `iPhone13,3` becomes `iPhone`. A marketing name
/// such as `iPhone 12 Pro` is kept. [fallback] covers an empty value.
String presentableDeviceName(String raw, {required String fallback}) {
  var name = raw.trim();
  if (name.contains('/')) name = name.split('/').first.trim();
  if (name.isEmpty || _notAName.contains(name.toLowerCase())) return fallback;
  if (_appleMachine.hasMatch(name)) {
    if (name.startsWith('iPad')) return 'iPad';
    if (name.startsWith('iPod')) return 'iPod';
    return 'iPhone';
  }
  return name;
}

/// `Dubai` + `United Arab Emirates` becomes `Dubai, United Arab Emirates`.
String placeLabel({String city = '', String region = '', String country = ''}) {
  final cityName = city.trim();
  final regionName = region.trim();
  final countryName = country.trim();
  final local = cityName.isNotEmpty ? cityName : regionName;
  if (local.isEmpty) return countryName;
  if (countryName.isEmpty) return local;
  if (local.toLowerCase() == countryName.toLowerCase()) return countryName;
  return '$local, $countryName';
}

/// Reads an ipwho.is (or similar) payload. A failed lookup returns nothing.
Map<String, String> placeFromIpLookup(Map<String, dynamic> json) {
  final success = json['success'];
  final status = readString(json['status']).toLowerCase();
  if (success == false || status == 'fail' || status == 'failed') {
    return const {};
  }
  final ip = readString(json['ip'] ?? json['query']);
  final location = placeLabel(
    city: readString(json['city']),
    region: readString(json['region'] ?? json['regionName']),
    country: readString(json['country'] ?? json['country_name']),
  );
  return {
    if (ip.isNotEmpty) 'ip': ip,
    if (location.isNotEmpty) 'location': location,
  };
}
