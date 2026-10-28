import 'dart:async';

import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/dashboard/domain/dashboard_repository.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/notification/services/staff_fcm.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository({required this.apiService});

  final ApiService apiService;

  @override
  Future<StaffDashboard> load() async {
    final body = await postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('dashboard'),
      fields: const {'action': 'summary'},
    );
    final data = objectPayload(body);
    if (data == null) {
      throw const StaffApiException('The summary was not returned');
    }
    // Same moment careers subscribes: after the call that carries `topics`.
    // Does not block Home. A repeat with the same list is a no-op.
    unawaited(StaffFcm.subscribeIfPresent(body));
    return StaffDashboard.fromData(data);
  }
}
