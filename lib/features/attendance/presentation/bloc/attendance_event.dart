import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAttendanceEvent extends AttendanceEvent {
  const InitializeAttendanceEvent();
}

/// When [showLoading] is false (e.g. GPS stream refresh), the UI is not reset
/// to the full-screen "Verifying location…" spinner — only user actions use true.
class CheckLocationEvent extends AttendanceEvent {
  const CheckLocationEvent({this.showLoading = true});

  final bool showLoading;

  @override
  List<Object?> get props => [showLoading];
}

class StartFaceCaptureEvent extends AttendanceEvent {
  const StartFaceCaptureEvent();
}

class FaceCapturedEvent extends AttendanceEvent {
  final String imagePath;

  /// Sensor orientation from the active camera (0/90/180/270).
  final int sensorOrientation;

  const FaceCapturedEvent(
    this.imagePath, {
    this.sensorOrientation = 0,
  });

  @override
  List<Object?> get props => [imagePath, sensorOrientation];
}

class RetryAttendanceEvent extends AttendanceEvent {
  const RetryAttendanceEvent();
}

class ToggleCaptureModeEvent extends AttendanceEvent {
  final bool useAutoCapture;

  const ToggleCaptureModeEvent(this.useAutoCapture);

  @override
  List<Object?> get props => [useAutoCapture];
}
