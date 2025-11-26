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

  // Error handling method
  MyError _handleError(DioException error) {
    log('--- Dio Error Handler ---');
    log('Type: ${error.type}');
    log('Status Code: ${error.response?.statusCode}');
    log('Path: ${error.requestOptions.path}');
    log('Response Data: ${error.response?.data}');

    String? errorMessage;

    // ✅ Extract readable message from response
    final responseData = error.response?.data;
    if (responseData != null) {
      try {
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ??
              responseData['error'] ??
              responseData['detail'] ??
              responseData.toString();
          log('Extracted message from Map: $errorMessage');
        } else if (responseData is String) {
          final decoded = jsonDecode(responseData);
          if (decoded is Map<String, dynamic>) {
            errorMessage = decoded['message'] ??
                decoded['error'] ??
                decoded['detail'] ??
                decoded.toString();
            log('Extracted message from JSON String: $errorMessage');
          } else {
            errorMessage = responseData;
          }
        } else {
          errorMessage = responseData.toString();
        }
      } catch (e) {
        log('Error parsing response: $e');
      }
    }

    // ✅ Fallback message
    errorMessage ??= error.message ?? 'Unknown Error';
    log('Final error message: $errorMessage');

    // ✅ Map DioExceptionType to custom error
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const MyError(
          key: AppError.unknown,
          message: 'Connection Timeout',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        switch (statusCode) {
          case 400:
            return MyError(
              key: AppError.badRequest,
              message: errorMessage ?? 'Bad Request',
            );
          case 401:
            return MyError(
              key: AppError.unauthorized,
              message: errorMessage ?? 'Unauthorized',
            );
          case 403:
            return MyError(
              key: AppError.forbidden,
              message: errorMessage ?? 'Forbidden',
            );
          case 404:
            return MyError(
              key: AppError.notFound,
              message: errorMessage ?? 'Not Found',
            );
          case 500:
            return MyError(
              key: AppError.internalServerError,
              message: errorMessage ?? 'Internal Server Error',
            );
          default:
            return MyError(
              key: AppError.unknown,
              message: errorMessage ?? 'Unexpected Error ($statusCode)',
            );
        }

      case DioExceptionType.cancel:
        return const MyError(
          key: AppError.unknown,
          message: 'Request Cancelled',
        );

      case DioExceptionType.unknown:
        // Sometimes Dio throws unknown for socket or parsing issues
        if (errorMessage.toLowerCase().contains('socket') ||
            errorMessage.toLowerCase().contains('network')) {
          return const MyError(
            key: AppError.unknown,
            message: 'No Internet Connection',
          );
        }
        return MyError(
          key: AppError.unknown,
          message: errorMessage,
        );

      default:
        return MyError(
          key: AppError.unknown,
          message: errorMessage,
        );
    }
  }
}
