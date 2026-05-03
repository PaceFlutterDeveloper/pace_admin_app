import 'dart:io';

import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/features/attendance/data/models/attendance_record_model.dart';
import 'package:admin_app/features/attendance/data/models/geofence_config_model.dart';
import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:dio/dio.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource({required this.dio});

  /// Bound HTTP waits so a hung server cannot block geofence forever.
  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _geofenceReceiveTimeout = Duration(seconds: 25);
  static const Duration _submitSendTimeout = Duration(seconds: 120);
  static const Duration _submitReceiveTimeout = Duration(seconds: 60);

  Future<GeofenceConfigModel> getSchoolGeofence({
    required String token,
  }) async {
    final baseUrl = await ApiConstants.getBaseUrl();
    final url = '${baseUrl}config/school-geofence';
    AttendanceLogger.log('remote GET school-geofence → $url');
    final response = await dio.get<dynamic>(
      url,
      options: Options(
        // Avoid Dio's long default message for 4xx/5xx; repository maps status codes.
        validateStatus: (status) => status != null && status < 600,
        connectTimeout: _connectTimeout,
        receiveTimeout: _geofenceReceiveTimeout,
        headers: {
          'Accept': 'application/json',
          'token': token,
        },
      ),
    );
    AttendanceLogger.log(
      'remote GET school-geofence ← HTTP ${response.statusCode}',
    );
    if (response.statusCode != null &&
        response.statusCode! >= 400 &&
        response.statusCode! < 600) {
      AttendanceLogger.log(
        'remote GET school-geofence: 4xx/5xx → throwing DioException',
      );
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    if (response.data is! Map<String, dynamic>) {
      AttendanceLogger.log(
        'remote GET school-geofence: invalid JSON shape (expected object)',
      );
      throw const FormatException('Invalid geofence response format');
    }
    AttendanceLogger.log('remote GET school-geofence: parsing JSON → GeofenceConfigModel');
    return GeofenceConfigModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AttendanceRecordModel> submitAttendance({
    required String token,
    required String employeeId,
    required String schoolName,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required File image,
    String? capturedImagePath,
  }) async {
    final baseUrl = await ApiConstants.getBaseUrl();
    final url = '${baseUrl}attendance/mark';
    AttendanceLogger.log(
      'remote POST attendance/mark → $url '
      '(employeeId=$employeeId, lat=$latitude, lng=$longitude)',
    );
    final formData = FormData.fromMap({
      'employee_id': employeeId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.uri.pathSegments.last,
      ),
    });
    final response = await dio.post<dynamic>(
      url,
      data: formData,
      options: Options(
        validateStatus: (status) => status != null && status < 600,
        connectTimeout: _connectTimeout,
        sendTimeout: _submitSendTimeout,
        receiveTimeout: _submitReceiveTimeout,
        headers: {
          'Accept': 'application/json',
          'token': token,
        },
      ),
    );
    AttendanceLogger.log(
      'remote POST attendance/mark ← HTTP ${response.statusCode}',
    );
    if (response.statusCode != null &&
        response.statusCode! >= 400 &&
        response.statusCode! < 600) {
      AttendanceLogger.log(
        'remote POST attendance/mark: error status → throwing DioException',
      );
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    if (response.data is! Map<String, dynamic>) {
      AttendanceLogger.log(
        'remote POST attendance/mark: invalid JSON shape (expected object)',
      );
      throw const FormatException('Invalid attendance response format');
    }
    final body = response.data as Map<String, dynamic>;
    final success = body['success'] == true;
    final matched = body['matched'] == true;
    if (!success || !matched) {
      final msg = (body['message'] ?? 'Face not matched').toString();
      AttendanceLogger.log(
        'remote POST attendance/mark: success=$success matched=$matched → $msg',
      );
      throw StateError(msg);
    }
    AttendanceLogger.log(
      'remote POST attendance/mark: matched=true — building AttendanceRecordModel',
    );
    return AttendanceRecordModel.fromJson(
      body,
      employeeId: employeeId,
      schoolName: schoolName,
      capturedImagePath: capturedImagePath,
    );
  }
}
