import 'package:admin_app/staff/timetable/domain/timetable_models.dart';

abstract class TimetableRepository {
  /// Periods for the week that starts on [weekStart] (a Monday).
  Future<List<TimetablePeriod>> week(DateTime weekStart);
}
