import 'package:admin_app/staff/leave/domain/leave_models.dart';

abstract class LeaveRepository {
  Future<LeaveOverview> overview();

  Future<List<LeaveType>> types();

  Future<LeaveRequest> detail(String requestId);

  /// Files a request. Throws a message the server wrote for overlap, balance,
  /// blackout dates or a missing document.
  Future<void> apply({
    required int typeId,
    required DateTime from,
    required DateTime to,
    required String reason,
    String? halfDay,
    String? attachmentPath,
  });

  Future<void> cancel(String requestId);
}
