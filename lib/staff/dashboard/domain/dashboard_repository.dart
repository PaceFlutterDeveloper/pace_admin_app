import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';

abstract class DashboardRepository {
  Future<StaffDashboard> load();
}
