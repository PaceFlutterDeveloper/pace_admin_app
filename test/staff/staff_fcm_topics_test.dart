import 'package:admin_app/staff/notification/services/staff_fcm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard topics are read from data.topics', () {
    final topics = StaffFcm.topicsFrom({
      'status': true,
      'message': 'OK',
      'data': {
        'attendance': {
          'today': {'status': 'absent'},
        },
        'unread_notifications': 0,
        'topics': [
          'staff_755',
          'emp_1965',
          'staff_school_100',
          'staff_group_1',
          'staff_group_2',
          'staff_role_admin',
        ],
      },
    });

    expect(topics, [
      'staff_755',
      'emp_1965',
      'staff_school_100',
      'staff_group_1',
      'staff_group_2',
      'staff_role_admin',
    ]);
  });

  test('a dashboard without topics is left alone', () {
    expect(
      StaffFcm.topicsFrom({
        'status': true,
        'data': {'events_today': 0},
      }),
      isNull,
    );
  });
}
