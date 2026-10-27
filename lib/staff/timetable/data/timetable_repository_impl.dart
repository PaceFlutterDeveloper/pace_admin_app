import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';
import 'package:admin_app/staff/timetable/domain/timetable_models.dart';
import 'package:admin_app/staff/timetable/domain/timetable_repository.dart';

class ApiTimetableRepository implements TimetableRepository {
  ApiTimetableRepository({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<TimetablePeriod>> week(DateTime weekStart) async {
    final body = await postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('timetable'),
      fields: {'action': 'my_week', 'week_start': ymd(weekStart)},
    );
    return [
      for (final row in listPayload(body, const ['periods', 'week']))
        TimetablePeriod.fromMap(row),
    ]..sort((a, b) {
      final byDay = a.weekday.compareTo(b.weekday);
      if (byDay != 0) return byDay;
      final byNo = a.periodNo.compareTo(b.periodNo);
      return byNo != 0 ? byNo : a.start.compareTo(b.start);
    });
  }
}
