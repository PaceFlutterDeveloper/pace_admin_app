import 'package:admin_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:equatable/equatable.dart';

enum AttendanceFailureType {
  /// Location or camera not granted; user can retry from the app (no Settings).
  permissionsDenied,
  /// User must enable permissions in system Settings.
  permissionsPermanentlyDenied,
  /// OS location services (GPS) are turned off.
  locationServicesDisabled,
  /// Could not read GPS (timeout, permission, or other).
  locationUnavailable,
  outsideGeofence,
  noFaceDetected,
  faceNotMatched,
  networkError,
  /// Config or optional school API returned 404 (not used after successful local geofence).
  featureUnavailable,
  /// POST mark-attendance missing, not deployed, or wrong path (HTTP 404).
  submitUnavailable,
  /// Server-side (5xx) issues.
  serverError,
  /// Session / auth (401–403).
  authorizationError,
  cameraError,
  lowLight,
  unknown,
}

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceCheckingLocation extends AttendanceState {
  const AttendanceCheckingLocation();
}

class AttendanceOutsideGeofence extends AttendanceState {
  final double distanceAway;
  final String schoolName;
  final bool useAutoCapture;

  const AttendanceOutsideGeofence({
    required this.distanceAway,
    required this.schoolName,
    required this.useAutoCapture,
  });

  @override
  List<Object?> get props => [distanceAway, schoolName, useAutoCapture];
}

class AttendanceReadyForFaceCapture extends AttendanceState {
  final double distance;
  final String schoolName;
  final bool useAutoCapture;

  const AttendanceReadyForFaceCapture({
    required this.distance,
    required this.schoolName,
    required this.useAutoCapture,
  });

  @override
  List<Object?> get props => [distance, schoolName, useAutoCapture];
}

class AttendanceFaceCapturing extends AttendanceState {
  final double distance;
  final String schoolName;
  final bool useAutoCapture;

  const AttendanceFaceCapturing({
    required this.distance,
    required this.schoolName,
    required this.useAutoCapture,
  });

  @override
  List<Object?> get props => [distance, schoolName, useAutoCapture];
}

class AttendanceVerifyingFace extends AttendanceState {
  final String imagePath;

  const AttendanceVerifyingFace(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class AttendanceSuccess extends AttendanceState {
  final AttendanceRecord record;

  const AttendanceSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class AttendanceFailure extends AttendanceState {
  final String message;
  final AttendanceFailureType type;

  const AttendanceFailure({
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [message, type];
}
