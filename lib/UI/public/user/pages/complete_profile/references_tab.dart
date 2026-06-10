import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_section_tab.dart';
import 'package:flutter/material.dart';

class ReferencesTab extends StatelessWidget {
  const ReferencesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionTab<Reference>(
      section: ProfileSection.references,
      addLabel: 'Add Reference',
      emptyTitle: 'No references yet',
      emptySubtitle: 'Add professional references to complete your profile.',
      recordsOf: (state) => state is ReferencesLoaded ? state.references : null,
      titleOf: (reference) => reference.name ?? 'Name',
      detailsOf: (reference) => [
        if (reference.position != null) 'Designation: ${reference.position}',
        if (reference.organization != null)
          'Organization: ${reference.organization}',
        if (reference.relationship != null &&
            reference.relationship!.isNotEmpty)
          'Relationship: ${reference.relationship}',
        if (reference.phone != null && reference.phone!.isNotEmpty)
          'Contact: ${reference.phone}',
        if (reference.email != null && reference.email!.isNotEmpty)
          'Email: ${reference.email}',
      ],
      editor: (context, existing) => showDialog<Reference>(
        context: context,
        builder: (_) => _ReferenceEditorDialog(existing: existing),
      ),
      saveEventBuilder: (references) =>
          SaveReferencesEvent(references: references),
    );
  }
}

class _ReferenceEditorDialog extends StatefulWidget {
  final Reference? existing;

  const _ReferenceEditorDialog({this.existing});

  @override
  State<_ReferenceEditorDialog> createState() => _ReferenceEditorDialogState();
}

class _ReferenceEditorDialogState extends State<_ReferenceEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _position;
  late final TextEditingController _organization;
  late final TextEditingController _relationship;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _position = TextEditingController(text: e?.position ?? '');
    _organization = TextEditingController(text: e?.organization ?? '');
    _relationship = TextEditingController(text: e?.relationship ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _email = TextEditingController(text: e?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _position.dispose();
    _organization.dispose();
    _relationship.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      Reference(
        id: widget.existing?.id,
        name: _name.text.trim(),
        position: _position.text.trim(),
        organization: _organization.text.trim(),
        relationship: _relationship.text.trim().isNotEmpty
            ? _relationship.text.trim()
            : null,
        phone: _phone.text.trim().isNotEmpty ? _phone.text.trim() : null,
        email: _email.text.trim().isNotEmpty ? _email.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecordEditorDialog(
      title: widget.existing != null ? 'Edit Reference' : 'Add Reference',
      formKey: _formKey,
      onSave: _save,
      fields: [
        ProfileTextField(label: 'Name', controller: _name, isRequired: true),
        ProfileTextField(
          label: 'Designation',
          controller: _position,
          isRequired: true,
        ),
        ProfileTextField(
          label: 'Organization',
          controller: _organization,
          isRequired: true,
        ),
        ProfileTextField(label: 'Relationship', controller: _relationship),
        ProfileTextField(
          label: 'Contact Number',
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
        ProfileTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null &&
                value.trim().isNotEmpty &&
                !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }
}
