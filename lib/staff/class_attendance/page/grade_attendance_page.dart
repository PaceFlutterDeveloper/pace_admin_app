import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/staff/class_attendance/cubit/grade_attendance_cubit.dart';
import 'package:admin_app/staff/class_attendance/model/grade_data_model.dart';
import 'package:admin_app/staff/class_attendance/model/grade_model.dart';
import 'package:admin_app/staff/class_attendance/page/sections_grid_screen.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GradeAttendanceScreen extends StatefulWidget {
  final String appTitle;

  const GradeAttendanceScreen({super.key, required this.appTitle});

  @override
  State<GradeAttendanceScreen> createState() => _GradeAttendanceScreenState();
}

class _GradeAttendanceScreenState extends State<GradeAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GradeAttendanceCubit>().getGrades();
  }

  Future<void> _reload() {
    return context.read<GradeAttendanceCubit>().getGrades(force: true);
  }

  void _openGrade(GradeModel grade) {
    final name = grade.label;
    if (grade.sections.length == 1) {
      openClassRoll(
        context,
        grade: grade.gradeCode,
        section: grade.sections.first,
        title: '$name · ${grade.sections.first}',
      );
      return;
    }
    if (grade.sections.isEmpty) {
      AppToast.error(context, 'No sections for $name');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SectionsGridScreen(grade: grade)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffPage(
      child: Column(
        children: [
          StaffPageHeader(
            title: widget.appTitle,
            subtitle: 'Classes and sections',
          ),
          Expanded(
            child: BlocConsumer<GradeAttendanceCubit, GradeAttendanceState>(
              listenWhen: (prev, next) =>
                  next.errorMessage != null &&
                  next.errorMessage != prev.errorMessage &&
                  next.gradeDataModel != null,
              listener: (context, state) {
                AppToast.error(context, state.errorMessage!);
              },
              builder: (context, state) {
                final data = state.gradeDataModel;
                if (state.fetchGrades && data == null) {
                  return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      for (var i = 0; i < 6; i++) ...[
                        const StaffSkeleton(height: 72, radius: 18),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                }
                if (data == null) {
                  return RefreshIndicator(
                    color: p.amberText,
                    backgroundColor: p.surface,
                    onRefresh: _reload,
                    child: ListView(
                      physics: staffScrollPhysics,
                      children: [
                        SizedBox(
                          height: 420,
                          child: StaffStateMessage(
                            glyph: StaffGlyphs.users,
                            title: 'Could not load classes',
                            message: state.errorMessage ?? 'Pull to try again.',
                            actionLabel: 'Try again',
                            onAction: _reload,
                            accent: StaffAccent.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (data.isEmpty) {
                  return RefreshIndicator(
                    color: p.amberText,
                    backgroundColor: p.surface,
                    onRefresh: _reload,
                    child: const StaffEmptyList(
                      glyph: StaffGlyphs.users,
                      title: 'No classes assigned',
                      message: 'Classes you can mark will show up here.',
                      accent: StaffAccent.blue,
                    ),
                  );
                }
                return RefreshIndicator(
                  color: p.amberText,
                  backgroundColor: p.surface,
                  onRefresh: _reload,
                  child: _ClassList(data: data, onOpen: _openGrade),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({required this.data, required this.onOpen});

  final GradeDataModel data;
  final ValueChanged<GradeModel> onOpen;

  @override
  Widget build(BuildContext context) {
    final home = data.dataDefault;
    return ListView(
      physics: staffScrollPhysics,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (home.isAssigned) ...[
          const SectionLabel('YOUR CLASS'),
          _ClassRow(
            title: '${data.labelFor(home.gr)} · ${home.sec}',
            detail: 'Take attendance',
            accent: StaffAccent.amber,
            onTap: () => openClassRoll(
              context,
              grade: home.gr,
              section: home.sec,
              title: '${data.labelFor(home.gr)} · ${home.sec}',
            ),
          ),
        ],
        if (data.grades.isNotEmpty) ...[
          SectionLabel(home.isAssigned ? 'OTHER CLASSES' : 'CLASSES'),
          for (final grade in data.grades)
            _ClassRow(
              title: grade.label,
              detail: _sectionDetail(grade),
              accent: StaffAccent.blue,
              onTap: () => onOpen(grade),
            ),
        ],
      ],
    );
  }
}

String _sectionDetail(GradeModel grade) {
  final count = grade.sections.length;
  if (count == 0) return 'No sections';
  if (count == 1) return 'Section ${grade.sections.first}';
  return '$count sections';
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({
    required this.title,
    required this.detail,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String detail;
  final StaffAccent accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: StaffCard(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            GlassIconTile(glyph: StaffGlyphs.users, accent: accent, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sora(15, weight: FontWeight.w700, color: p.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: sora(12, weight: FontWeight.w500, color: p.muted),
                  ),
                ],
              ),
            ),
            StaffIcon(StaffGlyphs.chevronRight, size: 18, color: p.muted),
          ],
        ),
      ),
    );
  }
}
