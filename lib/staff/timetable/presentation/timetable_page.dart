import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/timetable/domain/timetable_models.dart';
import 'package:admin_app/staff/timetable/domain/timetable_repository.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Monday of the week that contains [day].
DateTime weekStartOf(DateTime day) {
  final date = DateTime(day.year, day.month, day.day);
  return date.subtract(Duration(days: date.weekday - 1));
}

/// Menu > Timetable: my periods, one weekday at a time.
class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key, this.title = 'Timetable'});

  final String title;

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late final TimetableRepository _repository = locator<TimetableRepository>();
  late DateTime _weekStart = weekStartOf(DateTime.now());
  late int _weekday = DateTime.now().weekday;
  late LoadCubit<List<TimetablePeriod>> _cubit = _make();

  LoadCubit<List<TimetablePeriod>> _make() {
    final start = _weekStart;
    return LoadCubit(() => _repository.week(start))..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _moveWeek(int by) {
    final old = _cubit;
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * by));
      _cubit = _make();
    });
    old.close();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final weekEnd = _weekStart.add(const Duration(days: 6));
    return StaffPage(
      child: Column(
        children: [
          StaffPageHeader(
            title: widget.title,
            subtitle:
                '${DateFormat('d MMM').format(_weekStart)} – ${DateFormat('d MMM').format(weekEnd)}',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StaffIconButton(
                  glyph: StaffGlyphs.chevronLeft,
                  semanticLabel: 'Previous week',
                  onTap: () => _moveWeek(-1),
                ),
                const SizedBox(width: 8),
                StaffIconButton(
                  glyph: StaffGlyphs.chevronRight,
                  semanticLabel: 'Next week',
                  onTap: () => _moveWeek(1),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              itemCount: 7,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final date = _weekStart.add(Duration(days: i));
                final selected = _weekday == i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _weekday = i + 1),
                  child: Container(
                    width: 52,
                    decoration: BoxDecoration(
                      color: selected ? p.amber : p.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? p.amber : p.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: sora(
                            11,
                            weight: FontWeight.w600,
                            color: selected ? p.onAmber : p.muted,
                          ),
                        ),
                        Text(
                          '${date.day}',
                          style: sora(
                            16,
                            weight: FontWeight.w700,
                            color: selected ? p.onAmber : p.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: BlocProvider.value(
              value: _cubit,
              child: StaffLoadView<List<TimetablePeriod>>(
                key: ValueKey(_weekStart),
                errorGlyph: StaffGlyphs.clock,
                errorTitle: 'Could not load timetable',
                accent: StaffAccent.violet,
                builder: (context, all) {
                  final day = [
                    for (final period in all)
                      if (period.weekday == _weekday) period,
                  ];
                  if (day.isEmpty) {
                    return StaffEmptyList(
                      glyph: StaffGlyphs.clock,
                      title: all.isEmpty
                          ? 'No timetable this week'
                          : 'No periods',
                      message: all.isEmpty
                          ? 'Your periods will show here once the school publishes them.'
                          : 'Nothing is scheduled for this day.',
                      accent: StaffAccent.violet,
                    );
                  }
                  return ListView.separated(
                    physics: staffScrollPhysics,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: day.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _PeriodCard(period: day[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.period});

  final TimetablePeriod period;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final times = [
      period.start,
      period.end,
    ].where((e) => e.isNotEmpty).join(' – ');
    final meta = [
      if (period.classLabel.isNotEmpty) period.classLabel,
      if (period.room.isNotEmpty) 'Room ${period.room}',
    ].join(' · ');
    return StaffCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.tint(StaffAccent.violet).background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              period.periodNo > 0 ? 'P${period.periodNo}' : '·',
              style: sora(
                13,
                weight: FontWeight.w700,
                color: p.tint(StaffAccent.violet).foreground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.subject.isEmpty ? 'Period' : period.subject,
                  style: sora(14, weight: FontWeight.w700, color: p.text),
                ),
                if (meta.isNotEmpty)
                  Text(meta, style: sora(12, color: p.muted)),
              ],
            ),
          ),
          if (times.isNotEmpty)
            Text(
              times,
              style: sora(11.5, weight: FontWeight.w600, color: p.amberText),
            ),
        ],
      ),
    );
  }
}
