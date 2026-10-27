import 'package:admin_app/staff/shell/staff_dock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dock tab follows the route, null for pushed pages', () {
    expect(staffTabForPath('/menu'), StaffTab.menu);
    expect(staffTabForPath('/tasks'), StaffTab.tasks);
    expect(staffTabForPath('/events'), StaffTab.events);
    expect(
      staffTabForPath('/tickets'),
      StaffTab.menu,
      reason: 'tickets live in the Menu',
    );
    expect(staffTabForPath('/manageTickets'), StaffTab.menu);
    expect(staffTabForPath('/updatePassword'), isNull);
    expect(StaffTab.values.length, 5);
    expect(StaffTab.menu.index, 2, reason: 'raised Menu button is centred');
  });
}
