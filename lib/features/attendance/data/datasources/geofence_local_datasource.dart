import 'package:admin_app/features/attendance/data/models/geofence_config_model.dart';
import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:hive/hive.dart';

class GeofenceLocalDataSource {
  static const String _settingsBox = 'settingsBox';
  static const String _geofenceKey = 'schoolGeofenceConfig';

  Future<void> cacheGeofenceConfig(GeofenceConfigModel config) async {
    AttendanceLogger.log(
      'Hive cache WRITE $_geofenceKey '
      '(school="${config.schoolName}")',
    );
    final box = await Hive.openBox(_settingsBox);
    await box.put(_geofenceKey, config.toJson());
  }

  Future<GeofenceConfigModel?> getCachedGeofenceConfig() async {
    final box = await Hive.openBox(_settingsBox);
    final raw = box.get(_geofenceKey);
    if (raw is! Map) {
      AttendanceLogger.log('Hive cache READ $_geofenceKey → miss');
      return null;
    }
    return GeofenceConfigModel.fromJson(Map<String, dynamic>.from(raw));
  }
}
