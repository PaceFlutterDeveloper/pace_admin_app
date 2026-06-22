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
        if (reference.address != null && reference.address!.isNotEmpty)
          'Address: ${reference.address}',
        if (reference.phone != null && reference.phone!.isNotEmpty)
          'Contact: ${reference.phone}',
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
  late final TextEditingController _address;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _position = TextEditingController(text: e?.position ?? '');
    _address = TextEditingController(text: e?.address ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _position.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      Reference(
        id: widget.existing?.id,
        name: _name.text.trim(),
        position: _position.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim().isNotEmpty ? _phone.text.trim() : null,
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
          label: 'Address',
          controller: _address,
          isRequired: true,
          maxLines: 2,
        ),
        ProfileTextField(
          label: 'Contact Number',
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
