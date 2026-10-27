import 'package:admin_app/staff/face_attendance/data/models/geofence_config_model.dart';
import 'package:admin_app/staff/face_attendance/utils/attendance_logger.dart';
import 'package:hive/hive.dart';

class GeofenceLocalDataSource {
  static const String _settingsBox = 'settingsBox';
  static const String _geofenceKey = 'schoolGeofenceConfig';

  /// One fence per school, so switching accounts cannot reuse another campus.
  String _cacheKey(Box box) {
    final school = box.get('schoolCode')?.toString().trim() ?? '';
    return school.isEmpty ? _geofenceKey : '$_geofenceKey:$school';
  }

  Future<void> cacheGeofenceConfig(GeofenceConfigModel config) async {
    final box = await Hive.openBox(_settingsBox);
    final key = _cacheKey(box);
    AttendanceLogger.log(
      'Hive cache WRITE $key '
      '(school="${config.schoolName}")',
    );
    await box.put(key, config.toJson());
  }

  Future<GeofenceConfigModel?> getCachedGeofenceConfig() async {
    final box = await Hive.openBox(_settingsBox);
    final key = _cacheKey(box);
    final raw = box.get(key);
    if (raw is! Map) {
      AttendanceLogger.log('Hive cache READ $key → miss');
      return null;
    }
    return GeofenceConfigModel.fromJson(Map<String, dynamic>.from(raw));
  }
}
