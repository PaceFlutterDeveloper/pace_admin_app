import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/sessions/domain/login_session.dart';
import 'package:admin_app/staff/sessions/domain/login_sessions_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiLoginSessionsRepository implements LoginSessionsRepository {
  ApiLoginSessionsRepository({required this.apiService});

  final ApiService apiService;

  Future<Map<String, dynamic>> _post(Map<String, dynamic> fields) {
    return postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('loginSessions'),
      fields: fields,
    );
  }

  @override
  Future<List<LoginSession>> load() async {
    final body = await _post({'action': 'list'});
    final nested = listPayload(body, const ['sessions', 'devices', 'logins']);
    final rows = nested.isNotEmpty
        ? nested
        : objectList(body['sessions'] ?? body['devices']);
    return [for (final row in rows) LoginSession.fromMap(row)];
  }

  @override
  Future<void> revoke(String sessionId) async {
    await _post({'action': 'revoke', 'session_id': sessionId});
  }

  @override
  Future<void> revokeOthers() async {
    await _post({'action': 'revokeOthers'});
  }
}
