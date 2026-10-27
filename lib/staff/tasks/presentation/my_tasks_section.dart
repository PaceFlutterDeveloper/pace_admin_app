import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:admin_app/staff/tasks/presentation/task_detail_page.dart';
import 'package:admin_app/staff/tasks/presentation/task_format.dart';
import 'package:admin_app/staff/tasks/presentation/tasks_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Home list of the signed-in user's next tasks.
class MyTasksSection extends StatelessWidget {
  const MyTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'My tasks',
          action: 'See all',
          onAction: () => context.go(Routes.tasks.path),
        ),
        BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) => switch (state) {
            TasksLoading() => const _Skeleton(),
            TasksFailed(:final message) => _Message(
              title: "Couldn't load tasks",
              body: message,
            ),
            TasksLoaded(:final tasks) when tasks.isEmpty => const _Message(
              title: 'No tasks',
              body: 'Nothing is assigned to you.',
            ),
            TasksLoaded(:final tasks) => _List(tasks: _next(tasks)),
          },
        ),
      ],
    );
  }

  List<StaffTask> _next(List<StaffTask> tasks) {
    final open = tasks.where((task) => !task.isDone).toList();
    final source = open.isEmpty ? tasks : open;
    return source.take(3).toList();
  }
}

class _List extends StatelessWidget {
  const _List({required this.tasks});

  final List<StaffTask> tasks;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TaskDetailPage(task: tasks[i]),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 34,
                      decoration: BoxDecoration(
                        color: tasks[i].overdue && !tasks[i].isDone
                            ? p.danger
                            : p.tint(StaffAccent.blue).foreground,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tasks[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sora(
                              13.5,
                              weight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                          Text(
                            '${tasks[i].statusLabel} · ${taskDueLabel(tasks[i])}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sora(
                              11.5,
                              weight: FontWeight.w400,
                              color: p.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i != tasks.length - 1) Divider(height: 1, color: p.border),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      onTap: () => context.go(Routes.tasks.path),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const GlassIconTile(
            glyph: StaffGlyphs.tasks,
            accent: StaffAccent.blue,
            size: 42,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: sora(13.5, weight: FontWeight.w700, color: p.text),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: sora(12, weight: FontWeight.w400, color: p.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return const StaffCard(
      margin: EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      padding: EdgeInsets.all(16),
      child: StaffSkeleton(width: double.infinity, height: 36),
    );
  }
}
