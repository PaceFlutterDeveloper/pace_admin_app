import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_section_tab.dart';
import 'package:flutter/material.dart';

/// Certificates / professional programs tab.
class ProgramsTab extends StatelessWidget {
  const ProgramsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionTab<ProfessionalProgram>(
      section: ProfileSection.programs,
      addLabel: 'Add Certificate',
      emptyTitle: 'No certificates yet',
      emptySubtitle:
          'Add professional programs and certificates to your profile.',
      recordsOf: (state) =>
          state is ProfessionalProgramsLoaded ? state.programs : null,
      titleOf: (program) => program.programName ?? 'Program',
      detailsOf: (program) => [
        if (program.institution != null) 'Institute: ${program.institution}',
        if (program.durationText != null && program.durationText!.isNotEmpty)
          'Duration: ${program.durationText}',
        if (program.place != null && program.place!.isNotEmpty)
          'Place: ${program.place}',
        if (program.yearPassing != null && program.yearPassing!.isNotEmpty)
          'Year: ${program.yearPassing}',
      ],
      editor: (context, existing) => showDialog<ProfessionalProgram>(
        context: context,
        builder: (_) => _ProgramEditorDialog(existing: existing),
      ),
      saveEventBuilder: (programs) =>
          SaveProfessionalProgramsEvent(programs: programs),
    );
  }
}

class _ProgramEditorDialog extends StatefulWidget {
  final ProfessionalProgram? existing;

  const _ProgramEditorDialog({this.existing});

  @override
  State<_ProgramEditorDialog> createState() => _ProgramEditorDialogState();
}

class _ProgramEditorDialogState extends State<_ProgramEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _programName;
  late final TextEditingController _institution;
  late final TextEditingController _durationText;
  late final TextEditingController _place;
  late final TextEditingController _yearPassing;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _programName = TextEditingController(text: e?.programName ?? '');
    _institution = TextEditingController(text: e?.institution ?? '');
    _durationText = TextEditingController(text: e?.durationText ?? '');
    _place = TextEditingController(text: e?.place ?? '');
    _yearPassing = TextEditingController(text: e?.yearPassing ?? '');
  }

  @override
  void dispose() {
    _programName.dispose();
    _institution.dispose();
    _durationText.dispose();
    _place.dispose();
    _yearPassing.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      ProfessionalProgram(
        id: widget.existing?.id,
        programName: _programName.text.trim(),
        institution: _institution.text.trim(),
        durationText: _durationText.text.trim().isNotEmpty
            ? _durationText.text.trim()
            : null,
        place: _place.text.trim().isNotEmpty ? _place.text.trim() : null,
        yearPassing: _yearPassing.text.trim().isNotEmpty
            ? _yearPassing.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecordEditorDialog(
      title: widget.existing != null ? 'Edit Certificate' : 'Add Certificate',
      formKey: _formKey,
      onSave: _save,
      fields: [
        ProfileTextField(
          label: 'Course Name',
          controller: _programName,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Institute',
          controller: _institution,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Duration',
          controller: _durationText,
          helperText: 'e.g. 6 months',
        ),
        ProfileTextField(label: 'Place', controller: _place),
        ProfileTextField(
          label: 'Year of Passing',
          controller: _yearPassing,
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
      ],
    );
  }
}
