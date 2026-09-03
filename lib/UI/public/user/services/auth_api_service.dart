import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService({required ApiService apiService}) : _apiService = apiService;

  // Login API call
  Future<Either<MyError, Map<String, dynamic>>> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      log('AuthApiService: Attempting login for email: $email');

      final body = <String, dynamic>{
        'email': email,
        'password': password,
      };
      if (fcmToken != null && fcmToken.isNotEmpty) {
        body['fcm_token'] = fcmToken;
        body['platform'] = _devicePlatform();
      }

      final result = await _apiService.postAPI(
        url: ApiConstants.authLoginUrl,
        body: body,
      );

      return result.fold(
        (error) {
          log('AuthApiService: Login failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          final response = json.decode(responseData);
          if (response['status'] == true) {
            log('AuthApiService: Login successful');
            return Right(response['data']);
          } else {
            log('AuthApiService: Login failed - ${response['message']}');
            return Left(
              MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Login failed',
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      log('AuthApiService: DioException during login - ${e.message}');
      return Left(
        MyError(key: AppError.apiError, message: 'Network error: ${e.message}'),
      );
    } catch (e) {
      log('AuthApiService: Unexpected error during login - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Signup API call
  Future<Either<MyError, Map<String, dynamic>>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      log('AuthApiService: Attempting signup for email: $email');

      final result = await _apiService.postAPI(
        url: ApiConstants.authRegisterUrl,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      return result.fold(
        (error) {
          log('AuthApiService: Signup failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          final response = json.decode(responseData);
          if (response['status'] == true) {
            log('AuthApiService: Signup successful');
            return Right(response['data']);
          } else {
            log('AuthApiService: Signup failed - ${response['message']}');
            return Left(
              MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Signup failed',
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      log('AuthApiService: DioException during signup - ${e.message}');
      return Left(
        MyError(key: AppError.apiError, message: 'Network error: ${e.message}'),
      );
    } catch (e) {
      log('AuthApiService: Unexpected error during signup - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Forgot Password API call
  Future<Either<MyError, Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      log('AuthApiService: Attempting forgot password for email: $email');

      final result = await _apiService.postAPI(
        url: ApiConstants.authForgotPasswordUrl,
        body: {'email': email},
      );

      return result.fold(
        (error) {
          log('AuthApiService: Forgot password failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          final response = json.decode(responseData);
          if (response['status'] == true) {
            log('AuthApiService: Forgot password request successful');
            return Right(response['data']);
          } else {
            log(
              'AuthApiService: Forgot password failed - ${response['message']}',
            );
            return Left(
              MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Forgot password failed',
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      log('AuthApiService: DioException during forgot password - ${e.message}');
      return Left(
        MyError(key: AppError.apiError, message: 'Network error: ${e.message}'),
      );
    } catch (e) {
      log('AuthApiService: Unexpected error during forgot password - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Reset Password API call
  Future<Either<MyError, Map<String, dynamic>>> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      log('AuthApiService: Attempting password reset');

      final result = await _apiService.postAPI(
        url: ApiConstants.authResetPasswordUrl,
        body: {
          'token': token,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      return result.fold(
        (error) {
          log('AuthApiService: Reset password failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          final response = json.decode(responseData);
          if (response['status'] == true) {
            log('AuthApiService: Password reset successful');
            return Right(response['data']);
          } else {
            log(
              'AuthApiService: Password reset failed - ${response['message']}',
            );
            return Left(
              MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Password reset failed',
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      log('AuthApiService: DioException during password reset - ${e.message}');
      return Left(
        MyError(key: AppError.apiError, message: 'Network error: ${e.message}'),
      );
    } catch (e) {
      log('AuthApiService: Unexpected error during password reset - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Resend Verification API call
  Future<Either<MyError, Map<String, dynamic>>> resendVerification({
    required String email,
  }) async {
    try {
      log(
        'AuthApiService: Attempting to resend verification for email: $email',
      );

      final result = await _apiService.postAPI(
        url: ApiConstants.authResendVerificationUrl,
        body: {'email': email},
      );

      return result.fold(
        (error) {
          log('AuthApiService: Resend verification failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          final response = json.decode(responseData);
          if (response['status'] == true) {
            log('AuthApiService: Resend verification successful');
            return Right(response['data']);
          } else {
            log(
              'AuthApiService: Resend verification failed - ${response['message']}',
            );
            return Left(
              MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Resend verification failed',
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      log(
        'AuthApiService: DioException during resend verification - ${e.message}',
      );
      return Left(
        MyError(key: AppError.apiError, message: 'Network error: ${e.message}'),
      );
    } catch (e) {
      log('AuthApiService: Unexpected error during resend verification - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Verify Email API call
  Future<Either<MyError, Map<String, dynamic>>> verifyEmail({
    required String token,
  }) async {
    try {
      log('AuthApiService: Attempting email verification');

      final result = await _apiService.postAPI(
        url: ApiConstants.authVerifyEmailUrl,
        body: {'token': token},
      );

      return result.fold(
        (error) {
          log('AuthApiService: Email verification failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          final response = json.decode(responseData);
          if (response['status'] == true) {
            log('AuthApiService: Email verification successful');
            return Right(response['data']);
          } else {
            log(
              'AuthApiService: Email verification failed - ${response['message']}',
            );
            return Left(
              MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Email verification failed',
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      log(
        'AuthApiService: DioException during email verification - ${e.message}',
      );
      return Left(
        MyError(key: AppError.apiError, message: 'Network error: ${e.message}'),
      );
    } catch (e) {
      log('AuthApiService: Unexpected error during email verification - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  static String _devicePlatform() => Platform.isIOS ? 'ios' : 'android';
}
