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
        if (program.completionDate != null)
          'Completed: ${program.completionDate}',
        if (program.certificateNumber != null &&
            program.certificateNumber!.isNotEmpty)
          'Certificate: ${program.certificateNumber}',
        if (program.expiryDate != null && program.expiryDate!.isNotEmpty)
          'Expiry: ${program.expiryDate}',
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
  late final TextEditingController _completionDate;
  late final TextEditingController _certificateNumber;
  late final TextEditingController _expiryDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _programName = TextEditingController(text: e?.programName ?? '');
    _institution = TextEditingController(text: e?.institution ?? '');
    _completionDate = TextEditingController(text: e?.completionDate ?? '');
    _certificateNumber = TextEditingController(
      text: e?.certificateNumber ?? '',
    );
    _expiryDate = TextEditingController(text: e?.expiryDate ?? '');
  }

  @override
  void dispose() {
    _programName.dispose();
    _institution.dispose();
    _completionDate.dispose();
    _certificateNumber.dispose();
    _expiryDate.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      ProfessionalProgram(
        id: widget.existing?.id,
        programName: _programName.text.trim(),
        institution: _institution.text.trim(),
        completionDate: _completionDate.text.trim().isNotEmpty
            ? _completionDate.text.trim()
            : null,
        certificateNumber: _certificateNumber.text.trim().isNotEmpty
            ? _certificateNumber.text.trim()
            : null,
        expiryDate: _expiryDate.text.trim().isNotEmpty
            ? _expiryDate.text.trim()
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
          label: 'Program Name',
          controller: _programName,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Institution',
          controller: _institution,
          isRequired: true,
        ),
        ProfileDateField(
          label: 'Completion Date',
          controller: _completionDate,
          lastDate: DateTime.now(),
        ),
        ProfileTextField(
          label: 'Certificate Number',
          controller: _certificateNumber,
        ),
        ProfileDateField(label: 'Expiry Date', controller: _expiryDate),
      ],
    );
  }
}
