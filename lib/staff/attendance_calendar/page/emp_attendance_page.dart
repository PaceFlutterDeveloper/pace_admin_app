import 'dart:math' as math;

import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_model.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_month_summary.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_record_status.dart';
import 'package:admin_app/staff/attendance_calendar/utils/attendance_status_style.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/leave/domain/leave_repository.dart';
import 'package:admin_app/staff/leave/presentation/leave_apply_sheet.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Stroke path for the header filter, on the same 24 grid as [StaffGlyphs].
const _filterGlyph = 'M22 3H2l8 9.46V19l4 2v-8.54L22 3z';

/// Monthly attendance: summary ring, tinted calendar, and the selected day.
class EmpAttendancePage extends StatefulWidget {
  const EmpAttendancePage({super.key, required this.menuModel});

  final MenuModel menuModel;

  @override
  State<EmpAttendancePage> createState() => _EmpAttendancePageState();
}

class _EmpAttendancePageState extends State<EmpAttendancePage> {
  late DateTime _month = _monthOf(DateTime.now());
  late DateTime _selected = DateUtils.dateOnly(DateTime.now());
  AttendanceDayKind? _lens;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceCubit>().getAttendance(
      month: _month.month,
      year: _month.year,
    );
  }

  DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  bool _isFutureMonth(DateTime month) {
    final now = DateTime.now();
    return month.year > now.year ||
        (month.year == now.year && month.month > now.month);
  }

  void _shiftMonth(int by) {
    final next = DateTime(_month.year, _month.month + by);
    if (_isFutureMonth(next)) return;
    final now = DateTime.now();
    setState(() {
      _month = next;
      _selected = next.year == now.year && next.month == now.month
          ? DateUtils.dateOnly(now)
          : DateTime(next.year, next.month + 1, 0);
    });
    context.read<AttendanceCubit>().getAttendance(
      month: next.month,
      year: next.year,
    );
  }

  Future<void> _refresh() {
    return context.read<AttendanceCubit>().getAttendance(
      month: _month.month,
      year: _month.year,
      quiet: true,
    );
  }

  Future<void> _pickLens(_AttendanceColors colors) async {
    final picked = await showStaffSheet<_LensChoice>(
      context,
      title: 'Highlight days',
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final choice in _lensChoices)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: _lensMark(choice.kind, colors),
                  title: Text(
                    choice.label,
                    style: sora(
                      14,
                      weight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                  trailing: _lens == choice.kind
                      ? StaffIcon(
                          StaffGlyphs.check,
                          size: 18,
                          color: colors.amber,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, choice),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) setState(() => _lens = picked.kind);
  }

  Future<void> _showLeaveBreakdown(
    List<AttendanceModel> rows,
    _AttendanceColors colors,
  ) {
    final counts = leaveTypeCounts(
      rows: rows,
      month: _month,
      today: DateTime.now(),
    );
    final tone = AttendanceMarkStyle.of(
      AttendanceDayKind.leave,
      isDark: colors.isDark,
    );
    return showStaffSheet<void>(
      context,
      title: 'Leave',
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
          child: counts.isEmpty
              ? Text(
                  'No leave this month',
                  style: sora(14, weight: FontWeight.w400, color: colors.muted),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in counts)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.type,
                                style: sora(
                                  15,
                                  weight: FontWeight.w500,
                                  color: colors.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${item.count}',
                              style: sora(
                                16,
                                weight: FontWeight.w600,
                                color: tone.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _applyLeave() async {
    final done = await showLeaveApplySheet(
      context,
      locator<LeaveRepository>(),
      day: _selected,
    );
    if (done == true && mounted) {
      AppToast.success(context, 'Leave request sent');
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _AttendanceColors.of(context);
    final title = widget.menuModel.menuName.trim().isEmpty
        ? 'Attendance'
        : widget.menuModel.menuName.trim();

    return Scaffold(
      backgroundColor: colors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: title,
              colors: colors,
              filterActive: _lens != null,
              onBack: () => Navigator.of(context).maybePop(),
              onFilter: () => _pickLens(colors),
            ),
            Expanded(
              child: BlocBuilder<AttendanceCubit, AttendanceState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => _spinner(colors),
                    loading: () => _spinner(colors),
                    laodingFailure: (message) => _Error(
                      message: message,
                      colors: colors,
                      onRetry: () =>
                          context.read<AttendanceCubit>().getAttendance(
                            month: _month.month,
                            year: _month.year,
                          ),
                    ),
                    loadingSuccess: (rows) => _loaded(colors, rows),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spinner(_AttendanceColors colors) {
    return Center(
      child: CircularProgressIndicator(color: colors.amber, strokeWidth: 2.4),
    );
  }

  Widget _loaded(_AttendanceColors colors, List<AttendanceModel> rows) {
    final today = DateTime.now();
    final summary = summarizeAttendanceMonth(
      rows: rows,
      month: _month,
      today: today,
    );
    final monthRows = [
      for (final row in rows)
        if (row.attDate.year == _month.year &&
            row.attDate.month == _month.month)
          row,
    ];
    final weekends = attendanceWeekendWeekdays(monthRows);
    final byDay = <int, AttendanceModel>{
      for (final row in monthRows) row.attDate.day: row,
    };
    final selectedRow = byDay[_selected.day];
    final selectedKind =
        _selected.year == _month.year && _selected.month == _month.month
        ? attendanceDayAppearance(
            date: _selected,
            row: selectedRow,
            weekendWeekdays: weekends,
          )
        : AttendanceDayKind.unmarked;

    return RefreshIndicator(
      color: colors.amber,
      backgroundColor: colors.card,
      onRefresh: _refresh,
      child: ListView(
        physics: staffScrollPhysics,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
        children: [
          _SummaryCard(
            colors: colors,
            month: _month,
            summary: summary,
            active: _lens,
            onStatus: (kind) => setState(() {
              _lens = _lens == kind ? null : kind;
            }),
            onLeave: () => _showLeaveBreakdown(monthRows, colors),
          ),
          const SizedBox(height: 12),
          _CalendarCard(
            colors: colors,
            month: _month,
            selected: _selected,
            byDay: byDay,
            weekends: weekends,
            lens: _lens,
            canGoForward: !_isFutureMonth(
              DateTime(_month.year, _month.month + 1),
            ),
            onPrevious: () => _shiftMonth(-1),
            onNext: () => _shiftMonth(1),
            onSelect: (day) => setState(() => _selected = day),
          ),
          const SizedBox(height: 12),
          _DayCard(
            colors: colors,
            day: _selected,
            row: selectedRow,
            kind: selectedKind,
            onApply: _applyLeave,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.colors,
    required this.filterActive,
    required this.onBack,
    required this.onFilter,
  });

  final String title;
  final _AttendanceColors colors;
  final bool filterActive;
  final VoidCallback onBack;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
      child: Row(
        children: [
          _IconHit(
            glyph: StaffGlyphs.chevronLeft,
            color: colors.text,
            label: 'Back',
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(16, weight: FontWeight.w500, color: colors.text),
            ),
          ),
          _IconHit(
            glyph: _filterGlyph,
            size: 18,
            color: filterActive ? colors.amber : colors.muted,
            label: 'Highlight days',
            onTap: onFilter,
            dotColor: filterActive ? colors.amber : null,
          ),
        ],
      ),
    );
  }
}

class _IconHit extends StatelessWidget {
  const _IconHit({
    required this.glyph,
    required this.color,
    required this.label,
    required this.onTap,
    this.size = 20,
    this.dotColor,
  });

  final String glyph;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final double size;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              StaffIcon(glyph, size: size, color: color),
              if (dotColor != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.colors,
    required this.month,
    required this.summary,
    required this.active,
    required this.onStatus,
    required this.onLeave,
  });

  final _AttendanceColors colors;
  final DateTime month;
  final AttendanceMonthSummary summary;
  final AttendanceDayKind? active;
  final ValueChanged<AttendanceDayKind> onStatus;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final streak = summary.streakLabel;
    return _Panel(
      colors: colors,
      child: Column(
        children: [
          Row(
            children: [
              _Ring(percentage: summary.percentage, colors: colors),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('MMMM').format(month)} summary',
                      style: sora(
                        11,
                        weight: FontWeight.w400,
                        color: colors.muted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.attendedLine,
                      style: sora(
                        15,
                        weight: FontWeight.w500,
                        color: colors.text,
                      ),
                    ),
                    if (streak != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        streak,
                        style: sora(
                          12,
                          weight: FontWeight.w400,
                          color: _tone(
                            AttendanceDayKind.absent,
                            colors,
                          ).foreground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (index, kind) in const [
                AttendanceDayKind.present,
                AttendanceDayKind.absent,
                AttendanceDayKind.late,
                AttendanceDayKind.leave,
              ].indexed) ...[
                if (index > 0) const SizedBox(width: 6),
                Expanded(child: _statusChip(kind)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(AttendanceDayKind kind) {
    final tone = _tone(kind, colors);
    final count = switch (kind) {
      AttendanceDayKind.present => summary.present,
      AttendanceDayKind.absent => summary.absent,
      AttendanceDayKind.late => summary.late,
      AttendanceDayKind.leave => summary.leave,
      _ => 0,
    };
    return _CountChip(
      value: '$count',
      label: _dayLabel(null, kind),
      valueColor: tone.foreground,
      colors: colors,
      badge: tone.badge,
      selected: kind == AttendanceDayKind.leave ? false : active == kind,
      onTap: kind == AttendanceDayKind.leave ? onLeave : () => onStatus(kind),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.percentage, required this.colors});

  final int percentage;
  final _AttendanceColors colors;

  @override
  Widget build(BuildContext context) {
    final progress = percentage <= 0
        ? 0.0
        : percentage >= 100
        ? 1.0
        : percentage / 100;
    return Semantics(
      label: '$percentage percent attendance',
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size.square(64),
              painter: _RingPainter(
                progress: progress,
                track: colors.ringTrack,
                value: colors.amber,
              ),
            ),
            SizedBox(
              width: 40,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$percentage%',
                  style: sora(14, weight: FontWeight.w500, color: colors.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.value,
  });

  final double progress;
  final Color track;
  final Color value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 26.0;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, stroke..color = track);
    if (progress <= 0) return;
    final fraction = progress < 0
        ? 0.0
        : progress > 1
        ? 1.0
        : progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      stroke..color = value,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.track != track ||
        oldDelegate.value != value;
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.colors,
    required this.month,
    required this.selected,
    required this.byDay,
    required this.weekends,
    required this.lens,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  final _AttendanceColors colors;
  final DateTime month;
  final DateTime selected;
  final Map<int, AttendanceModel> byDay;
  final Set<int> weekends;
  final AttendanceDayKind? lens;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday % 7;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const SizedBox(height: 38),
      for (var day = 1; day <= days; day++)
        _cell(DateTime(month.year, month.month, day)),
    ];

    return _Panel(
      colors: colors,
      child: Column(
        children: [
          Row(
            children: [
              _MonthButton(
                glyph: StaffGlyphs.chevronLeft,
                label: 'Previous month',
                colors: colors,
                onTap: onPrevious,
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(month),
                  textAlign: TextAlign.center,
                  style: sora(15, weight: FontWeight.w500, color: colors.text),
                ),
              ),
              _MonthButton(
                glyph: StaffGlyphs.chevronRight,
                label: 'Next month',
                colors: colors,
                enabled: canGoForward,
                onTap: canGoForward ? onNext : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _WeekRow(
            children: [
              for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: sora(11, weight: FontWeight.w400, color: colors.muted),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < cells.length; i += 7) ...[
            if (i > 0) const SizedBox(height: 5),
            _WeekRow(
              children: [
                for (var col = 0; col < 7; col++)
                  i + col < cells.length
                      ? cells[i + col]
                      : const SizedBox(height: 38),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              for (final kind in const [
                AttendanceDayKind.present,
                AttendanceDayKind.absent,
                AttendanceDayKind.late,
                AttendanceDayKind.leave,
                AttendanceDayKind.holiday,
                AttendanceDayKind.weekend,
              ])
                _LegendDot(
                  label: _dayLabel(null, kind),
                  tone: _tone(kind, colors),
                  text: colors.muted,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _PunchKey(label: 'Punch in', color: _punchIn, text: colors.muted),
              _PunchKey(
                label: 'Punch out',
                color: _punchOut,
                text: colors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(DateTime date) {
    final row = byDay[date.day];
    final kind = attendanceDayAppearance(
      date: date,
      row: row,
      weekendWeekdays: weekends,
    );
    final tone = _tone(kind, colors);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isSelected = DateUtils.isSameDay(date, selected);
    final faded = _faded(kind);
    final status = _dayLabel(row, kind);
    final punches = attendanceShowsPunchDots(row, kind);
    final ring = isToday
        ? colors.amber
        : isSelected
        ? colors.text
        : null;
    final punchLabel = !punches || row == null
        ? ''
        : ', ${row.hasPunchIn ? 'punched in' : 'missed punch in'}'
              ', ${row.hasPunchOut ? 'punched out' : 'missed punch out'}';
    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${DateFormat('MMMM d').format(date)}, $status${isToday ? ', today' : ''}$punchLabel',
      child: SizedBox(
        height: 38,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: faded ? 0.3 : 1,
                child: Material(
                  color: tone.background ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelect(date);
                    },
                    child: Stack(
                      children: [
                        Align(
                          alignment: punches
                              ? const Alignment(0, -0.45)
                              : Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: sora(
                              13,
                              weight: FontWeight.w500,
                              color: tone.foreground,
                            ),
                          ),
                        ),
                        if (tone.badge != null)
                          Positioned(
                            top: 3,
                            right: 3,
                            child: StaffIcon(
                              tone.badge!,
                              size: 9,
                              color: tone.foreground,
                              strokeWidth: 1.6,
                            ),
                          ),
                        if (punches && row != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 3,
                            child: _PunchPair(
                              punchedIn: row.hasPunchIn,
                              punchedOut: row.hasPunchOut,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (ring != null)
              Positioned(
                left: -3,
                top: -3,
                right: -3,
                bottom: -3,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: ring, width: 2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _faded(AttendanceDayKind kind) {
    final lens = this.lens;
    if (lens == null || kind == lens) return false;
    return kind != AttendanceDayKind.weekend &&
        kind != AttendanceDayKind.holiday &&
        kind != AttendanceDayKind.unmarked;
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.glyph,
    required this.label,
    required this.colors,
    required this.onTap,
    this.enabled = true,
  });

  final String glyph;
  final String label;
  final _AttendanceColors colors;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.chip,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: StaffIcon(
                  glyph,
                  size: 16,
                  color: enabled ? colors.text : colors.weekend,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.colors,
    required this.day,
    required this.row,
    required this.kind,
    required this.onApply,
  });

  final _AttendanceColors colors;
  final DateTime day;
  final AttendanceModel? row;
  final AttendanceDayKind kind;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final label = _dayLabel(row, kind);
    final tone = _tone(kind, colors);
    final checkIn = row == null ? '' : row!.checkInTime;
    final checkOut = row == null ? '' : row!.checkOutTime;
    final variance = row == null ? null : attendanceVarianceLabel(row!);
    final today = DateUtils.dateOnly(DateTime.now());
    final dayOnly = DateUtils.dateOnly(day);
    final isFuture = dayOnly.isAfter(today);
    final canApply = kind == AttendanceDayKind.absent && !isFuture;
    final pillColor = tone.background == null ? colors.muted : tone.foreground;
    return _Panel(
      colors: colors,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Column(
          key: ValueKey(dayOnly),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEE, d MMM').format(day),
                    style: sora(
                      15,
                      weight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: tone.background ?? colors.chip,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tone.badge != null) ...[
                        StaffIcon(tone.badge!, size: 12, color: pillColor),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        label,
                        style: sora(
                          12,
                          weight: FontWeight.w500,
                          color: pillColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CountChip(
                    label: 'In',
                    value: attendancePunchLabel(checkIn),
                    valueColor: colors.text,
                    colors: colors,
                    labelFirst: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CountChip(
                    label: 'Out',
                    value: attendancePunchLabel(checkOut),
                    valueColor: colors.text,
                    colors: colors,
                    labelFirst: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CountChip(
                    label: 'Hours',
                    value: attendanceHoursLabel(checkIn, checkOut),
                    valueColor: colors.text,
                    colors: colors,
                    labelFirst: true,
                  ),
                ),
              ],
            ),
            if (variance != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  variance,
                  style: sora(
                    12,
                    weight: FontWeight.w500,
                    color: _tone(AttendanceDayKind.late, colors).foreground,
                  ),
                ),
              ),
            ],
            if (canApply) ...[
              const SizedBox(height: 10),
              Material(
                color: colors.amber,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onApply();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        'Apply leave for this day',
                        style: sora(
                          14,
                          weight: FontWeight.w500,
                          color: colors.onAmber,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ] else if (isFuture && kind == AttendanceDayKind.unmarked) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No record yet',
                  style: sora(12, weight: FontWeight.w400, color: colors.muted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.colors,
    this.labelFirst = false,
    this.badge,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final String value;
  final Color valueColor;
  final _AttendanceColors colors;
  final bool labelFirst;
  final String? badge;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final figure = Text(
      value,
      textAlign: TextAlign.center,
      style: sora(
        labelFirst ? 14 : 16,
        weight: FontWeight.w500,
        color: valueColor,
      ),
    );
    final caption = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null) ...[
          StaffIcon(badge!, size: 10, color: valueColor, strokeWidth: 1.6),
          const SizedBox(width: 3),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: sora(11, weight: FontWeight.w400, color: colors.muted),
          ),
        ),
      ],
    );
    final body = Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: onTap == null ? 0 : 44),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: colors.chip,
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: colors.amber, width: 1) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: labelFirst ? [caption, figure] : [figure, caption],
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: body,
      ),
    );
  }
}

const _punchIn = Color(0xFF3DDC84);
const _punchOut = Color(0xFFFF5C5C);

/// Green spot for punch-in, red spot for punch-out. A missed punch stays
/// an empty ring in that spot.
class _PunchPair extends StatelessWidget {
  const _PunchPair({required this.punchedIn, required this.punchedOut});

  final bool punchedIn;
  final bool punchedOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PunchDot(filled: punchedIn, color: _punchIn),
        const SizedBox(width: 6),
        _PunchDot(filled: punchedOut, color: _punchOut),
      ],
    );
  }
}

class _PunchDot extends StatelessWidget {
  const _PunchDot({required this.filled, required this.color});

  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(
          color: filled ? color : color.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
    );
  }
}

class _PunchKey extends StatelessWidget {
  const _PunchKey({
    required this.label,
    required this.color,
    required this.text,
  });

  final String label;
  final Color color;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: sora(11, weight: FontWeight.w400, color: text)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.label,
    required this.tone,
    required this.text,
  });

  final String label;
  final _Tone tone;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tone.badge != null)
          StaffIcon(
            tone.badge!,
            size: 11,
            color: tone.foreground,
            strokeWidth: 1.6,
          )
        else
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: tone.foreground,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: sora(11, weight: FontWeight.w400, color: text),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.colors, required this.child});

  final _AttendanceColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.cardBorder, width: 0.5),
      ),
      child: child,
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({
    required this.message,
    required this.colors,
    required this.onRetry,
  });

  final String message;
  final _AttendanceColors colors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: sora(14, weight: FontWeight.w400, color: colors.muted),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try again',
                style: sora(14, weight: FontWeight.w500, color: colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LensChoice {
  const _LensChoice(this.label, this.kind);

  final String label;
  final AttendanceDayKind? kind;
}

const _lensChoices = <_LensChoice>[
  _LensChoice('All days', null),
  _LensChoice('Present', AttendanceDayKind.present),
  _LensChoice('Absent', AttendanceDayKind.absent),
  _LensChoice('Late', AttendanceDayKind.late),
  _LensChoice('Leave', AttendanceDayKind.leave),
];

class _Tone {
  const _Tone(this.background, this.foreground, this.badge);

  final Color? background;
  final Color foreground;
  final String? badge;
}

_Tone _tone(AttendanceDayKind kind, _AttendanceColors colors) {
  final mark = AttendanceMarkStyle.of(kind, isDark: colors.isDark);
  return _Tone(mark.background, mark.foreground, mark.badge);
}

Widget _lensMark(AttendanceDayKind? kind, _AttendanceColors colors) {
  if (kind == null) {
    return Icon(Icons.circle, size: 10, color: colors.muted);
  }
  final tone = _tone(kind, colors);
  if (tone.badge != null) {
    return StaffIcon(tone.badge!, size: 16, color: tone.foreground);
  }
  return Icon(Icons.circle, size: 10, color: tone.foreground);
}

String _dayLabel(AttendanceModel? row, AttendanceDayKind kind) {
  if (row != null && attendanceDayKind(row) != AttendanceDayKind.unmarked) {
    return attendanceRecordStatusLabel(row);
  }
  switch (kind) {
    case AttendanceDayKind.weekend:
      return 'Weekend';
    case AttendanceDayKind.holiday:
      return 'Holiday';
    case AttendanceDayKind.present:
      return 'Present';
    case AttendanceDayKind.absent:
      return 'Absent';
    case AttendanceDayKind.late:
      return 'Late';
    case AttendanceDayKind.leave:
      return 'Leave';
    case AttendanceDayKind.unmarked:
      return 'Not marked';
  }
}

/// Colours taken from the attendance mockup. Light mode keeps the same
/// structure with paper surfaces.
class _AttendanceColors {
  const _AttendanceColors({
    required this.page,
    required this.card,
    required this.cardBorder,
    required this.chip,
    required this.text,
    required this.muted,
    required this.weekend,
    required this.amber,
    required this.onAmber,
    required this.ringTrack,
    required this.isDark,
  });

  final Color page;
  final Color card;
  final Color cardBorder;
  final Color chip;
  final Color text;
  final Color muted;
  final Color weekend;
  final Color amber;
  final Color onAmber;
  final Color ringTrack;
  final bool isDark;

  static const dark = _AttendanceColors(
    page: Color(0xFF0E1118),
    card: Color(0xFF1A1F2B),
    cardBorder: Color(0xFF2A3040),
    chip: Color(0xFF252B39),
    text: Color(0xFFE8EAF0),
    muted: Color(0xFF9AA0AE),
    weekend: Color(0xFF5C6273),
    amber: Color(0xFFF2A93B),
    onAmber: Color(0xFF3A2400),
    ringTrack: Color(0xFF2A3040),
    isDark: true,
  );

  static const light = _AttendanceColors(
    page: Color(0xFFEEF0F4),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE3E6EE),
    chip: Color(0xFFF0F2F6),
    text: Color(0xFF14161C),
    muted: Color(0xFF6B7285),
    weekend: Color(0xFF9AA0AE),
    amber: Color(0xFFF2A93B),
    onAmber: Color(0xFF3A2400),
    ringTrack: Color(0xFFE3E6EE),
    isDark: false,
  );

  static _AttendanceColors of(BuildContext context) {
    return StaffPalette.of(context).isDark ? dark : light;
  }
}
