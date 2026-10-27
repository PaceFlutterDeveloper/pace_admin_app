import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/reports/domain/report_models.dart';
import 'package:admin_app/staff/reports/domain/reports_repository.dart';
import 'package:admin_app/staff/reports/presentation/report_view_page.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Menu > Reports: the reports this role may run.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, this.title = 'Reports'});

  final String title;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ReportsRepository _repository = locator<ReportsRepository>();
  late final LoadCubit<List<ReportInfo>> _cubit = LoadCubit(
    _repository.available,
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return BlocProvider.value(
      value: _cubit,
      child: StaffPage(
        child: Column(
          children: [
            StaffPageHeader(
              title: widget.title,
              subtitle: 'Summaries for leaders',
            ),
            Expanded(
              child: StaffLoadView<List<ReportInfo>>(
                errorGlyph: StaffGlyphs.chart,
                errorTitle: 'Could not load reports',
                accent: StaffAccent.violet,
                builder: (context, reports) {
                  if (reports.isEmpty) {
                    return const StaffEmptyList(
                      glyph: StaffGlyphs.chart,
                      title: 'No reports for your role',
                      message:
                          'Ask the school office if you expected to see some.',
                      accent: StaffAccent.violet,
                    );
                  }
                  return ListView.separated(
                    physics: staffScrollPhysics,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: reports.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => StaffCard(
                      radius: 20,
                      padding: const EdgeInsets.all(14),
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => ReportViewPage(
                            report: reports[i],
                            repository: _repository,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const GlassIconTile(
                            glyph: StaffGlyphs.chart,
                            accent: StaffAccent.violet,
                            size: 42,
                            radius: 14,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reports[i].name,
                              style: sora(
                                14,
                                weight: FontWeight.w700,
                                color: p.text,
                              ),
                            ),
                          ),
                          StaffIcon(
                            StaffGlyphs.chevronRight,
                            size: 18,
                            color: p.muted,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
