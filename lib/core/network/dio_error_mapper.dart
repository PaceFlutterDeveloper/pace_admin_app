import 'package:dio/dio.dart';

import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/core/utils/debug_logger.dart';

/// Maps [DioException] to a short, user-safe [Failure] (never raw Dio paragraphs).
Failure failureFromDioException(DioException e) {
  final status = e.response?.statusCode;
  final raw = e.message ?? '';

  if (_isDioBoilerplateMessage(raw)) {
    final f =
        Failure(_messageForStatus(status, e.type), kind: _kindFor(status, e.type));
    DebugLogger.log(
      '[Network] dio_error_mapper: boilerplate msg stripped → '
      'type=${e.type} http=$status kind=${f.kind} → "${f.message}"',
    );
    return f;
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      DebugLogger.log(
        '[Network] dio_error_mapper: ${e.type} → networkTimeout',
      );
      return const Failure(
        'Connection timed out. Check your internet and try again.',
        kind: FailureKind.networkTimeout,
      );
    case DioExceptionType.connectionError:
      DebugLogger.log(
        '[Network] dio_error_mapper: connectionError → networkUnavailable',
      );
      return const Failure(
        'No internet connection. Check your network and try again.',
        kind: FailureKind.networkUnavailable,
      );
    case DioExceptionType.badResponse:
      final f = Failure(
        _messageForStatus(status, e.type),
        kind: _kindFor(status, e.type),
      );
      DebugLogger.log(
        '[Network] dio_error_mapper: badResponse http=$status → '
        'kind=${f.kind} "${f.message}"',
      );
      return f;
    default:
      if (status != null) {
        final f = Failure(
          _messageForStatus(status, e.type),
          kind: _kindFor(status, e.type),
        );
        DebugLogger.log(
          '[Network] dio_error_mapper: default+status http=$status → '
          'kind=${f.kind}',
        );
        return f;
      }
      DebugLogger.log(
        '[Network] dio_error_mapper: ${e.type} (no status) → generic',
      );
      return Failure(
        'Something went wrong. Please try again.',
        kind: FailureKind.generic,
      );
  }
}

bool _isDioBoilerplateMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('validatestatus') ||
      lower.contains('requestoptions') ||
      lower.contains('developer.mozilla.org') ||
      lower.contains('status code of');
}

String _messageForStatus(int? status, DioExceptionType type) {
  switch (status) {
    case 404:
      return 'The requested resource was not found. It may not be available yet. '
          'Try again later or contact support.';
    case 401:
    case 403:
      return 'Your session may have expired. Please sign in again.';
    case 500:
    case 502:
    case 503:
      return 'The server is temporarily unavailable. Please try again later.';
    default:
      if (status != null && status >= 400 && status < 500) {
        return 'We could not complete this request. Please try again.';
      }
      if (status != null && status >= 500) {
        return 'The server is temporarily unavailable. Please try again later.';
      }
      return 'Something went wrong. Please try again.';
  }
}

FailureKind _kindFor(int? status, DioExceptionType type) {
  if (type == DioExceptionType.connectionTimeout ||
      type == DioExceptionType.sendTimeout ||
      type == DioExceptionType.receiveTimeout) {
    return FailureKind.networkTimeout;
  }
  if (type == DioExceptionType.connectionError) {
    return FailureKind.networkUnavailable;
  }
  if (status == 404) {
    return FailureKind.httpNotFound;
  }
  if (status != null && status >= 500) {
    return FailureKind.httpServer;
  }
  if (status != null && status >= 400) {
    return FailureKind.httpClient;
  }
  return FailureKind.generic;
}
