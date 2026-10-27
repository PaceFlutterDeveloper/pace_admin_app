import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/approvals/domain/approval_models.dart';
import 'package:admin_app/staff/approvals/domain/approvals_repository.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_avatar.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Menu > Approvals: requests waiting for me, and the ones I already decided.
class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key, this.title = 'Approvals'});

  final String title;

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  late final ApprovalsRepository _repository = locator<ApprovalsRepository>();
  late LoadCubit<ApprovalList> _cubit = _makeCubit(true);
  bool _pending = true;

  LoadCubit<ApprovalList> _makeCubit(bool pending) =>
      LoadCubit(() => _repository.list(pending: pending))..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _switch(int index) {
    final pending = index == 0;
    if (pending == _pending) return;
    final old = _cubit;
    setState(() {
      _pending = pending;
      _cubit = _makeCubit(pending);
    });
    old.close();
  }

  Future<void> _open(StaffApproval item) async {
    final changed = await showStaffSheet<bool>(
      context,
      title: item.title.isEmpty ? 'Approval' : item.title,
      builder: (_) => _ApprovalDetail(repository: _repository, item: item),
    );
    if (changed == true && mounted) {
      AppToast.success(context, 'Decision saved');
      _cubit.load(quiet: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffPage(
      child: Column(
        children: [
          StaffPageHeader(
            title: widget.title,
            subtitle: 'Decisions waiting on you',
          ),
          StaffFilterRow(
            labels: const ['Pending', 'Done'],
            selected: _pending ? 0 : 1,
            onSelect: _switch,
          ),
          Expanded(
            child: BlocProvider.value(
              value: _cubit,
              child: StaffLoadView<ApprovalList>(
                key: ValueKey(_pending),
                errorGlyph: StaffGlyphs.check,
                errorTitle: 'Could not load approvals',
                builder: (context, data) {
                  if (data.items.isEmpty) {
                    return StaffEmptyList(
                      glyph: StaffGlyphs.check,
                      title: _pending ? 'All caught up' : 'Nothing decided yet',
                      message: _pending
                          ? 'Requests that need your decision will appear here.'
                          : 'Requests you approve or reject will be listed here.',
                    );
                  }
                  return ListView.separated(
                    physics: staffScrollPhysics,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: data.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _ApprovalCard(
                      item: data.items[i],
                      onTap: () => _open(data.items[i]),
                    ),
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

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.item, required this.onTap});

  final StaffApproval item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      radius: 20,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaffAvatar(name: item.requesterName, photo: item.requesterPhoto),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.requesterName.isEmpty ? item.title : item.requesterName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sora(14, weight: FontWeight.w700, color: p.text),
                ),
                if (item.requesterRole.isNotEmpty)
                  Text(
                    item.requesterRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sora(11.5, color: p.muted),
                  ),
                const SizedBox(height: 6),
                Text(
                  [item.title, item.summary]
                      .where((e) => e.isNotEmpty && e != item.requesterName)
                      .join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: sora(12.5, weight: FontWeight.w500, color: p.text),
                ),
                if (item.submittedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d MMM, h:mm a').format(item.submittedAt!),
                      style: sora(11, color: p.muted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalDetail extends StatefulWidget {
  const _ApprovalDetail({required this.repository, required this.item});

  final ApprovalsRepository repository;
  final StaffApproval item;

  @override
  State<_ApprovalDetail> createState() => _ApprovalDetailState();
}

class _ApprovalDetailState extends State<_ApprovalDetail> {
  late StaffApproval _item = widget.item;
  final _comment = TextEditingController();
  bool _rejecting = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final full = await widget.repository.detail(widget.item.id);
      if (mounted) setState(() => _item = full);
    } catch (_) {
      // The card data is enough to decide; details just stay short.
    }
  }

  Future<void> _decide(bool approve) async {
    if (!approve && _comment.text.trim().isEmpty) {
      setState(() => _error = 'Write a reason before rejecting.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.decide(
        _item.id,
        approve: approve,
        comment: _comment.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = staffErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final item = _item;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              StaffAvatar(name: item.requesterName, photo: item.requesterPhoto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.requesterName,
                      style: sora(14.5, weight: FontWeight.w700, color: p.text),
                    ),
                    if (item.requesterRole.isNotEmpty)
                      Text(item.requesterRole, style: sora(12, color: p.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (item.summary.isNotEmpty)
            Text(
              item.summary,
              style: sora(13.5, weight: FontWeight.w500, color: p.text),
            ),
          for (final (label, value) in item.details)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(label, style: sora(12, color: p.muted)),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: sora(13, weight: FontWeight.w600, color: p.text),
                    ),
                  ),
                ],
              ),
            ),
          if (item.comment.isNotEmpty && !item.isPending) ...[
            const SizedBox(height: 12),
            Text('Comment: ${item.comment}', style: sora(12.5, color: p.muted)),
          ],
          if (item.isPending) ...[
            const SizedBox(height: 16),
            if (_rejecting)
              StaffField(
                label: 'Reason for rejecting',
                controller: _comment,
                maxLines: 3,
                autofocus: true,
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: sora(
                    12.5,
                    weight: FontWeight.w500,
                    color: p.dangerText,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AmberButton(
                    label: _rejecting ? 'Confirm reject' : 'Reject',
                    soft: true,
                    onPressed: _busy
                        ? null
                        : () => _rejecting
                              ? _decide(false)
                              : setState(() => _rejecting = true),
                  ),
                ),
                if (!_rejecting) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: AmberButton(
                      label: 'Approve',
                      loading: _busy,
                      onPressed: _busy ? null : () => _decide(true),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
