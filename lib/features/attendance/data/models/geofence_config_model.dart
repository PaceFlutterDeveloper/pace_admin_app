import 'package:admin_app/features/attendance/domain/entities/geofence_config.dart';

class GeofenceConfigModel extends GeofenceConfig {
  const GeofenceConfigModel({
    required super.schoolName,
    required super.centerLatitude,
    required super.centerLongitude,
    required super.radiusMeters,
  });

  factory GeofenceConfigModel.fromJson(Map<String, dynamic> json) {
    return GeofenceConfigModel(
      schoolName: (json['schoolName'] ?? '').toString(),
      centerLatitude: (json['centerLatitude'] as num?)?.toDouble() ?? 0,
      centerLongitude: (json['centerLongitude'] as num?)?.toDouble() ?? 0,
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolName': schoolName,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'radiusMeters': radiusMeters,
    };
  }
}
