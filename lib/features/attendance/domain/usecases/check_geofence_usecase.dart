import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/features/attendance/domain/entities/geofence_check_result.dart';
import 'package:admin_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:dartz/dartz.dart';

class CheckGeofenceUseCase {
  final AttendanceRepository repository;

  CheckGeofenceUseCase(this.repository);

  Future<Either<Failure, GeofenceCheckResult>> call() {
    return repository.checkGeofence();
  }
}
