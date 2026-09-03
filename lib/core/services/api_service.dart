import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/careers_session_expired_handler.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class ApiService {
  final Dio _dio;

  ApiService({required Dio dio}) : _dio = dio;

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Options _requestOptions({
    required String method,
    required String url,
    required Map<String, dynamic> headers,
    Map<String, dynamic>? queryParameters,
  }) {
    final tag = _buildApiTag(method, url, queryParameters);
    return Options(
      method: method,
      headers: headers,
      responseType: ResponseType.plain,
      extra: {'api_tag': tag},
    );
  }

  String _buildApiTag(
    String method,
    String url,
    Map<String, dynamic>? queryParameters,
  ) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return '$method $url';
    }

    final query = queryParameters.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    return '$method $url?$query';
  }

  /// Strips PHP warnings / HTML noise that some careers endpoints prepend to JSON.
  static String extractJsonPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) return trimmed;

    final objectStart = trimmed.indexOf('{');
    final arrayStart = trimmed.indexOf('[');
    final start = objectStart == -1
        ? arrayStart
        : arrayStart == -1
            ? objectStart
            : objectStart < arrayStart
                ? objectStart
                : arrayStart;
    if (start == -1) return trimmed;

    final isObject = trimmed[start] == '{';
    final end = isObject ? trimmed.lastIndexOf('}') : trimmed.lastIndexOf(']');
    if (end <= start) return trimmed.substring(start).trim();
    return trimmed.substring(start, end + 1);
  }

  String _normalizeResponseBody(dynamic data) {
    if (data == null) return '';
    if (data is Map || data is List) return json.encode(data);
    return extractJsonPayload(data.toString());
  }

  // GET request
  Future<Either<MyError, dynamic>> getRequest(
    String endpoint,
    String? token, {
    Map<String, dynamic>? queryParameters,
    bool useSessionToken = false,
  }) async {
    try {
      final headers = <String, dynamic>{..._jsonHeaders};
      if (token != null) {
        if (useSessionToken) {
          headers['X-Session-Token'] = token;
        } else {
          headers['token'] = token;
        }
      }
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: _requestOptions(
          method: 'GET',
          url: endpoint,
          headers: headers,
          queryParameters: queryParameters,
        ),
      );
      return Right(_normalizeResponseBody(response.data));
    } on DioException catch (e) {
      _handleCareersSessionExpiry(e, useSessionToken: useSessionToken);
      return Left(_handleError(e));
    }
  }

  // POST request
  Future<Either<MyError, dynamic>> postAPI({
    dynamic body,
    String url = '',
    String authorization = '',
    bool useSessionToken = false,
  }) async {
    final headers = <String, dynamic>{'Accept': 'application/json'};
    if (body is! FormData) {
      headers.addAll(_jsonHeaders);
    }
    if (authorization.isNotEmpty) {
      if (useSessionToken) {
        headers['X-Session-Token'] = authorization;
      } else {
        headers['token'] = authorization;
      }
    }

    try {
      final response = await _dio.post(
        url,
        data: body,
        options: _requestOptions(
          method: 'POST',
          url: url,
          headers: headers,
        ),
      );

      return Right(_normalizeResponseBody(response.data));
    } on DioException catch (e) {
      _handleCareersSessionExpiry(e, useSessionToken: useSessionToken);
      return Left(_handleError(e));
    } catch (e) {
      log('postAPI non-Dio error: $e (${e.runtimeType})');
      return Left(MyError(
        key: AppError.unknown,
        message: e.toString(),
      ));
    }
  }

  // PUT request
  Future<Either<MyError, dynamic>> putRequest(
    String endpoint,
    String? token,
    dynamic data,
  ) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: _requestOptions(
          method: 'PUT',
          url: endpoint,
          headers: {
            ..._jsonHeaders,
            'token': token,
          },
        ),
      );
      return Right(_normalizeResponseBody(response.data));
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // DELETE request
  Future<Either<MyError, dynamic>> deleteRequest(
    String endpoint,
    String? token,
  ) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: _requestOptions(
          method: 'DELETE',
          url: endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'token': token,
          },
        ),
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // Helper method to extract text from HTML responses
  String _extractTextFromHtml(String html) {
    try {
      // Remove HTML tags using regex
      String text = html
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll(RegExp(r'&nbsp;'), ' ') // Replace &nbsp; with space
          .replaceAll(RegExp(r'&amp;'), '&') // Replace &amp; with &
          .replaceAll(RegExp(r'&lt;'), '<') // Replace &lt; with <
          .replaceAll(RegExp(r'&gt;'), '>') // Replace &gt; with >
          .replaceAll(RegExp(r'&quot;'), '"') // Replace &quot; with "
          .replaceAll(RegExp(r'&#39;'), "'") // Replace &#39; with '
          .trim();

      // Clean up multiple spaces/newlines
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

      // If we extracted meaningful text, return it
      if (text.isNotEmpty && text.length > 10) {
        return text;
      }
    } catch (e) {
      log('Error extracting text from HTML: $e');
    }
    return html; // Fallback to original if extraction fails
  }

  // Helper method to get user-friendly error message
  String _getUserFriendlyMessage(AppError errorKey, String? rawMessage) {
    // If we have a raw message, try to extract meaningful text
    if (rawMessage != null && rawMessage.isNotEmpty) {
      // Check if it's HTML
      if (rawMessage.contains('<') && rawMessage.contains('>')) {
        final extracted = _extractTextFromHtml(rawMessage);
        // If extraction gave us something meaningful, use it
        if (extracted.length > 10 && extracted != rawMessage) {
          return extracted;
        }
      }
      // If it's a long technical message, provide a user-friendly one
      if (rawMessage.length > 100 || 
          rawMessage.contains('Exception') ||
          rawMessage.contains('status code')) {
        // Use a friendly message based on error type
        switch (errorKey) {
          case AppError.internalServerError:
            return 'Server error occurred. Please try again later or contact support if the problem persists.';
          case AppError.badRequest:
            return 'Invalid request. Please check your input and try again.';
          case AppError.unauthorized:
            return 'Your session has expired. Please log in again.';
          case AppError.forbidden:
            return 'You don\'t have permission to perform this action.';
          case AppError.notFound:
            return 'The requested resource was not found.';
          case AppError.conflict:
            return 'This action conflicts with existing data.';
          default:
            return 'Something went wrong. Please try again.';
        }
      }
      return rawMessage;
    }

    // Default messages based on error type
    switch (errorKey) {
      case AppError.internalServerError:
        return 'Server error occurred. Please try again later or contact support if the problem persists.';
      case AppError.badRequest:
        return 'Invalid request. Please check your input and try again.';
      case AppError.unauthorized:
        return 'Your session has expired. Please log in again.';
      case AppError.forbidden:
        return 'You don\'t have permission to perform this action.';
      case AppError.notFound:
        return 'The requested resource was not found.';
      case AppError.conflict:
        return 'This action conflicts with existing data.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void _handleCareersSessionExpiry(
    DioException error, {
    required bool useSessionToken,
  }) {
    if (!useSessionToken) return;
    if (!CareersSessionExpiredHandler.isExpiredSessionError(error)) return;
    CareersSessionExpiredHandler.handleExpired();
  }

  // Error handling method
  MyError _handleError(DioException error) {
    String? rawErrorMessage;
    AppError errorKey = AppError.unknown;

    // ✅ Extract readable message from response
    final responseData = error.response?.data;
    if (responseData != null) {
      try {
        if (responseData is Map<String, dynamic>) {
          rawErrorMessage = responseData['message'] ??
              responseData['error'] ??
              responseData['detail'] ??
              responseData.toString();
        } else if (responseData is String) {
          final jsonPayload = extractJsonPayload(responseData);
          // Check if it's HTML
          if (jsonPayload.contains('<') && jsonPayload.contains('>')) {
            rawErrorMessage = responseData;
          } else {
            // Try to parse as JSON
            try {
              final decoded = jsonDecode(jsonPayload);
              if (decoded is Map<String, dynamic>) {
                rawErrorMessage = decoded['message'] ??
                    decoded['error'] ??
                    decoded['detail'] ??
                    decoded.toString();
              } else {
                rawErrorMessage = jsonPayload;
              }
            } catch (e) {
              // Not JSON, use as-is
              rawErrorMessage = responseData;
            }
          }
        } else {
          rawErrorMessage = responseData.toString();
        }
      } catch (e) {
        rawErrorMessage = responseData.toString();
      }
    }

    // ✅ Fallback: Dio message, then the underlying transport error (e.g. SocketException)
    rawErrorMessage ??=
        error.message ?? error.error?.toString() ?? 'Unknown Error';

    // ✅ Map DioExceptionType to custom error
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const MyError(
          key: AppError.unknown,
          message: 'Connection timeout. Please check your internet connection and try again.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        switch (statusCode) {
          case 400:
            errorKey = AppError.badRequest;
            break;
          case 401:
            errorKey = AppError.unauthorized;
            break;
          case 403:
            errorKey = AppError.forbidden;
            break;
          case 404:
            errorKey = AppError.notFound;
            break;
          case 409:
            errorKey = AppError.conflict;
            break;
          case 500:
            errorKey = AppError.internalServerError;
            break;
          default:
            errorKey = AppError.unknown;
        }
        final userFriendlyMessage = _getUserFriendlyMessage(errorKey, rawErrorMessage);
        return MyError(
          key: errorKey,
          message: userFriendlyMessage,
        );

      case DioExceptionType.cancel:
        return const MyError(
          key: AppError.unknown,
          message: 'Request was cancelled. Please try again.',
        );

      case DioExceptionType.unknown:
        // Sometimes Dio throws unknown for socket or parsing issues
        if (rawErrorMessage.toLowerCase().contains('formatexception')) {
          final userFriendlyMessage =
              _getUserFriendlyMessage(AppError.internalServerError, rawErrorMessage);
          return MyError(
            key: AppError.internalServerError,
            message: userFriendlyMessage,
          );
        }
        if (rawErrorMessage.toLowerCase().contains('socket') ||
            rawErrorMessage.toLowerCase().contains('network') ||
            rawErrorMessage.toLowerCase().contains('connection')) {
          return const MyError(
            key: AppError.unknown,
            message: 'No internet connection. Please check your network and try again.',
          );
        }
        final userFriendlyMessage = _getUserFriendlyMessage(AppError.unknown, rawErrorMessage);
        return MyError(
          key: AppError.unknown,
          message: userFriendlyMessage,
        );

      default:
        final userFriendlyMessage = _getUserFriendlyMessage(AppError.unknown, rawErrorMessage);
        return MyError(
          key: AppError.unknown,
          message: userFriendlyMessage,
        );
    }
  }
}
