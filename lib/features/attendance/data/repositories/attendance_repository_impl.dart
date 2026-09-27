import 'dart:io';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/features/attendance/data/attendance_submit_dio_mapper.dart';
import 'package:admin_app/core/utils/constants/attendance_geofence_constants.dart';
import 'package:admin_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:admin_app/features/attendance/data/datasources/geofence_local_datasource.dart';
import 'package:admin_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:admin_app/features/attendance/domain/entities/geofence_check_result.dart';
import 'package:admin_app/features/attendance/domain/entities/geofence_config.dart';
import 'package:admin_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final GeofenceLocalDataSource localDataSource;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, GeofenceConfig>> getGeofenceConfig({
    bool forceRefresh = false,
  }) async {
    final user = await AuthData.getActiveUser();
    if (user == null) {
      AttendanceLogger.log('getGeofenceConfig: no active user → failure');
      return const Left(Failure('Unable to find active employee session'));
    }
    try {
      if (!forceRefresh) {
        final cached = await localDataSource.getCachedGeofenceConfig();
        if (cached != null) {
          return Right(cached);
        }
        AttendanceLogger.log('getGeofenceConfig: no Hive cache, fetching remote');
      } else {
        AttendanceLogger.log('getGeofenceConfig: forceRefresh skip cache, fetching remote');
      }
      final config =
          await remoteDataSource.getSchoolGeofence(token: user.token);
      await localDataSource.cacheGeofenceConfig(config);
      AttendanceLogger.log(
        'getGeofenceConfig: remote OK, cached to Hive '
        '(school="${config.schoolName}")',
      );
      return Right(config);
    } on DioException {
      AttendanceLogger.log(
        'getGeofenceConfig: DioException — trying stale cache then fallback',
      );
      final stale = await localDataSource.getCachedGeofenceConfig();
      if (stale != null) {
        AttendanceLogger.log(
          'getGeofenceConfig: using stale Hive after remote error',
        );
        return Right(stale);
      }
      final fallback = AttendanceGeofenceFallback.asModel;
      await localDataSource.cacheGeofenceConfig(fallback);
      AttendanceLogger.log(
        'getGeofenceConfig: no cache — using built-in fallback coords '
        '(${fallback.centerLatitude}, ${fallback.centerLongitude}), '
        'r=${fallback.radiusMeters}m, cached',
      );
      return Right(fallback);
    } catch (e, st) {
      AttendanceLogger.log(
        'getGeofenceConfig: unexpected error ($e) — trying stale then fallback',
      );
      AttendanceLogger.log('getGeofenceConfig stack: $st');
      final stale = await localDataSource.getCachedGeofenceConfig();
      if (stale != null) {
        AttendanceLogger.log(
          'getGeofenceConfig: using stale Hive after parse/other error',
        );
        return Right(stale);
      }
      final fallback = AttendanceGeofenceFallback.asModel;
      await localDataSource.cacheGeofenceConfig(fallback);
      AttendanceLogger.log(
        'getGeofenceConfig: no cache — using fallback coords + cached',
      );
      return Right(fallback);
    }
  }

  @override
  Future<Either<Failure, GeofenceCheckResult>> checkGeofence() async {
    AttendanceLogger.log(
      'checkGeofence: location services omitted from this release',
    );
    return const Left(
      Failure(
        'Location services are not available in this version.',
        kind: FailureKind.locationUnavailable,
      ),
    );
  }

  @override
  Future<Either<Failure, AttendanceRecord>> submitAttendance({
    required File image,
  }) async {
    final user = await AuthData.getActiveUser();
    if (user == null) {
      return const Left(Failure('Unable to find active employee session'));
    }

    AttendanceLogger.log('submitAttendance: starting (verify geofence + upload)');
    final geofenceResult = await checkGeofence();
    return await geofenceResult.fold(
      (failure) async {
        AttendanceLogger.log(
          'submitAttendance: blocked — geofence step failed: ${failure.message}',
        );
        return Left(failure);
      },
      (geofence) async {
        if (!geofence.isInside) {
          AttendanceLogger.log(
            'submitAttendance: blocked — outside radius '
            '(${geofence.distanceMeters.toStringAsFixed(0)}m)',
          );
          return Left(
            Failure(
              'You are ${(geofence.distanceMeters).toStringAsFixed(0)}m away from school',
            ),
          );
        }

        AttendanceLogger.log(
          'submitAttendance: inside geofence — uploading face + metadata…',
        );
        try {
          final record = await remoteDataSource.submitAttendance(
            token: user.token,
            employeeId: user.userId,
            schoolName: geofence.config.schoolName,
            latitude: geofence.latitude,
            longitude: geofence.longitude,
            timestamp: DateTime.now(),
            image: image,
            capturedImagePath: image.path,
          );
          AttendanceLogger.log(
            'submitAttendance: server accepted attendance '
            '(attendanceId=${record.attendanceId})',
          );
          return Right(record);
        } on StateError catch (e) {
          AttendanceLogger.log(
            'submitAttendance: face verification rejected — ${e.message}',
          );
          return Left(Failure(e.message));
        } on DioException catch (e) {
          AttendanceLogger.log(
            'submitAttendance: HTTP error type=${e.type} '
            'status=${e.response?.statusCode}',
          );
          return Left(mapSubmitAttendanceDioException(e));
        } catch (e, st) {
          AttendanceLogger.log('submitAttendance: unexpected error: $e');
          AttendanceLogger.log('submitAttendance stack: $st');
          return const Left(Failure('Unable to mark attendance right now'));
        }
      },
    );
  }
}
