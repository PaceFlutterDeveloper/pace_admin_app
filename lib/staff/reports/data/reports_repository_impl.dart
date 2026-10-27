import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/reports/domain/report_models.dart';
import 'package:admin_app/staff/reports/domain/reports_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiReportsRepository implements ReportsRepository {
  ApiReportsRepository({required this.apiService});

  final ApiService apiService;

  Future<Map<String, dynamic>> _post(Map<String, dynamic> fields) {
    return postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('reports'),
      fields: fields,
    );
  }

  @override
  Future<List<ReportInfo>> available() async {
    final body = await _post({'action': 'list'});
    return [
      for (final row in listPayload(body, const ['reports']))
        ReportInfo.fromMap(row),
    ];
  }

  @override
  Future<ReportResult> run(
    String key, {
    required DateTime from,
    required DateTime to,
  }) async {
    final body = await _post({
      'action': 'run',
      'report_key': key,
      'from': ymd(from),
      'to': ymd(to),
    });
    final data = objectPayload(body);
    if (data == null) {
      throw const StaffApiException('The report did not return any data');
    }
    return ReportResult.fromData(data);
  }
}
