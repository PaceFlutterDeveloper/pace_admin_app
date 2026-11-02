import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/notices/domain/notice_models.dart';
import 'package:admin_app/staff/notices/domain/notices_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiNoticesRepository implements NoticesRepository {
  ApiNoticesRepository({required this.apiService});

  final ApiService apiService;

  Future<Map<String, dynamic>> _post(Map<String, dynamic> fields) {
    return postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('circulars'),
      fields: fields,
    );
  }

  @override
  Future<List<StaffNotice>> list() async {
    final body = await _post({'action': 'list', 'pageNo': 0, 'limit': 100});
    return [
      for (final row in listPayload(body, const ['circulars', 'notices']))
        StaffNotice.fromMap(row),
    ];
  }

  @override
  Future<StaffNotice> detail(String id) async {
    final body = await _post({'action': 'detail', 'circular_id': id});
    final data = objectPayload(body);
    if (data == null) {
      throw const StaffApiException('The circular was not returned');
    }
    return StaffNotice.fromMap(data);
  }

  @override
  Future<void> markRead(String id) async {
    await _post({'action': 'mark_read', 'circular_id': id});
  }

  @override
  Future<void> acknowledge(String id) async {
    await _post({'action': 'acknowledge', 'circular_id': id});
  }
}
