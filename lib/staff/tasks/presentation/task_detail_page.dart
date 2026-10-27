import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/shared/staff_attachment.dart';
import 'package:admin_app/staff/tasks/domain/staff_task.dart';
import 'package:admin_app/staff/tasks/domain/tasks_repository.dart';
import 'package:admin_app/staff/tasks/presentation/task_format.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key, required this.task});

  final StaffTask task;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late StaffTask _task = widget.task;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final full = await locator<TasksRepository>().taskDetail(_task.id);
      if (!mounted) return;
      setState(() {
        _task = full;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final task = _task;
    return ColoredBox(
      color: p.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  StaffIconButton(
                    glyph: StaffGlyphs.chevronLeft,
                    semanticLabel: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Task',
                      style: sora(
                        22,
                        weight: FontWeight.w700,
                        color: p.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (_loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: p.amberText,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Text(
                    task.title,
                    style: sora(
                      24,
                      weight: FontWeight.w700,
                      color: p.text,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(
                        name: task.statusLabel,
                        colorHex: task.statusColor,
                      ),
                      PriorityBadge(task.priorityLabel),
                      if (task.overdue && !task.isDone)
                        const StatusBadge(name: 'Overdue', colorHex: '#E11D48'),
                      TicketMetaChip(
                        glyph: StaffGlyphs.clock,
                        label: taskDueLabel(task),
                      ),
                    ],
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      task.description,
                      style: sora(
                        14,
                        weight: FontWeight.w400,
                        color: p.text,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (task.pending > 0 || task.table != null) ...[
                    const SizedBox(height: 18),
                    _TaskItems(task: task),
                  ],
                  if (task.assignees.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Assigned to',
                      style: sora(
                        11.5,
                        weight: FontWeight.w600,
                        color: p.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final name in task.assignees)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            PersonTile(name: name),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: sora(
                                  13.5,
                                  weight: FontWeight.w600,
                                  color: p.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if (task.createdBy.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Added by ${task.createdBy}'
                        '${task.createdAt == null ? '' : ' · ${taskWhen(task.createdAt)}'}',
                        style: sora(
                          12,
                          weight: FontWeight.w400,
                          color: p.muted,
                        ),
                      ),
                    ),
                  if (task.checklist.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Checklist',
                      style: sora(
                        11.5,
                        weight: FontWeight.w600,
                        color: p.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final item in task.checklist)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            StaffIcon(
                              item.done ? StaffGlyphs.check : StaffGlyphs.tasks,
                              size: 18,
                              color: item.done
                                  ? p.tint(StaffAccent.green).foreground
                                  : p.muted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.title,
                                style: sora(
                                  13.5,
                                  weight: FontWeight.w500,
                                  color: item.done ? p.muted : p.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if (task.comments.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Comments',
                      style: sora(
                        11.5,
                        weight: FontWeight.w600,
                        color: p.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final note in task.comments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StaffCard(
                          radius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  if (note.author.isNotEmpty) note.author,
                                  if (note.at != null) taskWhen(note.at),
                                ].join(' · '),
                                style: sora(
                                  11.5,
                                  weight: FontWeight.w600,
                                  color: p.muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note.text,
                                style: sora(
                                  13.5,
                                  weight: FontWeight.w400,
                                  color: p.text,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  if (task.attachments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Attachments',
                      style: sora(
                        11.5,
                        weight: FontWeight.w600,
                        color: p.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final file in task.attachments) _FileRow(file: file),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file});

  final StaffAttachment file;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      radius: 16,
      margin: const EdgeInsets.only(bottom: 8),
      onTap: file.url.isEmpty
          ? null
          : () {
              final uri = Uri.tryParse(file.url);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          StaffIcon(StaffGlyphs.paperclip, size: 18, color: p.amberText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(13, weight: FontWeight.w600, color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// The items a counter task is made of, one card per row.
class _TaskItems extends StatelessWidget {
  const _TaskItems({required this.task});

  final StaffTask task;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final table = task.table;
    final summary = [
      if (task.pending > 0) '${task.pending} pending',
      if (task.critical > 0) '${task.critical} critical',
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.isEmpty ? 'Items' : 'Items · $summary',
          style: sora(11.5, weight: FontWeight.w600, color: p.muted),
        ),
        if (table != null) ...[
          const SizedBox(height: 8),
          for (final row in table.rows)
            StaffCard(
              radius: 16,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, column) in table.columns.indexed)
                    if ((row[column.$1] ?? '').isNotEmpty && column.$1 != 'id')
                      Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 0 : 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 86,
                              child: Text(
                                column.$2,
                                style: sora(11.5, color: p.muted),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                row[column.$1]!,
                                style: sora(
                                  12.5,
                                  weight: FontWeight.w600,
                                  color: p.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
