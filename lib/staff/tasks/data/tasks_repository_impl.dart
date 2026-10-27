import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';
import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:admin_app/staff/tasks/domain/tasks_repository.dart';

class ApiTasksRepository implements TasksRepository {
  ApiTasksRepository({required this.apiService});

  final ApiService apiService;

  @override
  Future<TaskListResult> myTasks() async {
    final body = await postStaffPage(
      api: apiService,
      url: ApiConstants.getTasks(),
      fields: {'action': 'list', 'scope': 'mine', 'pageNo': 0, 'limit': 100},
    );
    return TaskListResult.fromBody(body);
  }

  @override
  Future<StaffTask> taskDetail(String id) async {
    final body = await postStaffPage(
      api: apiService,
      url: ApiConstants.getTasks(),
      fields: {'action': 'detail', 'task_id': id},
    );
    final data = _taskRecord(body);
    final task = data == null ? null : StaffTask.tryFromMap(data);
    if (task == null) {
      throw const StaffApiException('Task details were not returned');
    }
    return task;
  }
}

Map<String, dynamic>? _taskRecord(Map<String, dynamic> body) {
  final data = objectPayload(body);
  if (data == null) return null;
  final nested = data['task'];
  if (nested is! Map || readString(data['title']).isNotEmpty) return data;
  final record = Map<String, dynamic>.from(nested);
  for (final key in ['comments', 'checklist', 'attachments', 'assignees']) {
    if (record[key] == null && data[key] != null) record[key] = data[key];
  }
  return record;
}
