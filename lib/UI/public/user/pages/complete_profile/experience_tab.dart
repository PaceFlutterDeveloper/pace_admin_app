import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_section_tab.dart';
import 'package:flutter/material.dart';

class ExperienceTab extends StatelessWidget {
  const ExperienceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionTab<ExperienceRecord>(
      section: ProfileSection.experience,
      addLabel: 'Add Experience',
      emptyTitle: 'No experience records yet',
      emptySubtitle: 'Add your work history to strengthen your profile.',
      recordsOf: (state) => state is ExperienceLoaded ? state.records : null,
      titleOf: (record) => record.position ?? 'Position',
      detailsOf: (record) => [
        if (record.companyName != null) 'Organization: ${record.companyName}',
        if (record.location != null && record.location!.isNotEmpty)
          'Location: ${record.location}',
        if (record.startDate != null) 'From: ${record.startDate}',
        if (record.endDate != null && record.isCurrent != true)
          'To: ${record.endDate}',
        if (record.isCurrent == true) 'Current role',
        if (record.jobDescription != null && record.jobDescription!.isNotEmpty)
          'Description: ${record.jobDescription}',
      ],
      editor: (context, existing) => showDialog<ExperienceRecord>(
        context: context,
        builder: (_) => _ExperienceEditorDialog(existing: existing),
      ),
      saveEventBuilder: (records) => SaveExperienceEvent(records: records),
    );
  }
}

class _ExperienceEditorDialog extends StatefulWidget {
  final ExperienceRecord? existing;

  const _ExperienceEditorDialog({this.existing});

  @override
  State<_ExperienceEditorDialog> createState() =>
      _ExperienceEditorDialogState();
}

class _ExperienceEditorDialogState extends State<_ExperienceEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _company;
  late final TextEditingController _position;
  late final TextEditingController _location;
  late final TextEditingController _startDate;
  late final TextEditingController _endDate;
  late final TextEditingController _description;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _company = TextEditingController(text: e?.companyName ?? '');
    _position = TextEditingController(text: e?.position ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _startDate = TextEditingController(text: e?.startDate ?? '');
    _endDate = TextEditingController(text: e?.endDate ?? '');
    _description = TextEditingController(text: e?.jobDescription ?? '');
    _isCurrent = e?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _company.dispose();
    _position.dispose();
    _location.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      ExperienceRecord(
        id: widget.existing?.id,
        companyName: _company.text.trim(),
        position: _position.text.trim(),
        location: _location.text.trim().isNotEmpty
            ? _location.text.trim()
            : null,
        startDate: _startDate.text.trim(),
        endDate: _isCurrent ? null : _endDate.text.trim(),
        isCurrent: _isCurrent,
        jobDescription: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecordEditorDialog(
      title: widget.existing != null ? 'Edit Experience' : 'Add Experience',
      formKey: _formKey,
      onSave: _save,
      fields: [
        ProfileTextField(
          label: 'Organization',
          controller: _company,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Designation',
          controller: _position,
          isRequired: true,
        ),
        ProfileTextField(label: 'Location', controller: _location),
        ProfileDateField(
          label: 'Start Date',
          controller: _startDate,
          isRequired: true,
          lastDate: DateTime.now(),
        ),
        ProfileSwitchField(
          label: 'Current role',
          value: _isCurrent,
          onChanged: (value) => setState(() => _isCurrent = value),
        ),
        if (!_isCurrent)
          ProfileDateField(
            label: 'End Date',
            controller: _endDate,
            lastDate: DateTime.now(),
          ),
        ProfileTextField(
          label: 'Job Description',
          controller: _description,
          maxLines: 3,
        ),
      ],
    );
  }
}
