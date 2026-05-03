import 'dart:io';

import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:admin_app/features/attendance/domain/entities/geofence_check_result.dart';
import 'package:admin_app/features/attendance/domain/entities/geofence_config.dart';
import 'package:dartz/dartz.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, GeofenceConfig>> getGeofenceConfig({
    bool forceRefresh = false,
  });

  Future<Either<Failure, GeofenceCheckResult>> checkGeofence();

  Future<Either<Failure, AttendanceRecord>> submitAttendance({
    required File image,
  });
}
