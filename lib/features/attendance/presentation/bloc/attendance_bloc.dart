import 'dart:async';

import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/features/attendance/domain/usecases/capture_and_verify_face_usecase.dart';
import 'package:admin_app/features/attendance/domain/usecases/check_geofence_usecase.dart';
import 'package:admin_app/features/attendance/domain/usecases/submit_attendance_usecase.dart';
import 'package:admin_app/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:admin_app/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:admin_app/features/attendance/utils/attendance_permissions_helper.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CheckGeofenceUseCase checkGeofenceUseCase;
  final CaptureAndVerifyFaceUseCase captureAndVerifyFaceUseCase;
  final SubmitAttendanceUseCase submitAttendanceUseCase;

  StreamSubscription<Position>? _positionStream;
  bool _useAutoCapture = true;
  double _distance = 0;
  String _schoolName = 'School Campus';
  bool _insideGeofence = false;

  /// Limits how often the GPS [Position] stream triggers a geofence refresh.
  DateTime? _lastStreamGeofenceAt;

  AttendanceBloc({
    required this.checkGeofenceUseCase,
    required this.captureAndVerifyFaceUseCase,
    required this.submitAttendanceUseCase,
  }) : super(const AttendanceInitial()) {
    on<InitializeAttendanceEvent>(_onInitializeAttendance);
    on<CheckLocationEvent>(
      _onCheckLocation,
      transformer: restartable(),
    );
    on<StartFaceCaptureEvent>(_onStartFaceCapture);
    on<FaceCapturedEvent>(_onFaceCaptured);
    on<RetryAttendanceEvent>(_onRetry);
    on<ToggleCaptureModeEvent>(_onToggleCaptureMode);
  }

  Future<void> _onInitializeAttendance(
    InitializeAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    AttendanceLogger.log('event: InitializeAttendance');
    if (await areMarkAttendancePermissionsGranted()) {
      AttendanceLogger.log(
        'Initialize: permissions already granted → skip prompt + loader',
      );
      _startBackgroundLocationMonitoring();
      add(const CheckLocationEvent());
      return;
    }

    emit(const AttendanceCheckingLocation());
    final outcome = await requestMarkAttendancePermissions();
    if (!outcome.granted) {
      final t = outcome.permanentlyDenied
          ? AttendanceFailureType.permissionsPermanentlyDenied
          : AttendanceFailureType.permissionsDenied;
      AttendanceLogger.log(
        'Initialize: permissions not granted (permanent=${outcome.permanentlyDenied}) → $t',
      );
      emit(AttendanceFailure(
        message: outcome.message,
        type: t,
      ));
      return;
    }
    AttendanceLogger.log('Initialize: permissions OK → background stream + CheckLocation');
    _startBackgroundLocationMonitoring();
    add(const CheckLocationEvent());
  }

  Future<void> _onCheckLocation(
    CheckLocationEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    if (!event.showLoading) {
      final s = state;
      if (s is AttendanceVerifyingFace ||
          s is AttendanceFaceCapturing ||
          s is AttendanceSuccess) {
        AttendanceLogger.log(
          'CheckLocation: skip silent refresh (state=${s.runtimeType})',
        );
        return;
      }
    }

    if (event.showLoading) {
      emit(const AttendanceCheckingLocation());
    }
    final result = await checkGeofenceUseCase();
    result.fold(
      (failure) {
        final ft = _failureTypeFromGeofenceFailure(failure);
        AttendanceLogger.log(
          'CheckLocation: failure kind=${failure.kind} uiType=$ft → ${failure.message}',
        );
        emit(AttendanceFailure(
          message: failure.message,
          type: ft,
        ));
      },
      (check) {
        _distance = check.distanceMeters;
        _schoolName = check.config.schoolName;
        _insideGeofence = check.isInside;
        if (!check.isInside) {
          emit(AttendanceOutsideGeofence(
            distanceAway: check.distanceMeters,
            schoolName: check.config.schoolName,
            useAutoCapture: _useAutoCapture,
          ));
          return;
        }
        emit(AttendanceReadyForFaceCapture(
          distance: check.distanceMeters,
          schoolName: check.config.schoolName,
          useAutoCapture: _useAutoCapture,
        ));
      },
    );
  }

  Future<void> _onStartFaceCapture(
    StartFaceCaptureEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    AttendanceLogger.log(
      'event: StartFaceCapture (_insideGeofence=$_insideGeofence)',
    );
    if (!_insideGeofence) {
      AttendanceLogger.log('StartFaceCapture: blocked — not inside geofence');
      emit(AttendanceOutsideGeofence(
        distanceAway: _distance,
        schoolName: _schoolName,
        useAutoCapture: _useAutoCapture,
      ));
      return;
    }
    emit(AttendanceFaceCapturing(
      distance: _distance,
      schoolName: _schoolName,
      useAutoCapture: _useAutoCapture,
    ));
  }

  Future<void> _onFaceCaptured(
    FaceCapturedEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    AttendanceLogger.log(
      'event: FaceCaptured → verifying face (path segments: ${event.image.path.split('/').last})',
    );
    emit(AttendanceVerifyingFace(event.image.path));
    final verification = await captureAndVerifyFaceUseCase(
      event.image,
      sensorOrientation: event.sensorOrientation,
    );
    await verification.fold(
      (failure) async {
        final vt = _mapValidationFailureType(failure.message);
        AttendanceLogger.log(
          'FaceCaptured: ML validation failed → type=$vt msg=${failure.message}',
        );
        emit(AttendanceFailure(
          message: failure.message,
          type: vt,
        ));
      },
      (compressedImage) async {
        AttendanceLogger.log(
          'FaceCaptured: ML OK → compressed=${compressedImage.path.split('/').last}',
        );
        final submitResult = await submitAttendanceUseCase(compressedImage);
        submitResult.fold(
          (failure) {
            final st = _failureTypeFromSubmitFailure(failure);
            AttendanceLogger.log(
              'submit: failed kind=${failure.kind} uiType=$st → ${failure.message}',
            );
            emit(AttendanceFailure(
              message: failure.message,
              type: st,
            ));
          },
          (record) {
            AttendanceLogger.log(
              'submit: success attendanceId=${record.attendanceId}',
            );
            emit(AttendanceSuccess(record));
          },
        );
      },
    );
  }

  void _onRetry(
    RetryAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) {
    if (state is AttendanceFailure &&
        (state as AttendanceFailure).type ==
            AttendanceFailureType.permissionsDenied) {
      AttendanceLogger.log(
        'event: Retry → re-run Initialize (soft permission denial)',
      );
      add(const InitializeAttendanceEvent());
      return;
    }
    AttendanceLogger.log('event: Retry → CheckLocation');
    add(const CheckLocationEvent());
  }

  void _onToggleCaptureMode(
    ToggleCaptureModeEvent event,
    Emitter<AttendanceState> emit,
  ) {
    AttendanceLogger.log(
      'event: ToggleCaptureMode useAutoCapture=${event.useAutoCapture}',
    );
    _useAutoCapture = event.useAutoCapture;
    if (state is AttendanceOutsideGeofence) {
      emit(AttendanceOutsideGeofence(
        distanceAway: _distance,
        schoolName: _schoolName,
        useAutoCapture: _useAutoCapture,
      ));
    } else if (state is AttendanceReadyForFaceCapture) {
      emit(AttendanceReadyForFaceCapture(
        distance: _distance,
        schoolName: _schoolName,
        useAutoCapture: _useAutoCapture,
      ));
    } else if (state is AttendanceFaceCapturing) {
      emit(AttendanceFaceCapturing(
        distance: _distance,
        schoolName: _schoolName,
        useAutoCapture: _useAutoCapture,
      ));
    }
  }

  AttendanceFailureType _mapValidationFailureType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('no face')) {
      return AttendanceFailureType.noFaceDetected;
    }
    if (lower.contains('multiple')) {
      return AttendanceFailureType.faceNotMatched;
    }
    if (lower.contains('light')) {
      return AttendanceFailureType.lowLight;
    }
    return AttendanceFailureType.faceNotMatched;
  }

  AttendanceFailureType _failureTypeFromGeofenceFailure(Failure failure) {
    switch (failure.kind) {
      case FailureKind.httpNotFound:
        return AttendanceFailureType.featureUnavailable;
      case FailureKind.networkTimeout:
      case FailureKind.networkUnavailable:
        return AttendanceFailureType.networkError;
      case FailureKind.httpServer:
        return AttendanceFailureType.serverError;
      case FailureKind.httpClient:
        return AttendanceFailureType.authorizationError;
      case FailureKind.locationServiceDisabled:
        return AttendanceFailureType.locationServicesDisabled;
      case FailureKind.locationTimeout:
      case FailureKind.locationUnavailable:
        return AttendanceFailureType.locationUnavailable;
      case FailureKind.generic:
        final lower = failure.message.toLowerCase();
        if (lower.contains('away from school')) {
          return AttendanceFailureType.outsideGeofence;
        }
        if (lower.contains('internet') ||
            lower.contains('connection') ||
            lower.contains('network')) {
          return AttendanceFailureType.networkError;
        }
        return AttendanceFailureType.unknown;
    }
  }

  AttendanceFailureType _failureTypeFromSubmitFailure(Failure failure) {
    switch (failure.kind) {
      case FailureKind.httpNotFound:
        return AttendanceFailureType.submitUnavailable;
      case FailureKind.networkTimeout:
      case FailureKind.networkUnavailable:
        return AttendanceFailureType.networkError;
      case FailureKind.httpServer:
        return AttendanceFailureType.serverError;
      case FailureKind.httpClient:
        return AttendanceFailureType.authorizationError;
      case FailureKind.locationServiceDisabled:
      case FailureKind.locationTimeout:
      case FailureKind.locationUnavailable:
        return AttendanceFailureType.locationUnavailable;
      case FailureKind.generic:
        break;
    }
    final lower = failure.message.toLowerCase();
    if (lower.contains('already marked')) {
      return AttendanceFailureType.faceNotMatched;
    }
    if (lower.contains('away from school')) {
      return AttendanceFailureType.outsideGeofence;
    }
    if (lower.contains('network') ||
        lower.contains('internet') ||
        lower.contains('connection')) {
      return AttendanceFailureType.networkError;
    }
    return AttendanceFailureType.unknown;
  }

  static const Duration _streamGeofenceThrottle = Duration(seconds: 45);

  void _startBackgroundLocationMonitoring() {
    AttendanceLogger.log(
      'location stream: subscribing (balanced accuracy, distanceFilter 25m, '
      'throttle ${_streamGeofenceThrottle.inSeconds}s, silent refresh)',
    );
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 25,
      ),
    ).listen((_) {
      final now = DateTime.now();
      if (_lastStreamGeofenceAt != null &&
          now.difference(_lastStreamGeofenceAt!) < _streamGeofenceThrottle) {
        return;
      }
      _lastStreamGeofenceAt = now;
      add(const CheckLocationEvent(showLoading: false));
    });
  }

  @override
  Future<void> close() {
    AttendanceLogger.log('bloc close: cancel location stream');
    _positionStream?.cancel();
    return super.close();
  }
}
