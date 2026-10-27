import 'package:admin_app/staff/notices/domain/notice_models.dart';

abstract class NoticesRepository {
  Future<List<StaffNotice>> list();

  Future<StaffNotice> detail(String id);

  Future<void> markRead(String id);

  Future<void> acknowledge(String id);
}
