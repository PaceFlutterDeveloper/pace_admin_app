import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/approvals/domain/approval_models.dart';
import 'package:admin_app/staff/approvals/domain/approvals_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiApprovalsRepository implements ApprovalsRepository {
  ApiApprovalsRepository({required this.apiService});

  final ApiService apiService;

  Future<Map<String, dynamic>> _post(Map<String, dynamic> fields) {
    return postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('approvals'),
      fields: fields,
    );
  }

  @override
  Future<ApprovalList> list({required bool pending}) async {
    final body = await _post({
      'action': 'list',
      'status': pending ? 'pending' : 'done',
      'pageNo': 0,
      'limit': 100,
    });
    final items = [
      for (final row in listPayload(body, const ['approvals']))
        StaffApproval.fromMap(row),
    ];
    final counts = countsPayload(body);
    return ApprovalList(
      items: items,
      pending: counts == null
          ? (pending ? items.length : 0)
          : readInt(counts['pending']),
    );
  }

  @override
  Future<StaffApproval> detail(String id) async {
    final body = await _post({'action': 'detail', 'approval_id': id});
    final data = objectPayload(body);
    if (data == null) {
      throw const StaffApiException('Approval details were not returned');
    }
    return StaffApproval.fromMap(data);
  }

  @override
  Future<void> decide(
    String id, {
    required bool approve,
    String? comment,
  }) async {
    await _post({
      'action': 'decide',
      'approval_id': id,
      'decision': approve ? 'approve' : 'reject',
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    });
  }
}
