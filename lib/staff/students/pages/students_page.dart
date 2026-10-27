import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/staff/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/staff/students/components/student_attendance_tile.dart';
import 'package:admin_app/staff/students/models/attendance_marks.dart';
import 'package:admin_app/staff/students/models/student_att_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StudentsPage extends StatefulWidget {
  final String grade;
  final String section;
  final String appTitle;

  const StudentsPage({
    super.key,
    required this.appTitle,
    required this.grade,
    required this.section,
  });

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _query = TextEditingController();
  String _filter = '';

  bool get _canLoad => widget.grade.isNotEmpty && widget.section.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(StudentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.grade != widget.grade ||
        oldWidget.section != widget.section) {
      _filter = '';
      _query.clear();
      _load();
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _load({bool quiet = false}) {
    if (!_canLoad) return;
    final bloc = context.read<StudentAttendanceBloc>();
    final current = bloc.state;
    final same =
        current is StudentLoadedState &&
        current.matches(widget.grade, widget.section);
    bloc.add(
      FetchStudentsEvent(
        grade: widget.grade,
        section: widget.section,
        quiet: quiet || same,
      ),
    );
  }

  StudentLoadedState? _roll(StudentAttendanceState state) {
    if (state is StudentLoadedState &&
        state.matches(widget.grade, widget.section)) {
      return state;
    }
    return null;
  }

  Future<void> _markAll(StudentLoadedState roll) async {
    if (roll.saving) return;
    final absent = countMarked(roll.students, attendanceAbsent);
    if (absent > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final p = context.staff;
          return AlertDialog(
            backgroundColor: p.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Mark everyone present?',
              style: sora(18, weight: FontWeight.w700, color: p.text),
            ),
            content: Text(
              'This replaces the $absent already marked absent.',
              style: sora(14, weight: FontWeight.w500, color: p.muted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: sora(14, weight: FontWeight.w600, color: p.muted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Mark all',
                  style: sora(14, weight: FontWeight.w700, color: p.amberText),
                ),
              ),
            ],
          );
        },
      );
      if (proceed != true || !mounted) return;
    }
    context.read<StudentAttendanceBloc>().add(MarkAllStudentEvent());
  }

  Future<void> _review(StudentLoadedState roll) async {
    if (roll.saving) return;
    final action = await showStaffSheet<String>(
      context,
      title: 'Save attendance',
      builder: (context) {
        final present = countMarked(roll.students, attendancePresent);
        final absent = countMarked(roll.students, attendanceAbsent);
        final p = context.staff;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CountLine(
                label: 'Present',
                value: '$present',
                color: const Color(0xFF059669),
              ),
              _CountLine(label: 'Absent', value: '$absent', color: p.danger),
              const SizedBox(height: 8),
              Text(
                'Confirm submits the roll for today. Save update changes one you already sent.',
                style: sora(12.5, weight: FontWeight.w500, color: p.muted),
              ),
              const SizedBox(height: 14),
              AmberButton(
                label: 'Save update',
                soft: true,
                onPressed: () => Navigator.pop(context, 'UPDATE'),
              ),
              const SizedBox(height: 8),
              AmberButton(
                label: 'Confirm',
                glyph: StaffGlyphs.check,
                onPressed: () => Navigator.pop(context, 'CONFIRM'),
              ),
            ],
          ),
        );
      },
    );
    if (action == null || !mounted) return;
    context.read<StudentAttendanceBloc>().add(
      PostAttendanceEvent(
        type: action,
        grade: widget.grade,
        section: widget.section,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    if (!_canLoad) {
      return const StaffPage(
        child: Column(
          children: [
            StaffPageHeader(title: 'Class', subtitle: 'Attendance'),
            Expanded(
              child: StaffStateMessage(
                glyph: StaffGlyphs.users,
                title: 'Class not found',
                message: 'Go back and choose a class and section.',
                accent: StaffAccent.blue,
              ),
            ),
          ],
        ),
      );
    }

    return StaffPage(
      child: BlocConsumer<StudentAttendanceBloc, StudentAttendanceState>(
        listenWhen: (prev, next) {
          if (next is! StudentLoadedState || next.notice == null) return false;
          if (!next.matches(widget.grade, widget.section)) return false;
          if (prev is StudentLoadedState &&
              prev.notice == next.notice &&
              prev.noticeIsError == next.noticeIsError) {
            return false;
          }
          return true;
        },
        listener: (context, state) {
          final roll = state as StudentLoadedState;
          if (roll.noticeIsError) {
            AppToast.error(context, roll.notice!);
          } else {
            AppToast.success(context, roll.notice!);
          }
        },
        builder: (context, state) {
          final roll = _roll(state);
          final date = DateFormat('d MMM yyyy').format(DateTime.now());
          final subtitle = roll == null
              ? date
              : '$date · ${roll.students.where(attendanceIsMarked).length} of ${roll.students.length} marked';
          return Column(
            children: [
              StaffPageHeader(
                title: widget.appTitle,
                subtitle: subtitle,
                trailing: roll == null || roll.students.isEmpty
                    ? null
                    : TextButton(
                        onPressed: roll.saving ? null : () => _markAll(roll),
                        child: Text(
                          'All present',
                          style: sora(
                            12.5,
                            weight: FontWeight.w700,
                            color: roll.saving ? p.muted : p.amberText,
                          ),
                        ),
                      ),
              ),
              Expanded(child: _body(context, state, roll)),
            ],
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    StudentAttendanceState state,
    StudentLoadedState? roll,
  ) {
    final p = context.staff;
    if (roll == null) {
      if (state is StudentErrorState &&
          state.matches(widget.grade, widget.section)) {
        return RefreshIndicator(
          color: p.amberText,
          backgroundColor: p.surface,
          onRefresh: () async => _load(),
          child: ListView(
            physics: staffScrollPhysics,
            children: [
              SizedBox(
                height: 420,
                child: StaffStateMessage(
                  glyph: StaffGlyphs.users,
                  title: 'Could not load this class',
                  message: state.message,
                  actionLabel: 'Try again',
                  onAction: _load,
                  accent: StaffAccent.blue,
                ),
              ),
            ],
          ),
        );
      }
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (var i = 0; i < 6; i++) ...[
            const StaffSkeleton(height: 92, radius: 18),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    final query = _filter.trim().toLowerCase();
    final visible = [
      for (final student in roll.students)
        if (query.isEmpty ||
            student.displayName.toLowerCase().contains(query) ||
            student.studcode.toLowerCase().contains(query))
          student,
    ];
    final unmarked = roll.students
        .where((student) => !attendanceIsMarked(student))
        .length;
    final canSave = unmarked == 0 && roll.students.isNotEmpty && !roll.saving;

    return Column(
      children: [
        if (roll.students.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: StaffField(
              label: 'Search',
              hint: 'Name or admission number',
              controller: _query,
              onChanged: (value) => setState(() => _filter = value),
              textInputAction: TextInputAction.search,
              suffixGlyph: StaffGlyphs.search,
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            color: p.amberText,
            backgroundColor: p.surface,
            onRefresh: () async => _load(quiet: true),
            child: visible.isEmpty
                ? ListView(
                    physics: staffScrollPhysics,
                    children: [
                      SizedBox(
                        height: 360,
                        child: StaffStateMessage(
                          glyph: StaffGlyphs.users,
                          title: roll.students.isEmpty
                              ? 'No students'
                              : 'No matches',
                          message: roll.students.isEmpty
                              ? 'This class has no students for today.'
                              : 'Try another name or admission number.',
                          accent: StaffAccent.blue,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: staffScrollPhysics,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final student = visible[index];
                      return StudentAttendanceTile(
                        key: ValueKey(
                          student.studcode.isEmpty
                              ? 'row-$index'
                              : student.studcode,
                        ),
                        student: student,
                        remarks: roll.remarks,
                      );
                    },
                  ),
          ),
        ),
        if (roll.students.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                if (unmarked > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      unmarked == 1
                          ? '1 student is not marked'
                          : '$unmarked students are not marked',
                      style: sora(12, weight: FontWeight.w600, color: p.muted),
                    ),
                  ),
                Opacity(
                  opacity: canSave || roll.saving ? 1 : 0.45,
                  child: AmberButton(
                    label: 'Save attendance',
                    glyph: StaffGlyphs.check,
                    loading: roll.saving,
                    onPressed: canSave ? () => _review(roll) : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CountLine extends StatelessWidget {
  const _CountLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: sora(15, weight: FontWeight.w600, color: p.text),
            ),
          ),
          Text(
            value,
            style: sora(16, weight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
