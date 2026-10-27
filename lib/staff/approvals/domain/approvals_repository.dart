import 'package:admin_app/staff/approvals/domain/approval_models.dart';

abstract class ApprovalsRepository {
  /// [pending] true lists items waiting for me, false the ones already decided.
  Future<ApprovalList> list({required bool pending});

  Future<StaffApproval> detail(String id);

  /// Throws the server's message, for example when someone else decided first.
  Future<void> decide(String id, {required bool approve, String? comment});
}
