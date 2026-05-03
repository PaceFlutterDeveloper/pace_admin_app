import 'dart:io';

import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:admin_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:dartz/dartz.dart';

class SubmitAttendanceUseCase {
  final AttendanceRepository repository;

  SubmitAttendanceUseCase(this.repository);

  Future<Either<Failure, AttendanceRecord>> call(File image) {
    AttendanceLogger.log(
      'use case: SubmitAttendance → repository (${image.path.split('/').last})',
    );
    return repository.submitAttendance(image: image);
  }
}
