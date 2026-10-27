import 'package:admin_app/staff/leave/domain/leave_models.dart';
import 'package:admin_app/staff/leave/domain/leave_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Returns true when the request was sent.
Future<bool?> showLeaveApplySheet(
  BuildContext context,
  LeaveRepository repository,
) {
  return showStaffSheet<bool>(
    context,
    title: 'Apply for leave',
    builder: (_) => _ApplyForm(repository: repository),
  );
}

class _ApplyForm extends StatefulWidget {
  const _ApplyForm({required this.repository});

  final LeaveRepository repository;

  @override
  State<_ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends State<_ApplyForm> {
  final _reason = TextEditingController();
  final _typeText = TextEditingController();
  final _fromText = TextEditingController();
  final _toText = TextEditingController();
  List<LeaveType>? _types;
  String? _typesError;
  LeaveType? _type;
  DateTime? _from;
  DateTime? _to;
  String? _half;
  PlatformFile? _file;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _reason.dispose();
    _typeText.dispose();
    _fromText.dispose();
    _toText.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    setState(() => _typesError = null);
    try {
      final types = await widget.repository.types();
      if (mounted) setState(() => _types = types);
    } catch (e) {
      if (mounted) setState(() => _typesError = staffErrorMessage(e));
    }
  }

  bool get _sameDay =>
      _from != null && _to != null && _from!.isAtSameMomentAs(_to!);

  Future<void> _pickType() async {
    final types = _types;
    if (types == null) return;
    final picked = await showStaffSheet<LeaveType>(
      context,
      title: 'Leave type',
      builder: (context) {
        final p = context.staff;
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          children: [
            for (final t in types)
              ListTile(
                title: Text(
                  t.name,
                  style: sora(14, weight: FontWeight.w600, color: p.text),
                ),
                subtitle: t.requiresDocument
                    ? Text(
                        'Needs a document',
                        style: sora(11.5, color: p.muted),
                      )
                    : null,
                trailing: _type?.id == t.id
                    ? StaffIcon(StaffGlyphs.check, color: p.amberText, size: 20)
                    : null,
                onTap: () => Navigator.pop(context, t),
              ),
          ],
        );
      },
    );
    if (picked != null) {
      setState(() {
        _type = picked;
        if (!picked.halfDayAllowed) _half = null;
      });
    }
  }

  Future<void> _pickDate({required bool start}) async {
    final today = DateTime.now();
    final first = DateTime(today.year - 1, today.month, today.day);
    final initial = (start ? _from : _to) ?? _from ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: start ? first : (_from ?? first),
      lastDate: DateTime(today.year + 2, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _from = picked;
        if (_to == null || _to!.isBefore(picked)) _to = picked;
      } else {
        _to = picked;
      }
      if (!_sameDay) _half = null;
    });
  }

  Future<void> _attach() async {
    final result = await FilePicker.pickFiles();
    final file = result?.files.firstOrNull;
    if (file != null && file.path != null) setState(() => _file = file);
  }

  String? _validate() {
    if (_type == null) return 'Choose a leave type.';
    if (_from == null || _to == null) return 'Choose the dates.';
    if (_reason.text.trim().isEmpty) return 'Write a reason.';
    if (_type!.requiresDocument && _file == null) {
      return 'This leave type needs a supporting document.';
    }
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.repository.apply(
        typeId: _type!.id,
        from: _from!,
        to: _to!,
        reason: _reason.text.trim(),
        halfDay: _half,
        attachmentPath: _file?.path,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = staffErrorMessage(e);
        });
      }
    }
  }

  String _date(DateTime? d) =>
      d == null ? '' : DateFormat('EEE, d MMM yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    if (_typesError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_typesError!, style: sora(13, color: p.muted)),
            const SizedBox(height: 14),
            AmberButton(label: 'Try again', soft: true, onPressed: _loadTypes),
          ],
        ),
      );
    }
    if (_types == null) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 48, top: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffField(
            label: 'Leave type',
            hint: 'Choose',
            readOnly: true,
            controller: _typeText..text = _type?.name ?? '',
            onTap: _pickType,
            suffixGlyph: StaffGlyphs.chevronRight,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StaffField(
                  label: 'From',
                  hint: 'Date',
                  readOnly: true,
                  controller: _fromText..text = _date(_from),
                  onTap: () => _pickDate(start: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StaffField(
                  label: 'To',
                  hint: 'Date',
                  readOnly: true,
                  controller: _toText..text = _date(_to),
                  onTap: () => _pickDate(start: false),
                ),
              ),
            ],
          ),
          if (_type?.halfDayAllowed == true && _sameDay) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                StaffFilterChip(
                  label: 'Full day',
                  selected: _half == null,
                  onTap: () => setState(() => _half = null),
                ),
                StaffFilterChip(
                  label: 'Morning',
                  selected: _half == 'am',
                  onTap: () => setState(() => _half = 'am'),
                ),
                StaffFilterChip(
                  label: 'Afternoon',
                  selected: _half == 'pm',
                  onTap: () => setState(() => _half = 'pm'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          StaffField(
            label: 'Reason',
            hint: 'Tell your approver why',
            controller: _reason,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 14),
          _AttachRow(
            file: _file,
            required: _type?.requiresDocument == true,
            onPick: _attach,
            onClear: () => setState(() => _file = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              style: sora(12.5, weight: FontWeight.w500, color: p.dangerText),
            ),
          ],
          const SizedBox(height: 18),
          AmberButton(
            label: 'Send request',
            loading: _sending,
            onPressed: _sending ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _AttachRow extends StatelessWidget {
  const _AttachRow({
    required this.file,
    required this.required,
    required this.onPick,
    required this.onClear,
  });

  final PlatformFile? file;
  final bool required;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      radius: 14,
      color: p.surfaceRaised,
      onTap: file == null ? onPick : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          StaffIcon(StaffGlyphs.paperclip, size: 18, color: p.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file?.name ??
                  (required
                      ? 'Attach a document (needed)'
                      : 'Attach a document (optional)'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(
                13,
                weight: FontWeight.w500,
                color: file == null ? p.muted : p.text,
              ),
            ),
          ),
          if (file != null)
            IconButton(
              tooltip: 'Remove',
              visualDensity: VisualDensity.compact,
              onPressed: onClear,
              icon: Icon(Icons.close, size: 18, color: p.muted),
            ),
        ],
      ),
    );
  }
}
