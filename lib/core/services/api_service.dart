import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class ApiService {
  final Dio _dio;

  ApiService({required Dio dio}) : _dio = dio;

  // GET request
  Future<Either<MyError, dynamic>> getRequest(
    String endpoint,
    String? token, {
    Map<String, dynamic>? queryParameters,
    bool useSessionToken = false,
  }) async {
    try {
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null) {
        if (useSessionToken) {
          headers['X-Session-Token'] = token;
        } else {
          headers['token'] = token;
        }
      }
      _dio.options = BaseOptions(headers: headers);
      final response =
          await _dio.get(endpoint, queryParameters: queryParameters);
      log(endpoint);
      return Right(json.encode(response.data));
    } on DioException catch (e) {
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
    try {
      log('Making POST request to: $url');
      log('Request body: $body');
      log('Authorization token: ${authorization.isNotEmpty ? 'provided' : 'empty'}');
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (authorization.isNotEmpty) {
        if (useSessionToken) {
          headers['X-Session-Token'] = authorization;
        } else {
          headers['token'] = authorization;
        }
      }
      _dio.options = BaseOptions(headers: headers);
      final response = await _dio.post(url, data: body);
      log('Response: ${response.statusCode}');
      log('Response data: ${response.data}');
      log(url);
      return Right(json.encode(response.data));
    } on DioException catch (e) {
      log('Caught DioException in postAPI');
      log('Exception type: ${e.type}');
      log('Exception message: ${e.message}');
      log('Exception response: ${e.response?.data}');
      log('Exception status code: ${e.response?.statusCode}');
      log('Request URL: ${e.requestOptions.uri}');
      log('Request method: ${e.requestOptions.method}');
      log('Request data: ${e.requestOptions.data}');
      log('Stack trace: ${e.stackTrace}');
      return Left(_handleError(e));
    } catch (e) {
      log('Caught non-DioException in postAPI: ${e.toString()}');
      log('Exception type: ${e.runtimeType}');
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
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token
        },
      );
      final response = await _dio.put(endpoint, data: data);
      return Right(json.encode(response.data));
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
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token
        },
      );
      final response = await _dio.delete(endpoint);
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
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // Error handling method
  MyError _handleError(DioException error) {
    log('--- Dio Error Handler ---');
    log('Type: ${error.type}');
    log('Status Code: ${error.response?.statusCode}');
    log('Path: ${error.requestOptions.path}');
    log('Response Data: ${error.response?.data}');

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
          log('Extracted message from Map: $rawErrorMessage');
        } else if (responseData is String) {
          // Check if it's HTML
          if (responseData.contains('<') && responseData.contains('>')) {
            rawErrorMessage = responseData;
            log('Detected HTML response');
          } else {
            // Try to parse as JSON
            try {
              final decoded = jsonDecode(responseData);
              if (decoded is Map<String, dynamic>) {
                rawErrorMessage = decoded['message'] ??
                    decoded['error'] ??
                    decoded['detail'] ??
                    decoded.toString();
                log('Extracted message from JSON String: $rawErrorMessage');
              } else {
                rawErrorMessage = responseData;
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
        log('Error parsing response: $e');
        rawErrorMessage = responseData.toString();
      }
    }

    // ✅ Fallback message
    rawErrorMessage ??= error.message ?? 'Unknown Error';
    log('Raw error message: $rawErrorMessage');

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
          case 500:
            errorKey = AppError.internalServerError;
            break;
          default:
            errorKey = AppError.unknown;
        }
        final userFriendlyMessage = _getUserFriendlyMessage(errorKey, rawErrorMessage);
        log('Final error message: $userFriendlyMessage');
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
