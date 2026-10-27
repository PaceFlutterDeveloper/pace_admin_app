import 'package:admin_app/staff/tasks/domain/staff_task.dart';

abstract class TasksRepository {
  Future<TaskListResult> myTasks();

  Future<StaffTask> taskDetail(String id);
}
