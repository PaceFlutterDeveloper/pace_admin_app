import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/directory/domain/directory_repository.dart';
import 'package:admin_app/staff/directory/domain/staff_member.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiDirectoryRepository implements DirectoryRepository {
  ApiDirectoryRepository({required this.apiService});

  final ApiService apiService;

  static const pageSize = 40;

  Future<Map<String, dynamic>> _post(Map<String, dynamic> fields) {
    return postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('staff'),
      fields: fields,
    );
  }

  @override
  Future<StaffPageResult> list({String search = '', int page = 0}) async {
    final body = await _post({
      'action': 'list',
      if (search.trim().isNotEmpty) 'search': search.trim(),
      'pageNo': page,
      'limit': pageSize,
    });
    final items = [
      for (final row in listPayload(body, const ['staff']))
        StaffMember.fromMap(row),
    ];
    return StaffPageResult(
      items: items,
      hasMore: readBool(body['has_more']),
      total: readInt(body['count']),
    );
  }

  @override
  Future<StaffMember> detail(String id) async {
    final body = await _post({'action': 'detail', 'staff_id': id});
    final data = objectPayload(body);
    if (data == null) {
      throw const StaffApiException('Staff details were not returned');
    }
    return StaffMember.fromMap(data);
  }
}
