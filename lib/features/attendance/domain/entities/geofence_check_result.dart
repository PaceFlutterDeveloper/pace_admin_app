import 'package:equatable/equatable.dart';
import 'package:admin_app/features/attendance/domain/entities/geofence_config.dart';

class GeofenceCheckResult extends Equatable {
  final GeofenceConfig config;
  final double distanceMeters;
  final bool isInside;
  final double latitude;
  final double longitude;

  const GeofenceCheckResult({
    required this.config,
    required this.distanceMeters,
    required this.isInside,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        config,
        distanceMeters,
        isInside,
        latitude,
        longitude,
      ];
}
