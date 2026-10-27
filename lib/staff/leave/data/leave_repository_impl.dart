import 'dart:math';

import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/leave/domain/leave_models.dart';
import 'package:admin_app/staff/leave/domain/leave_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';
import 'package:dio/dio.dart';

class ApiLeaveRepository implements LeaveRepository {
  ApiLeaveRepository({required this.apiService});

  final ApiService apiService;

  Future<Map<String, dynamic>> _post(Map<String, dynamic> fields) {
    return postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('leave'),
      fields: fields,
    );
  }

  @override
  Future<LeaveOverview> overview() async {
    final results = await Future.wait([
      _post({'action': 'balance'}),
      _post({'action': 'list', 'pageNo': 0, 'limit': 100}),
    ]);
    return LeaveOverview(
      balances: [
        for (final row in listPayload(results[0], const ['balance']))
          LeaveBalance.fromMap(row),
      ],
      requests: [
        for (final row in listPayload(results[1], const ['requests']))
          LeaveRequest.fromMap(row),
      ],
    );
  }

  @override
  Future<List<LeaveType>> types() async {
    final body = await _post({'action': 'types'});
    return [
      for (final row in listPayload(body, const ['types']))
        LeaveType.fromMap(row),
    ];
  }

  @override
  Future<LeaveRequest> detail(String requestId) async {
    final body = await _post({'action': 'detail', 'request_id': requestId});
    final data = objectPayload(body);
    if (data == null) {
      throw const StaffApiException('Leave details were not returned');
    }
    return LeaveRequest.fromMap(data);
  }

  @override
  Future<void> apply({
    required int typeId,
    required DateTime from,
    required DateTime to,
    required String reason,
    String? halfDay,
    String? attachmentPath,
  }) async {
    await _post({
      'action': 'apply',
      'leave_type_id': typeId,
      'from_date': ymd(from),
      'to_date': ymd(to),
      'reason': reason,
      if (halfDay != null) 'half_day': halfDay,
      'client_request_id': _requestId(),
      if (attachmentPath != null)
        'attachment': await MultipartFile.fromFile(attachmentPath),
    });
  }

  @override
  Future<void> cancel(String requestId) async {
    await _post({'action': 'cancel', 'request_id': requestId});
  }

  /// Lets the server ignore a request that was sent twice.
  String _requestId() {
    final random = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}$random';
  }
}
