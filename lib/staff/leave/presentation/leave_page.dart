import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/leave/domain/leave_models.dart';
import 'package:admin_app/staff/leave/domain/leave_repository.dart';
import 'package:admin_app/staff/leave/presentation/leave_apply_sheet.dart';
import 'package:admin_app/staff/leave/presentation/leave_detail_sheet.dart';
import 'package:admin_app/staff/leave/presentation/leave_format.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Menu > Leave: balances, my requests, and applying for leave.
class LeavePage extends StatefulWidget {
  const LeavePage({super.key, this.title = 'Leave'});

  final String title;

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  late final LeaveRepository _repository = locator<LeaveRepository>();
  late final LoadCubit<LeaveOverview> _cubit = LoadCubit(_repository.overview)
    ..load();
  int _filter = 0;

  static const _filters = <(String, LeaveStatus?)>[
    ('All', null),
    ('Pending', LeaveStatus.pending),
    ('Approved', LeaveStatus.approved),
    ('Rejected', LeaveStatus.rejected),
    ('Cancelled', LeaveStatus.cancelled),
  ];

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _apply() async {
    final done = await showLeaveApplySheet(context, _repository);
    if (done == true && mounted) {
      AppToast.success(context, 'Leave request sent');
      _cubit.load(quiet: true);
    }
  }

  Future<void> _open(LeaveRequest request) async {
    final changed = await showLeaveDetailSheet(context, _repository, request);
    if (changed == true && mounted) {
      AppToast.success(context, 'Leave request cancelled');
      _cubit.load(quiet: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: StaffPage(
        child: Column(
          children: [
            StaffPageHeader(
              title: widget.title,
              subtitle: 'Balance and requests',
            ),
            Expanded(
              child: StaffLoadView<LeaveOverview>(
                errorGlyph: StaffGlyphs.leave,
                errorTitle: 'Could not load leave',
                accent: StaffAccent.green,
                builder: (context, data) => _content(context, data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, LeaveOverview data) {
    final wanted = _filters[_filter].$2;
    final requests = [
      for (final r in data.requests)
        if (wanted == null || r.status == wanted) r,
    ];
    return ListView(
      physics: staffScrollPhysics,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (data.balances.isNotEmpty) _Balances(data.balances),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: AmberButton(
            label: 'Apply for leave',
            glyph: StaffGlyphs.plus,
            onPressed: _apply,
          ),
        ),
        StaffFilterRow(
          labels: [for (final f in _filters) f.$1],
          selected: _filter,
          onSelect: (i) => setState(() => _filter = i),
        ),
        if (requests.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: StaffStateMessage(
              glyph: StaffGlyphs.leave,
              title: data.requests.isEmpty
                  ? 'No leave requests yet'
                  : 'Nothing in this filter',
              message: data.requests.isEmpty
                  ? 'Requests you apply for will be listed here.'
                  : 'Try another status.',
              accent: StaffAccent.green,
            ),
          )
        else
          for (final r in requests)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: _RequestCard(request: r, onTap: () => _open(r)),
            ),
      ],
    );
  }
}

class _Balances extends StatelessWidget {
  const _Balances(this.balances);

  final List<LeaveBalance> balances;

  @override
  Widget build(BuildContext context) {
    final sorted = [...balances]
      ..sort((a, b) => b.remaining.compareTo(a.remaining));
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        itemCount: sorted.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _BalanceCard(sorted[i]),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(this.balance);

  final LeaveBalance balance;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return SizedBox(
      width: 150,
      child: StaffCard(
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              balance.type,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sora(11.5, weight: FontWeight.w600, color: p.muted),
            ),
            const Spacer(),
            Text(
              leaveNumber(balance.remaining),
              style: sora(
                24,
                weight: FontWeight.w700,
                color: p.text,
                letterSpacing: -0.6,
              ),
            ),
            Text(
              'left of ${leaveNumber(balance.entitled)}'
              '${balance.pending > 0 ? ' · ${leaveNumber(balance.pending)} pending' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(10.5, weight: FontWeight.w400, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onTap});

  final LeaveRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final half = leaveHalfLabel(request.halfDay);
    return StaffCard(
      radius: 20,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sora(14, weight: FontWeight.w700, color: p.text),
                ),
              ),
              const SizedBox(width: 8),
              LeaveStatusPill(request.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              leaveRange(request.from, request.to),
              half.isEmpty ? leaveDays(request.days) : half,
            ].where((e) => e.isNotEmpty).join(' · '),
            style: sora(12.5, weight: FontWeight.w500, color: p.muted),
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              request.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sora(12, weight: FontWeight.w400, color: p.muted),
            ),
          ],
        ],
      ),
    );
  }
}
