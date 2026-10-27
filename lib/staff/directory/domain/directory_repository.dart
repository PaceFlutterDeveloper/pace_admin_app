import 'package:admin_app/staff/directory/domain/staff_member.dart';

abstract class DirectoryRepository {
  Future<StaffPageResult> list({String search = '', int page = 0});

  Future<StaffMember> detail(String id);
}
