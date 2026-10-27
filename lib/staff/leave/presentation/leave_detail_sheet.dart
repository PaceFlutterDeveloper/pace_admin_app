import 'package:admin_app/staff/leave/domain/leave_models.dart';
import 'package:admin_app/staff/leave/domain/leave_repository.dart';
import 'package:admin_app/staff/leave/presentation/leave_format.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Returns true when the request was cancelled from the sheet.
Future<bool?> showLeaveDetailSheet(
  BuildContext context,
  LeaveRepository repository,
  LeaveRequest request,
) {
  return showStaffSheet<bool>(
    context,
    title: request.type,
    builder: (_) => _Detail(repository: repository, request: request),
  );
}

class _Detail extends StatefulWidget {
  const _Detail({required this.repository, required this.request});

  final LeaveRepository repository;
  final LeaveRequest request;

  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  late LeaveRequest _request = widget.request;
  bool _cancelling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// The list row has no approval trail, so fetch the full record.
  Future<void> _refresh() async {
    try {
      final full = await widget.repository.detail(widget.request.id);
      if (mounted) setState(() => _request = full);
    } catch (_) {
      // The list data is still correct; the trail just stays hidden.
    }
  }

  Future<void> _cancel() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: const Text('Your approver will no longer see it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    setState(() {
      _cancelling = true;
      _error = null;
    });
    try {
      await widget.repository.cancel(_request.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _cancelling = false;
          _error = staffErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final r = _request;
    final half = leaveHalfLabel(r.halfDay);
    final steps = [
      for (final s in r.trail)
        if (s.action.isNotEmpty) s,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: LeaveStatusPill(r.status),
          ),
          const SizedBox(height: 14),
          _Line('Dates', leaveRange(r.from, r.to)),
          _Line(
            'Length',
            half.isEmpty ? leaveDays(r.days) : '$half · ${leaveDays(r.days)}',
          ),
          if (r.appliedAt != null)
            _Line('Applied', DateFormat('d MMM yyyy').format(r.appliedAt!)),
          if (r.reason.isNotEmpty) _Line('Reason', r.reason),
          if (r.approverName.isNotEmpty) _Line('Approver', r.approverName),
          if (r.approverComment.isNotEmpty &&
              r.approverComment != r.approverName)
            _Line('Comment', r.approverComment),
          if (steps.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'HISTORY',
              style: sora(
                10.5,
                weight: FontWeight.w700,
                color: p.muted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            for (final s in steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  [
                    _title(s.action),
                    if (s.at != null) DateFormat('d MMM, h:mm a').format(s.at!),
                    if (s.by.isNotEmpty && int.tryParse(s.by) == null) s.by,
                  ].join(' · '),
                  style: sora(12.5, color: p.text),
                ),
              ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: sora(12.5, weight: FontWeight.w500, color: p.dangerText),
            ),
          ],
          if (r.canCancel) ...[
            const SizedBox(height: 18),
            AmberButton(
              label: 'Cancel request',
              soft: true,
              loading: _cancelling,
              onPressed: _cancelling ? null : _cancel,
            ),
          ],
        ],
      ),
    );
  }

  String _title(String action) {
    final text = action.trim();
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: sora(12, color: p.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: sora(13.5, weight: FontWeight.w600, color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}
