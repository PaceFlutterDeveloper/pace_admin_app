import 'package:admin_app/staff/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/staff/students/models/attendance_marks.dart';
import 'package:admin_app/staff/students/models/student_att_model.dart';
import 'package:admin_app/staff/students/models/student_response_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_avatar.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentAttendanceTile extends StatefulWidget {
  final StudentModel student;
  final List<Remark> remarks;

  const StudentAttendanceTile({
    super.key,
    required this.student,
    required this.remarks,
  });

  @override
  State<StudentAttendanceTile> createState() => _StudentAttendanceTileState();
}

class _StudentAttendanceTileState extends State<StudentAttendanceTile> {
  late String _comment = widget.student.att?.comment ?? '';

  @override
  void didUpdateWidget(StudentAttendanceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.att != widget.student.att) {
      _comment = widget.student.att?.comment ?? '';
    }
  }

  void _mark(bool present, {String? remark}) {
    final student = widget.student;
    final current = student.att;
    final side = present ? attendancePresent : attendanceAbsent;
    final pool = remarksFor(widget.remarks, present: present);
    final keep =
        current?.att == side && pool.any((item) => item.key == current?.remark);
    final key =
        remark ??
        (keep
            ? current!.remark
            : defaultRemarkKey(widget.remarks, present: present));
    context.read<StudentAttendanceBloc>().add(
      UpdateStudentAttendanceEvent(
        studcode: student.studcode,
        studentAttendance: StudentAttModel(
          id: current?.id ?? '',
          studcode: student.studcode,
          comment: _comment,
          remark: key,
          att: side,
        ),
      ),
    );
  }

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _comment);
    final saved = await showStaffSheet<String>(
      context,
      title: 'Note',
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StaffField(
              label: 'Note',
              hint: 'Optional',
              controller: controller,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 12),
            AmberButton(
              label: 'Save note',
              onPressed: () => Navigator.pop(context, controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || saved == null) return;
    setState(() => _comment = saved);
    final current = widget.student.att;
    if (current == null || !current.isMarked) return;
    context.read<StudentAttendanceBloc>().add(
      UpdateStudentAttendanceEvent(
        studcode: widget.student.studcode,
        studentAttendance: current.copyWith(
          comment: saved,
          studcode: widget.student.studcode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final student = widget.student;
    final present = student.att?.att == attendancePresent;
    final absent = student.att?.att == attendanceAbsent;
    final pool = present
        ? remarksFor(widget.remarks, present: true)
        : absent
        ? remarksFor(widget.remarks, present: false)
        : const <Remark>[];
    final selectedRemark = pool.any((item) => item.key == student.att?.remark)
        ? student.att!.remark
        : null;

    return StaffCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StaffAvatar(name: student.displayName, photo: student.photo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: sora(15, weight: FontWeight.w700, color: p.text),
                    ),
                    if (student.studcode.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Adm ${student.studcode}',
                        style: sora(
                          12,
                          weight: FontWeight.w500,
                          color: p.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              InkWell(
                onTap: _editNote,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Text(
                    'Note',
                    style: sora(
                      12.5,
                      weight: FontWeight.w700,
                      color: p.amberText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (student.bornOn.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Born ${student.bornOn}',
              style: sora(12, weight: FontWeight.w500, color: p.muted),
            ),
          ],
          if (_comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _comment,
              style: sora(12.5, weight: FontWeight.w500, color: p.text),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatusButton(
                  label: 'Present',
                  selected: present,
                  fill: const Color(0xFF059669),
                  onTap: () => _mark(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusButton(
                  label: 'Absent',
                  selected: absent,
                  fill: p.danger,
                  onTap: () => _mark(false),
                ),
              ),
            ],
          ),
          if (pool.isNotEmpty) ...[
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: p.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    isDense: true,
                    value: selectedRemark,
                    hint: Text(
                      'Remark',
                      style: sora(13, weight: FontWeight.w500, color: p.muted),
                    ),
                    dropdownColor: p.surfaceRaised,
                    icon: Icon(Icons.keyboard_arrow_down, color: p.muted),
                    style: sora(13, weight: FontWeight.w600, color: p.text),
                    onChanged: (key) {
                      if (key == null) return;
                      _mark(present, remark: key);
                    },
                    items: [
                      for (final remark in pool)
                        DropdownMenuItem<String>(
                          value: remark.key,
                          child: Text(
                            remark.value.isEmpty ? remark.key : remark.value,
                            overflow: TextOverflow.ellipsis,
                            style: sora(
                              13,
                              weight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.selected,
    required this.fill,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color fill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : fill;
    return Material(
      color: selected ? fill : fill.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? fill : fill.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            label,
            style: sora(13, weight: FontWeight.w700, color: foreground),
          ),
        ),
      ),
    );
  }
}
