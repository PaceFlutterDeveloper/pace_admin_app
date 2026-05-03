import 'dart:io';

import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/core/utils/debug_logger.dart';
import 'package:admin_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:admin_app/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:admin_app/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:admin_app/features/attendance/presentation/widgets/attendance_step_indicator.dart';
import 'package:admin_app/features/attendance/presentation/widgets/attendance_success_widget.dart';
import 'package:admin_app/features/attendance/presentation/widgets/face_capture_widget.dart';
import 'package:admin_app/features/attendance/presentation/widgets/geofence_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendancePage extends StatefulWidget {
  final String title;

  const AttendancePage({
    super.key,
    this.title = 'Attendance',
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const InitializeAttendanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) async {
        if (state is AttendanceFailure &&
            state.type ==
                AttendanceFailureType.permissionsPermanentlyDenied) {
          final openSettings = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Permission Required'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Later'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
          if (openSettings == true && context.mounted) {
            DebugLogger.log(
              '[Attendance] UI: opening system Settings (permissions blocked)',
            );
            await openAppSettings();
          }
        }
      },
      builder: (context, state) {
        final step = _stepFromState(state);
        final isCapturing = state is AttendanceFaceCapturing;
        final isVerifying = state is AttendanceVerifyingFace;
        return PopScope(
          canPop: !isVerifying,
          child: Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            backgroundColor:
                isCapturing ? Colors.black : ConstColors.backgroundColor,
            body: SafeArea(
              child: isCapturing
                  ? _buildCaptureView(context, state)
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          AttendanceStepIndicator(currentStep: step),
                          const SizedBox(height: 16),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildBody(context, state),
                            ),
                          ),
                          if (isVerifying)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'Verifying identity...',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCaptureView(BuildContext context, AttendanceState state) {
    final captureState = state as AttendanceFaceCapturing;
    return FaceCaptureWidget(
      useAutoCapture: captureState.useAutoCapture,
      onCaptureModeChanged: (value) {
        context.read<AttendanceBloc>().add(ToggleCaptureModeEvent(value));
      },
      onCancel: () =>
          context.read<AttendanceBloc>().add(const CheckLocationEvent()),
      onCapture: (file, sensorOrientation) => context
          .read<AttendanceBloc>()
          .add(FaceCapturedEvent(file, sensorOrientation: sensorOrientation)),
    );
  }

  Widget _buildBody(BuildContext context, AttendanceState state) {
    if (state is AttendanceCheckingLocation || state is AttendanceInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Verifying your location...'),
          ],
        ),
      );
    }

    if (state is AttendanceOutsideGeofence) {
      return GeofenceStatusWidget(
        isInside: false,
        distanceMeters: state.distanceAway,
        schoolName: state.schoolName,
        primaryLabel: 'Check Location',
        onPrimaryAction: () {
          context.read<AttendanceBloc>().add(const CheckLocationEvent());
        },
        onRetry: () =>
            context.read<AttendanceBloc>().add(const RetryAttendanceEvent()),
      );
    }

    if (state is AttendanceReadyForFaceCapture) {
      return GeofenceStatusWidget(
        isInside: true,
        distanceMeters: state.distance,
        schoolName: state.schoolName,
        primaryLabel: 'Start Face Scan',
        onPrimaryAction: () {
          context.read<AttendanceBloc>().add(const StartFaceCaptureEvent());
        },
        onRetry: () =>
            context.read<AttendanceBloc>().add(const CheckLocationEvent()),
      );
    }

    if (state is AttendanceVerifyingFace) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (state.imagePath.isNotEmpty)
            Image.file(
              File(state.imagePath),
              fit: BoxFit.cover,
            ),
          Container(color: Colors.black.withValues(alpha: 0.55)),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Verifying identity...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state is AttendanceSuccess) {
      return AttendanceSuccessWidget(
        record: state.record,
        onDone: () {
          if (!context.mounted) return;
          if (context.canPop()) {
            context.pop();
          }
        },
      );
    }

    if (state is AttendanceFailure) {
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForFailure(state.type),
                color: _colorForFailure(state.type),
                size: 42,
              ),
              const SizedBox(height: 10),
              Text(
                _clampedUserMessage(state.message),
                textAlign: TextAlign.center,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => context
                    .read<AttendanceBloc>()
                    .add(const RetryAttendanceEvent()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 0 = location phase, 1 = face phase (including ready-to-scan), 2 = done.
  int _stepFromState(AttendanceState state) {
    if (state is AttendanceSuccess) {
      return 2;
    }
    if (state is AttendanceFaceCapturing ||
        state is AttendanceVerifyingFace ||
        state is AttendanceReadyForFaceCapture) {
      return 1;
    }
    if (state is AttendanceFailure) {
      return _stepIndexForFailure(state.type);
    }
    return 0;
  }

  /// Keep the strip aligned with how far the user got (e.g. submit errors stay on face/submit step).
  int _stepIndexForFailure(AttendanceFailureType type) {
    switch (type) {
      case AttendanceFailureType.permissionsDenied:
      case AttendanceFailureType.permissionsPermanentlyDenied:
      case AttendanceFailureType.locationServicesDisabled:
      case AttendanceFailureType.locationUnavailable:
      case AttendanceFailureType.featureUnavailable:
      case AttendanceFailureType.outsideGeofence:
        return 0;
      default:
        return 1;
    }
  }

  IconData _iconForFailure(AttendanceFailureType type) {
    switch (type) {
      case AttendanceFailureType.permissionsDenied:
      case AttendanceFailureType.permissionsPermanentlyDenied:
      case AttendanceFailureType.locationServicesDisabled:
      case AttendanceFailureType.locationUnavailable:
      case AttendanceFailureType.outsideGeofence:
        return Icons.location_off_rounded;
      case AttendanceFailureType.noFaceDetected:
      case AttendanceFailureType.faceNotMatched:
        return Icons.face_retouching_off_rounded;
      case AttendanceFailureType.networkError:
        return Icons.wifi_off_rounded;
      case AttendanceFailureType.featureUnavailable:
        return Icons.schedule_rounded;
      case AttendanceFailureType.submitUnavailable:
        return Icons.cloud_off_rounded;
      case AttendanceFailureType.serverError:
        return Icons.cloud_off_rounded;
      case AttendanceFailureType.authorizationError:
        return Icons.lock_outline_rounded;
      case AttendanceFailureType.cameraError:
        return Icons.camera_alt_outlined;
      case AttendanceFailureType.lowLight:
        return Icons.lightbulb_outline_rounded;
      case AttendanceFailureType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  Color _colorForFailure(AttendanceFailureType type) {
    switch (type) {
      case AttendanceFailureType.outsideGeofence:
        return Colors.orange;
      case AttendanceFailureType.faceNotMatched:
      case AttendanceFailureType.noFaceDetected:
        return Colors.red;
      case AttendanceFailureType.networkError:
        return Colors.blueGrey;
      case AttendanceFailureType.featureUnavailable:
        return Colors.teal;
      case AttendanceFailureType.submitUnavailable:
        return Colors.indigo;
      case AttendanceFailureType.serverError:
      case AttendanceFailureType.authorizationError:
        return Colors.deepPurple;
      default:
        return Colors.deepOrange;
    }
  }

  static const int _kMaxFailureMessageChars = 280;

  String _clampedUserMessage(String message) {
    if (message.length <= _kMaxFailureMessageChars) return message;
    return '${message.substring(0, _kMaxFailureMessageChars - 1)}…';
  }
}
