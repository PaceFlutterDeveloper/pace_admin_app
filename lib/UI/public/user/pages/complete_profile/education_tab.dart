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
        if (record.institution != null) 'Institution: ${record.institution}',
        if (record.fieldOfStudy != null) 'Field: ${record.fieldOfStudy}',
        if (record.graduationYear != null) 'Year: ${record.graduationYear}',
        if (record.gpa != null) 'GPA: ${record.gpa}',
        if (record.grade != null) 'Grade: ${record.grade}',
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
  late final TextEditingController _gpa;
  late final TextEditingController _grade;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _qualification = TextEditingController(text: e?.qualification ?? '');
    _institution = TextEditingController(text: e?.institution ?? '');
    _fieldOfStudy = TextEditingController(text: e?.fieldOfStudy ?? '');
    _graduationYear = TextEditingController(text: e?.graduationYear ?? '');
    _gpa = TextEditingController(text: e?.gpa?.toString() ?? '');
    _grade = TextEditingController(text: e?.grade ?? '');
  }

  @override
  void dispose() {
    _qualification.dispose();
    _institution.dispose();
    _fieldOfStudy.dispose();
    _graduationYear.dispose();
    _gpa.dispose();
    _grade.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      EducationRecord(
        id: widget.existing?.id,
        qualification: _qualification.text.trim(),
        institution: _institution.text.trim(),
        fieldOfStudy: _fieldOfStudy.text.trim(),
        graduationYear: _graduationYear.text.trim(),
        gpa: _gpa.text.isNotEmpty ? double.tryParse(_gpa.text) : null,
        grade: _grade.text.trim().isNotEmpty ? _grade.text.trim() : null,
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
          label: 'Qualification',
          controller: _qualification,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Institution',
          controller: _institution,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Field of Study',
          controller: _fieldOfStudy,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Graduation Year',
          controller: _graduationYear,
          isRequired: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter Graduation Year';
            }
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
        ProfileNumericField(label: 'GPA', controller: _gpa, maxValue: 4.0),
        ProfileTextField(label: 'Grade', controller: _grade),
      ],
    );
  }
}
