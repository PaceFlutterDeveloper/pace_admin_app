import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_attachment.dart';

class TaskCheckItem {
  const TaskCheckItem({required this.title, required this.done});

  final String title;
  final bool done;

  static TaskCheckItem? tryFrom(Map<String, dynamic> json) {
    final title = plainText(
      readString(json['title'] ?? json['item'] ?? json['name'] ?? json['text']),
    );
    if (title.isEmpty) return null;
    return TaskCheckItem(
      title: title,
      done: readBool(json['done'] ?? json['is_done'] ?? json['checked']),
    );
  }
}

class TaskNote {
  const TaskNote({required this.author, required this.text, this.at});

  final String author;
  final String text;
  final DateTime? at;

  static TaskNote? tryFrom(Map<String, dynamic> json) {
    final text = plainText(
      readString(json['text'] ?? json['comment'] ?? json['body']),
    );
    if (text.isEmpty) return null;
    return TaskNote(
      author: personName(json['author'] ?? json['created_by'] ?? json['user']),
      text: text,
      at: readDate(json['created_at'] ?? json['at']),
    );
  }
}

/// Rows behind a task such as "pending student leave", from `detail`.
class TaskTable {
  const TaskTable({required this.columns, required this.rows});

  /// (key, label) pairs in display order.
  final List<(String, String)> columns;
  final List<Map<String, String>> rows;

  static TaskTable? tryFrom(dynamic raw) {
    if (raw is! Map) return null;
    final columns = [
      for (final column in objectList(raw['columns']))
        (
          readString(column['key']),
          readString(column['label'] ?? column['key']),
        ),
    ].where((column) => column.$1.isNotEmpty).toList();
    final rows = [
      for (final item in objectList(raw['items'] ?? raw['rows']))
        {for (final column in columns) column.$1: readString(item[column.$1])},
    ];
    if (columns.isEmpty || rows.isEmpty) return null;
    return TaskTable(columns: columns, rows: rows);
  }
}

class TaskCounts {
  const TaskCounts({
    required this.open,
    required this.dueToday,
    required this.overdue,
  });

  final int open;
  final int dueToday;
  final int overdue;

  static const empty = TaskCounts(open: 0, dueToday: 0, overdue: 0);

  static TaskCounts? tryFrom(Map<String, dynamic>? json) {
    if (json == null) return null;
    if (!json.containsKey('open') &&
        !json.containsKey('due_today') &&
        !json.containsKey('overdue')) {
      return null;
    }
    return TaskCounts(
      open: readInt(json['open']),
      dueToday: readInt(json['due_today']),
      overdue: readInt(json['overdue']),
    );
  }

  static TaskCounts fromTasks(List<StaffTask> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var open = 0;
    var dueToday = 0;
    var overdue = 0;
    for (final task in tasks) {
      if (task.isDone) continue;
      open++;
      final due = task.dueAt;
      if (due == null) continue;
      final day = DateTime(due.year, due.month, due.day);
      if (day == today) dueToday++;
      if (task.overdue || day.isBefore(today)) overdue++;
    }
    return TaskCounts(open: open, dueToday: dueToday, overdue: overdue);
  }
}

/// One assigned task from `page=tasks`.
class StaffTask {
  const StaffTask({
    required this.id,
    required this.title,
    this.description = '',
    this.status = '',
    this.priority = '',
    this.dueAt,
    this.createdBy = '',
    this.assignees = const [],
    this.createdAt,
    this.overdue = false,
    this.checklist = const [],
    this.comments = const [],
    this.attachments = const [],
    this.pending = 0,
    this.critical = 0,
    this.table,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueAt;
  final String createdBy;
  final List<String> assignees;
  final DateTime? createdAt;
  final bool overdue;
  final List<TaskCheckItem> checklist;
  final List<TaskNote> comments;
  final List<StaffAttachment> attachments;

  /// Items still waiting, and how many of them are critical.
  final int pending;
  final int critical;
  final TaskTable? table;

  bool get isDone {
    final value = status.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    return value == 'done' || value == 'completed' || value == 'closed';
  }

  String get statusLabel {
    final value = status.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    return switch (value) {
      'in_progress' || 'inprogress' => 'In progress',
      'done' || 'completed' || 'closed' => 'Done',
      'open' || '' => 'Open',
      _ => status,
    };
  }

  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return 'High';
      case 'low':
        return 'Low';
      case '':
      case 'normal':
      case 'medium':
        return 'Normal';
      default:
        return priority;
    }
  }

  String get statusColor {
    final value = status.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    return switch (value) {
      'in_progress' || 'inprogress' => '#3B82F6',
      'done' || 'completed' || 'closed' => '#1F9D55',
      _ => '#F5B544',
    };
  }

  static StaffTask? tryFromMap(Map<String, dynamic> json) {
    final title = plainText(readString(json['title']));
    if (title.isEmpty) return null;
    final id = readString(json['task_id'] ?? json['id']);
    final names = <String>[];
    final rawAssignees = json['assignees'] ?? json['assignee'];
    if (rawAssignees is List) {
      for (final item in rawAssignees) {
        final name = personName(item);
        if (name.isNotEmpty) names.add(name);
      }
    } else {
      final name = personName(rawAssignees);
      if (name.isNotEmpty) names.add(name);
    }
    return StaffTask(
      id: id.isEmpty ? title : id,
      title: title,
      description: plainText(readString(json['description'])),
      status: readString(json['status']),
      priority: readString(json['priority']),
      dueAt: readDate(json['due_at'] ?? json['due_date']),
      createdBy: personName(json['created_by']),
      assignees: names,
      createdAt: readDate(json['created_at']),
      overdue: readBool(json['is_overdue'] ?? json['overdue']),
      checklist: [
        for (final item in objectList(json['checklist'] ?? json['check_list']))
          if (TaskCheckItem.tryFrom(item) case final check?) check,
      ],
      comments: [
        for (final item in objectList(json['comments'] ?? json['activity']))
          if (TaskNote.tryFrom(item) case final note?) note,
      ],
      attachments: readAttachments(json['attachments']),
      pending: readInt(json['pending']),
      critical: readInt(json['critical']),
      table: TaskTable.tryFrom(json['detail']),
    );
  }
}

class TaskListResult {
  const TaskListResult({required this.tasks, required this.counts});

  final List<StaffTask> tasks;
  final TaskCounts counts;

  static TaskListResult fromBody(Map<String, dynamic> body) {
    final tasks = [
      for (final item in listPayload(body, const ['tasks', 'items']))
        if (StaffTask.tryFromMap(item) case final task?) task,
    ];
    final counts =
        TaskCounts.tryFrom(countsPayload(body)) ?? TaskCounts.fromTasks(tasks);
    return TaskListResult(tasks: tasks, counts: counts);
  }
}
