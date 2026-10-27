import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:intl/intl.dart';

String taskDueLabel(StaffTask task) {
  final due = task.dueAt;
  if (due == null) return 'No due date';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(due.year, due.month, due.day);
  final date = day == today
      ? 'Today'
      : day == today.add(const Duration(days: 1))
      ? 'Tomorrow'
      : DateFormat('d MMM').format(due);
  if (due.hour == 0 && due.minute == 0) return date;
  return '$date, ${DateFormat('h:mm a').format(due)}';
}

String taskWhen(DateTime? value) {
  if (value == null) return '';
  if (value.hour == 0 && value.minute == 0) {
    return DateFormat('d MMM yyyy').format(value);
  }
  return DateFormat('d MMM yyyy, h:mm a').format(value);
}
