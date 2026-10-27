import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads an events list and keeps all-day events first', () {
    final events = eventsFromBody({
      'status': true,
      'data': [
        {
          'event_id': 12,
          'title': 'Staff meeting',
          'description': 'Agenda in the attached PDF',
          'starts_at': '2026-10-26T09:30:00+04:00',
          'ends_at': '2026-10-26T10:15:00+04:00',
          'all_day': false,
          'location': 'Conference Room 2',
          'category': 'meeting',
          'audience': 'all_staff',
          'color': '#F5B544',
          'attachments': [
            {'name': 'agenda.pdf', 'url': 'https://example.com/agenda.pdf'},
          ],
          'created_by': 'Principal Office',
        },
        {
          'event_id': 9,
          'title': 'National Day',
          'starts_at': '2026-10-26',
          'all_day': 1,
          'location': '',
        },
      ],
    });

    expect(events.map((event) => event.title), [
      'National Day',
      'Staff meeting',
    ]);
    expect(events.last.location, 'Conference Room 2');
    expect(events.last.attachments.single.name, 'agenda.pdf');
    expect(events.last.createdBy, 'Principal Office');
    expect(events.first.allDay, isTrue);
  });

  test('reads tasks, counts, and a wrapped detail record', () {
    final list = TaskListResult.fromBody({
      'status': true,
      'data': {
        'tasks': [
          {
            'task_id': 4,
            'title': 'Prepare the hall',
            'description': 'Chairs and sound',
            'status': 'in_progress',
            'priority': 'high',
            'due_at': '2026-10-27T16:00:00+04:00',
            'created_by': {'id': 2, 'name': 'Principal'},
            'assignees': [
              {'id': 8, 'name': 'Niyas'},
            ],
            'is_overdue': false,
          },
        ],
        'counts': {'open': 3, 'due_today': 1, 'overdue': 2},
      },
    });

    expect(list.tasks.single.statusLabel, 'In progress');
    expect(list.tasks.single.priorityLabel, 'High');
    expect(list.tasks.single.assignees, ['Niyas']);
    expect(list.tasks.single.createdBy, 'Principal');
    expect(list.counts.dueToday, 1);
    expect(list.counts.overdue, 2);

    final detail = StaffTask.tryFromMap({
      'title': 'Prepare the hall',
      'checklist': [
        {'title': 'Chairs', 'done': true},
        {'item': 'Sound', 'is_done': 0},
      ],
      'comments': [
        {
          'text': 'Starting now',
          'author': {'name': 'Niyas'},
          'created_at': '2026-10-27T09:00:00+04:00',
        },
      ],
    });
    expect(detail!.checklist.map((item) => item.done), [true, false]);
    expect(detail.comments.single.author, 'Niyas');
  });
}
