import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:admin_app/staff/tasks/presentation/task_format.dart';
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

    expect(list.tasks.single.priorityLabel, 'High');
    expect(list.tasks.single.assignees, ['Niyas']);
    expect(list.tasks.single.createdBy, 'Principal');
    expect(list.tasks.single.tracksPending, isFalse);
    expect(list.counts.dueToday, 1);
    expect(list.counts.overdue, 2);

    final leave = StaffTask.tryFromMap({
      'task_id': 'studportal_leave_approvals',
      'title': 'Student Portal leave — pending',
      'status': 'open',
      'pending': 41,
      'critical': 13,
      'is_overdue': true,
    });
    expect(leave!.pending, 41);
    expect(leave.critical, 13);
    expect(leave.tracksPending, isTrue);

    final clear = StaffTask.tryFromMap({
      'title': 'Student Portal leave — pending',
      'pending': 0,
      'critical': 0,
    });
    expect(clear!.tracksPending, isTrue);
    expect(clear.pending, 0);

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

  test('task number is the id, and a title used as a fallback is not one', () {
    final numbered = StaffTask.tryFromMap({
      'task_id': 4,
      'title': 'Prepare the hall',
    });
    final fallback = StaffTask.tryFromMap({'title': 'Prepare the hall'});
    expect(taskNumberLabel(numbered!), '#4');
    expect(taskNumberLabel(fallback!), isNull);
  });

  test('a multi-day event is listed on every day it covers', () {
    final event = StaffEvent(
      id: '3',
      title: 'Sports week',
      startsAt: DateTime(2026, 10, 26, 9),
      endsAt: DateTime(2026, 10, 28, 16),
    );
    final days = expandEventDays([event]);
    expect(days.map((row) => row.day), [
      DateTime(2026, 10, 26),
      DateTime(2026, 10, 27),
      DateTime(2026, 10, 28),
    ]);
    expect(days.map((row) => row.span), [
      EventSpan.first,
      EventSpan.middle,
      EventSpan.last,
    ]);
  });

  test('an all-day exclusive midnight does not add an empty last day', () {
    final event = StaffEvent.tryFromMap({
      'event_id': 9,
      'title': 'Sports week',
      'starts_at': '2026-10-26',
      'ends_at': '2026-10-29T00:00:00+04:00',
      'all_day': true,
    });
    expect(event!.exclusiveEnd, isTrue);
    expect(eventEndDay(event), DateTime(2026, 10, 28));
    final days = expandEventDays([event]);
    expect(days.map((row) => row.span), [
      EventSpan.first,
      EventSpan.middle,
      EventSpan.last,
    ]);
    expect(days.last.day, DateTime(2026, 10, 28));
  });

  test('an all-day date range keeps the written end date', () {
    final event = StaffEvent.tryFromMap({
      'title': 'National Day',
      'starts_at': '2026-10-26',
      'ends_at': '2026-10-28',
      'all_day': 1,
    });
    expect(event!.exclusiveEnd, isFalse);
    expect(eventEndDay(event), DateTime(2026, 10, 28));
    expect(expandEventDays([event]).length, 3);
  });
}
