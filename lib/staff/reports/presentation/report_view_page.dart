import 'package:admin_app/staff/reports/domain/report_models.dart';
import 'package:admin_app/staff/reports/domain/reports_repository.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// One report: pick a period, see the headline numbers and a short table.
class ReportViewPage extends StatefulWidget {
  const ReportViewPage({
    super.key,
    required this.report,
    required this.repository,
  });

  final ReportInfo report;
  final ReportsRepository repository;

  @override
  State<ReportViewPage> createState() => _ReportViewPageState();
}

class _ReportViewPageState extends State<ReportViewPage> {
  late DateTimeRange _range = _thisMonth();
  late LoadCubit<ReportResult> _cubit = _make();

  static DateTimeRange _thisMonth() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  LoadCubit<ReportResult> _make() {
    final range = _range;
    return LoadCubit(
      () => widget.repository.run(
        widget.report.key,
        from: range.start,
        to: range.end,
      ),
    )..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null || !mounted) return;
    final old = _cubit;
    setState(() {
      _range = picked;
      _cubit = _make();
    });
    old.close();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final fmt = DateFormat('d MMM yyyy');
    return StaffPage(
      child: Column(
        children: [
          StaffPageHeader(title: widget.report.name),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: StaffCard(
              radius: 16,
              onTap: _pickRange,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  StaffIcon(StaffGlyphs.cal, size: 18, color: p.amberText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${fmt.format(_range.start)} – ${fmt.format(_range.end)}',
                      style: sora(13, weight: FontWeight.w600, color: p.text),
                    ),
                  ),
                  Text(
                    'Change',
                    style: sora(
                      12,
                      weight: FontWeight.w600,
                      color: p.amberText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocProvider.value(
              value: _cubit,
              child: StaffLoadView<ReportResult>(
                key: ValueKey(_range),
                errorGlyph: StaffGlyphs.chart,
                errorTitle: 'Could not run this report',
                accent: StaffAccent.violet,
                skeletonCount: 3,
                builder: (context, result) => _Result(result: result),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.result});

  final ReportResult result;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    if (result.summary.isEmpty && result.rows.isEmpty) {
      return const StaffEmptyList(
        glyph: StaffGlyphs.chart,
        title: 'No data for this period',
        message: 'Try a wider date range.',
        accent: StaffAccent.violet,
      );
    }
    return ListView(
      physics: staffScrollPhysics,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (result.summary.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (label, value) in result.summary)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 42) / 2,
                  child: StaffCard(
                    radius: 18,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: sora(
                            24,
                            weight: FontWeight.w700,
                            color: p.text,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(label, style: sora(11.5, color: p.muted)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        for (final row in result.rows)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StaffCard(
              radius: 16,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, column) in result.columns.indexed)
                    if ((row[column.$1] ?? '').isNotEmpty)
                      index == 0
                          ? Text(
                              row[column.$1]!,
                              style: sora(
                                13.5,
                                weight: FontWeight.w700,
                                color: p.text,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      column.$2,
                                      style: sora(12, color: p.muted),
                                    ),
                                  ),
                                  Text(
                                    row[column.$1]!,
                                    style: sora(
                                      12.5,
                                      weight: FontWeight.w600,
                                      color: p.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
