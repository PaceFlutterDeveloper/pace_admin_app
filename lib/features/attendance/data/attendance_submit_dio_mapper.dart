import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/core/network/dio_error_mapper.dart';
import 'package:admin_app/features/attendance/constants/attendance_ui_strings.dart';
import 'package:dio/dio.dart';

/// Maps upload/submit [DioException]s to [Failure] with copy that matches the real step:
/// location and face checks already succeeded; the failure is saving to the server.
Failure mapSubmitAttendanceDioException(DioException e) {
  final status = e.response?.statusCode;
  if (status == 404) {
    return const Failure(
      AttendanceUiStrings.submitEndpointNotFound,
      kind: FailureKind.httpNotFound,
    );
  }

  final base = failureFromDioException(e);

  switch (base.kind) {
    case FailureKind.networkTimeout:
    case FailureKind.networkUnavailable:
      return Failure(
        AttendanceUiStrings.submitNetworkIssue,
        kind: base.kind,
      );
    case FailureKind.httpServer:
      return Failure(
        AttendanceUiStrings.submitServerIssue,
        kind: base.kind,
      );
    case FailureKind.httpClient:
      if (status == 401 || status == 403) {
        return Failure(
          '${AttendanceUiStrings.submitCouldNotSaveLead} ${base.message}',
          kind: FailureKind.httpClient,
        );
      }
      return const Failure(
        AttendanceUiStrings.submitRequestNotAccepted,
        kind: FailureKind.generic,
      );
    default:
      return base;
  }
}
