import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_section_tab.dart';
import 'package:flutter/material.dart';

class EducationTab extends StatelessWidget {
  const EducationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionTab<EducationRecord>(
      section: ProfileSection.education,
      addLabel: 'Add Education',
      emptyTitle: 'No education records yet',
      emptySubtitle: 'Add your qualifications to strengthen your profile.',
      recordsOf: (state) => state is EducationLoaded ? state.records : null,
      titleOf: (record) => record.qualification ?? 'Qualification',
      detailsOf: (record) => [
        if (record.institution != null)
          'Board / University: ${record.institution}',
        if (record.fieldOfStudy != null)
          'Main Subject: ${record.fieldOfStudy}',
        if (record.graduationYear != null)
          'Year of Passing: ${record.graduationYear}',
        if (record.percentage != null && record.percentage!.isNotEmpty)
          'Percentage: ${record.percentage}',
      ],
      editor: (context, existing) => showDialog<EducationRecord>(
        context: context,
        builder: (_) => _EducationEditorDialog(existing: existing),
      ),
      saveEventBuilder: (records) => SaveEducationEvent(records: records),
    );
  }
}

class _EducationEditorDialog extends StatefulWidget {
  final EducationRecord? existing;

  const _EducationEditorDialog({this.existing});

  @override
  State<_EducationEditorDialog> createState() => _EducationEditorDialogState();
}

class _EducationEditorDialogState extends State<_EducationEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qualification;
  late final TextEditingController _institution;
  late final TextEditingController _fieldOfStudy;
  late final TextEditingController _graduationYear;
  late final TextEditingController _percentage;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _qualification = TextEditingController(text: e?.qualification ?? '');
    _institution = TextEditingController(text: e?.institution ?? '');
    _fieldOfStudy = TextEditingController(text: e?.fieldOfStudy ?? '');
    _graduationYear = TextEditingController(text: e?.graduationYear ?? '');
    _percentage = TextEditingController(text: e?.percentage ?? '');
  }

  @override
  void dispose() {
    _qualification.dispose();
    _institution.dispose();
    _fieldOfStudy.dispose();
    _graduationYear.dispose();
    _percentage.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      EducationRecord(
        id: widget.existing?.id,
        qualification: _qualification.text.trim(),
        institution: _institution.text.trim(),
        fieldOfStudy: _fieldOfStudy.text.trim().isNotEmpty
            ? _fieldOfStudy.text.trim()
            : null,
        graduationYear: _graduationYear.text.trim().isNotEmpty
            ? _graduationYear.text.trim()
            : null,
        percentage: _percentage.text.trim().isNotEmpty
            ? _percentage.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecordEditorDialog(
      title: widget.existing != null ? 'Edit Education' : 'Add Education',
      formKey: _formKey,
      onSave: _save,
      fields: [
        ProfileTextField(
          label: 'Course / Qualification',
          controller: _qualification,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Board / University',
          controller: _institution,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Main Subject',
          controller: _fieldOfStudy,
        ),
        ProfileTextField(
          label: 'Year of Passing',
          controller: _graduationYear,
          keyboardType: TextInputType.number,
          maxLength: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final year = int.tryParse(value);
            final currentYear = DateTime.now().year;
            if (value.length != 4 ||
                year == null ||
                year < 1900 ||
                year > currentYear + 1) {
              return 'Please enter a valid year (1900-${currentYear + 1})';
            }
            return null;
          },
        ),
        ProfileTextField(
          label: 'Percentage',
          controller: _percentage,
          helperText: 'e.g. 85%',
        ),
      ],
    );
  }
}
