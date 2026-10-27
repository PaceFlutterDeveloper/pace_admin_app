import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:admin_app/staff/tasks/domain/tasks_repository.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TasksState {
  const TasksState();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksLoaded extends TasksState {
  const TasksLoaded({required this.tasks, required this.counts});

  final List<StaffTask> tasks;
  final TaskCounts counts;
}

class TasksFailed extends TasksState {
  const TasksFailed(this.message);

  final String message;
}

class TasksCubit extends Cubit<TasksState> {
  TasksCubit({TasksRepository? repository})
    : _repository = repository ?? locator<TasksRepository>(),
      super(const TasksLoading());

  final TasksRepository _repository;
  final LoadMarker _loaded = LoadMarker();

  bool get isFresh => _loaded.isFresh();

  Future<void> load({bool quiet = false}) async {
    final keep = quiet && _loaded.holds() && state is TasksLoaded;
    if (!keep) emit(const TasksLoading());
    try {
      final result = await _repository.myTasks();
      _loaded.mark();
      emit(TasksLoaded(tasks: result.tasks, counts: result.counts));
    } catch (error) {
      if (!keep) emit(TasksFailed(staffErrorMessage(error)));
    }
  }
}
