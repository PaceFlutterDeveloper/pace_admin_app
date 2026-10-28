import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:admin_app/staff/tasks/presentation/task_detail_page.dart';
import 'package:admin_app/staff/tasks/presentation/task_format.dart';
import 'package:admin_app/staff/tasks/presentation/tasks_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _TaskFilter { open, done, all }

/// Tasks tab: work assigned to the signed-in staff member.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late final TasksCubit _cubit = locator<TasksCubit>();
  _TaskFilter _filter = _TaskFilter.open;

  @override
  void initState() {
    super.initState();
    _cubit.load(quiet: _cubit.isFresh);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return BlocProvider.value(
      value: _cubit,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 4),
              child: Row(
                children: [
                  ?staffOriginBack(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasks',
                          style: sora(
                            28,
                            weight: FontWeight.w700,
                            color: p.text,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<TasksCubit, TasksState>(
                          builder: (context, state) {
                            if (state is! TasksLoaded) {
                              return Text(
                                'Assigned to you',
                                style: sora(
                                  12.5,
                                  weight: FontWeight.w400,
                                  color: p.muted,
                                ),
                              );
                            }
                            final line = _summaryLine(state.tasks, state.counts);
                            return Text(
                              line.text,
                              style: sora(
                                12.5,
                                weight: FontWeight.w600,
                                color: line.clear
                                    ? p.tint(StaffAccent.green).foreground
                                    : line.urgent
                                    ? p.dangerText
                                    : p.muted,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                final tasks = state is TasksLoaded ? state.tasks : null;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      for (final filter in _TaskFilter.values) ...[
                        _FilterChip(
                          label: _chipLabel(filter, tasks),
                          selected: _filter == filter,
                          onTap: () => setState(() => _filter = filter),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<TasksCubit, TasksState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    color: p.amberText,
                    backgroundColor: p.surface,
                    onRefresh: () => _cubit.load(),
                    child: switch (state) {
                      TasksLoading() => const _TaskSkeleton(),
                      TasksFailed(:final message) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 420,
                            child: StaffStateMessage(
                              glyph: StaffGlyphs.tasks,
                              title: 'Could not load tasks',
                              message: message,
                              actionLabel: 'Try again',
                              onAction: _cubit.load,
                              accent: StaffAccent.blue,
                            ),
                          ),
                        ],
                      ),
                      TasksLoaded(:final tasks) => _TaskList(
                        tasks: _visible(tasks),
                        filter: _filter,
                        listEmpty: tasks.isEmpty,
                      ),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _summary(TaskCounts counts) {
    return '${counts.open} open · ${counts.dueToday} due today · ${counts.overdue} overdue';
  }

  _SummaryLine _summaryLine(List<StaffTask> tasks, TaskCounts counts) {
    final open = tasks.where((task) => !task.isDone).toList();
    final counters = open.where((task) => task.tracksPending).toList();
    if (counters.isEmpty && open.isNotEmpty) {
      return _SummaryLine(_summary(counts));
    }
    final pending = counters.fold<int>(0, (sum, task) => sum + task.pending);
    final critical = counters.fold<int>(0, (sum, task) => sum + task.critical);
    if (pending == 0 && critical == 0) {
      if (open.length == counters.length) {
        return const _SummaryLine('Nothing is waiting on you.', clear: true);
      }
      return _SummaryLine(_summary(counts));
    }
    final parts = <String>[
      '$pending pending',
      if (critical > 0) '$critical critical',
      if (counts.overdue > 0) '${counts.overdue} overdue',
    ];
    return _SummaryLine(parts.join(' · '), urgent: critical > 0);
  }

  String _chipLabel(_TaskFilter filter, List<StaffTask>? tasks) {
    final name = switch (filter) {
      _TaskFilter.open => 'Open',
      _TaskFilter.done => 'Done',
      _TaskFilter.all => 'All',
    };
    if (tasks == null) return name;
    final count = tasks.where((task) => _matches(task, filter)).length;
    return '$name $count';
  }

  List<StaffTask> _visible(List<StaffTask> tasks) {
    return [
      for (final task in tasks)
        if (_matches(task, _filter)) task,
    ];
  }

  bool _matches(StaffTask task, _TaskFilter filter) {
    final status = task.status.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    return switch (filter) {
      _TaskFilter.open => status == 'open' || status.isEmpty,
      _TaskFilter.done => task.isDone,
      _TaskFilter.all => true,
    };
  }
}

class _SummaryLine {
  const _SummaryLine(this.text, {this.clear = false, this.urgent = false});

  final String text;
  final bool clear;
  final bool urgent;
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.filter,
    required this.listEmpty,
  });

  final List<StaffTask> tasks;
  final _TaskFilter filter;
  final bool listEmpty;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      final caughtUp = filter == _TaskFilter.open;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 420,
            child: StaffStateMessage(
              glyph: caughtUp ? StaffGlyphs.check : StaffGlyphs.tasks,
              title: caughtUp
                  ? "You're all clear"
                  : filter == _TaskFilter.done
                  ? 'Nothing finished yet'
                  : listEmpty
                  ? 'No tasks'
                  : 'Nothing in this filter',
              message: caughtUp
                  ? 'Nothing is waiting on you. Enjoy the quiet.'
                  : filter == _TaskFilter.done
                  ? 'Finish one and it will show up here.'
                  : listEmpty
                  ? 'Work assigned to you will show up here.'
                  : 'Try another status.',
              accent: caughtUp ? StaffAccent.green : StaffAccent.blue,
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return StaffTaskCard(
          task: task,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TaskDetailPage(task: task),
              ),
            );
          },
        );
      },
    );
  }
}

class StaffTaskCard extends StatelessWidget {
  const StaffTaskCard({super.key, required this.task, required this.onTap});

  final StaffTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final accent = ticketPriorityAccent(ticketPriorityOf(task.priorityLabel));
    final people = task.assignees.join(', ');
    return StaffCard(
      radius: 22,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassIconTile(
                glyph: StaffGlyphs.tasks,
                accent: accent,
                size: 42,
                radius: 14,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (taskNumberLabel(task) case final number?)
                      Text(
                        number,
                        style: sora(
                          11,
                          weight: FontWeight.w800,
                          color: p.amberText,
                        ),
                      ),
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: sora(14.5, weight: FontWeight.w700, color: p.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      taskDueLabel(task),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(
                        11.5,
                        weight: FontWeight.w500,
                        color: task.overdue && !task.isDone
                            ? p.dangerText
                            : p.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PriorityBadge(task.priorityLabel),
            ],
          ),
          if (task.tracksPending) ...[
            const SizedBox(height: 10),
            _PendingLine(task: task),
          ],
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sora(
                12.5,
                weight: FontWeight.w400,
                color: p.muted,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(name: task.statusLabel, colorHex: task.statusColor),
              if (task.overdue && !task.isDone)
                StatusBadge(name: 'Overdue', colorHex: '#E11D48'),
              if (people.isNotEmpty)
                TicketMetaChip(glyph: StaffGlyphs.user, label: people),
              if (task.attachments.isNotEmpty)
                const TicketMetaChip(
                  glyph: StaffGlyphs.paperclip,
                  label: 'Attachment',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingLine extends StatelessWidget {
  const _PendingLine({required this.task});

  final StaffTask task;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    if (task.pending == 0 && task.critical == 0) {
      final green = p.tint(StaffAccent.green).foreground;
      return Row(
        children: [
          StaffIcon(StaffGlyphs.check, size: 14, color: green),
          const SizedBox(width: 6),
          Text(
            'Nothing pending',
            style: sora(12.5, weight: FontWeight.w700, color: green),
          ),
        ],
      );
    }
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (task.pending > 0)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${task.pending}',
                  style: sora(18, weight: FontWeight.w800, color: p.text),
                ),
                TextSpan(
                  text: ' pending',
                  style: sora(12.5, weight: FontWeight.w600, color: p.muted),
                ),
              ],
            ),
          ),
        if (task.critical > 0)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${task.critical}',
                  style: sora(18, weight: FontWeight.w800, color: p.dangerText),
                ),
                TextSpan(
                  text: ' critical',
                  style: sora(12.5, weight: FontWeight.w600, color: p.dangerText),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final tint = p.tint(StaffAccent.amber);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? tint.background : p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? tint.foreground : p.border),
        ),
        child: Text(
          label,
          style: sora(
            12,
            weight: FontWeight.w700,
            color: selected ? tint.foreground : p.muted,
          ),
        ),
      ),
    );
  }
}

class _TaskSkeleton extends StatelessWidget {
  const _TaskSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      children: const [
        StaffCard(
          radius: 22,
          padding: EdgeInsets.all(14),
          child: StaffSkeleton(width: double.infinity, height: 72),
        ),
        SizedBox(height: 10),
        StaffCard(
          radius: 22,
          padding: EdgeInsets.all(14),
          child: StaffSkeleton(width: double.infinity, height: 72),
        ),
      ],
    );
  }
}
