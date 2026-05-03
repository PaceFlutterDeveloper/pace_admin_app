import 'package:admin_app/features/attendance/data/models/geofence_config_model.dart';

/// Default campus boundary when the geofence API is unavailable and Hive has no cache.
abstract final class AttendanceGeofenceFallback {
  static const double centerLatitude = 25.295880;
  static const double centerLongitude = 55.458018;

  /// Approximate radius when the server does not supply `radiusMeters`.
  static const double radiusMeters = 250;

  static const String schoolName = 'School campus';

  static GeofenceConfigModel get asModel => const GeofenceConfigModel(
        schoolName: schoolName,
        centerLatitude: centerLatitude,
        centerLongitude: centerLongitude,
        radiusMeters: radiusMeters,
      );
}
