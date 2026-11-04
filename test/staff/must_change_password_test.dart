import 'dart:io';

import 'package:admin_app/staff/dashboard/domain/dashboard_repository.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/session/must_change_password.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _DashboardRepo implements DashboardRepository {
  _DashboardRepo(this.dashboard);

  final StaffDashboard dashboard;

  @override
  Future<StaffDashboard> load() async => dashboard;
}

void main() {
  late Directory hiveDir;
  late String Function() originalKey;

  setUp(() async {
    originalKey = LoadMarker.sessionKey;
    LoadMarker.sessionKey = () => 'test';
    hiveDir = await Directory.systemTemp.createTemp('must_change_password');
    Hive.init(hiveDir.path);
    await Hive.openBox('settingsBox');
  });

  tearDown(() async {
    LoadMarker.sessionKey = originalKey;
    await Hive.close();
    if (hiveDir.existsSync()) await hiveDir.delete(recursive: true);
  });

  test('dashboard flag 1 keeps the person on the password screen', () async {
    final cubit = DashboardCubit(
      repository: _DashboardRepo(
        StaffDashboard.fromData({'must_change_password': 1}),
      ),
    );
    await cubit.load();
    expect(mustChangePasswordGate.required, isTrue);
    await cubit.close();
  });

  test('dashboard flag 0 clears a password requirement', () async {
    mustChangePasswordGate.apply(true);
    final cubit = DashboardCubit(
      repository: _DashboardRepo(
        StaffDashboard.fromData({'must_change_password': 0}),
      ),
    );
    await cubit.load();
    expect(mustChangePasswordGate.required, isFalse);
    await cubit.close();
  });

  test(
    'a summary that omits the flag leaves the requirement in place',
    () async {
      mustChangePasswordGate.apply(true);
      final cubit = DashboardCubit(
        repository: _DashboardRepo(
          StaffDashboard.fromData({'unread_notifications': 2}),
        ),
      );
      await cubit.load();
      expect(mustChangePasswordGate.required, isTrue);
      await cubit.close();
    },
  );

  test('a dropped summary cannot turn the requirement back on', () async {
    mustChangePasswordGate.apply(false);
    final cubit = DashboardCubit(
      repository: _DashboardRepo(
        StaffDashboard.fromData({'must_change_password': 1}),
      ),
    );
    final pending = cubit.load();
    cubit.dropSession();
    await pending;
    expect(mustChangePasswordGate.required, isFalse);
    await cubit.close();
  });
}
