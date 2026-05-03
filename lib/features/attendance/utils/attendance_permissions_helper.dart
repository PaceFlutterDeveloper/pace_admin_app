import 'dart:async';

import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

/// Outcome of requesting location + camera for mark attendance.
class AttendancePermissionOutcome {
  final bool granted;
  final bool permanentlyDenied;
  final String message;

  const AttendancePermissionOutcome({
    required this.granted,
    this.permanentlyDenied = false,
    this.message = '',
  });
}

/// Hive flag: user has seen the one-time home-screen intro for mark-attendance permissions.
class AttendancePermissionsPrefs {
  static const String _boxName = 'settingsBox';
  static const String _introKey = 'mark_attendance_perm_intro_v1';

  static Future<bool> isIntroCompleted() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_introKey) == true;
  }

  static Future<void> setIntroCompleted() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_introKey, true);
  }
}

/// True when Geolocator + camera are already usable (no system prompts needed).
Future<bool> areMarkAttendancePermissionsGranted() async {
  final geo = await Geolocator.checkPermission();
  final locationOk = geo == LocationPermission.whileInUse ||
      geo == LocationPermission.always;
  final cam = await Permission.camera.status;
  final cameraOk = cam.isGranted || cam.isLimited;
  return locationOk && cameraOk;
}

/// Requests location (Geolocator + optional [Permission.locationWhenInUse]) and camera.
/// Matches [AttendanceBloc] behaviour: non-blocking [Permission.locationAlways] when granted.
Future<AttendancePermissionOutcome> requestMarkAttendancePermissions() async {
  const needBoth =
      'Location and camera permissions are required to mark attendance.';
  const needLocation =
      'Location permission is required to verify you are on campus.';
  const needCamera =
      'Camera permission is required to verify your identity.';

  var geo = await Geolocator.checkPermission();
  AttendanceLogger.log('permissions helper: Geolocator.checkPermission → $geo');
  if (geo == LocationPermission.denied) {
    geo = await Geolocator.requestPermission();
    AttendanceLogger.log(
      'permissions helper: Geolocator.requestPermission → $geo',
    );
  }

  if (geo == LocationPermission.deniedForever) {
    AttendanceLogger.log(
      'permissions helper: location deniedForever → Settings path',
    );
    return const AttendancePermissionOutcome(
      granted: false,
      permanentlyDenied: true,
      message:
          'Location access is permanently denied. Enable it in Settings to mark attendance.',
    );
  }

  var locationOk =
      geo == LocationPermission.whileInUse || geo == LocationPermission.always;

  if (!locationOk) {
    final ph = await Permission.locationWhenInUse.request();
    AttendanceLogger.log(
      'permissions helper: Permission.locationWhenInUse.request → $ph',
    );
    if (ph.isPermanentlyDenied) {
      return const AttendancePermissionOutcome(
        granted: false,
        permanentlyDenied: true,
        message:
            'Location access is blocked. Enable it in Settings to mark attendance.',
      );
    }
    if (ph.isGranted || ph.isLimited) {
      geo = await Geolocator.checkPermission();
      locationOk = geo == LocationPermission.whileInUse ||
          geo == LocationPermission.always;
    }
  }

  var camera = await Permission.camera.status;
  AttendanceLogger.log('permissions helper: Permission.camera (initial) → $camera');
  if (!camera.isGranted && !camera.isLimited) {
    camera = await Permission.camera.request();
    AttendanceLogger.log(
      'permissions helper: Permission.camera.request → $camera',
    );
  }

  if (camera.isPermanentlyDenied) {
    AttendanceLogger.log(
      'permissions helper: camera permanently denied → Settings path',
    );
    return const AttendancePermissionOutcome(
      granted: false,
      permanentlyDenied: true,
      message:
          'Camera access is blocked. Enable it in Settings to mark attendance.',
    );
  }

  final cameraOk = camera.isGranted || camera.isLimited;

  if (locationOk && cameraOk) {
    AttendanceLogger.log(
      'permissions helper: location+camera OK → scheduling locationAlways (non-blocking)',
    );
    unawaited(
      Future(() async {
        try {
          await Permission.locationAlways.request();
        } catch (_) {}
      }),
    );
    return const AttendancePermissionOutcome(granted: true);
  }

  if (!locationOk && !cameraOk) {
    return const AttendancePermissionOutcome(
      granted: false,
      permanentlyDenied: false,
      message: needBoth,
    );
  }
  if (!locationOk) {
    return const AttendancePermissionOutcome(
      granted: false,
      permanentlyDenied: false,
      message: needLocation,
    );
  }
  return const AttendancePermissionOutcome(
    granted: false,
    permanentlyDenied: false,
    message: needCamera,
  );
}
