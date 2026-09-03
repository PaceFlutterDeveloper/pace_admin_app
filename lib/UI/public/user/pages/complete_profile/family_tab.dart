import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_section_tab.dart';
import 'package:flutter/material.dart';

class FamilyTab extends StatelessWidget {
  const FamilyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionTab<FamilyMember>(
      section: ProfileSection.family,
      addLabel: 'Add Family Member',
      emptyTitle: 'No family members yet',
      emptySubtitle: 'Add your family details to complete your profile.',
      recordsOf: (state) => state is FamilyLoaded ? state.members : null,
      titleOf: (member) => member.name ?? 'Name',
      detailsOf: (member) => [
        if (member.relationship != null) 'Relation: ${member.relationship}',
        if (member.occupation != null) 'Profession: ${member.occupation}',
        if (member.age != null) 'Age: ${member.age}',
        if (member.dependentYn == true) 'Dependent',
      ],
      editor: (context, existing) => showDialog<FamilyMember>(
        context: context,
        builder: (_) => _FamilyEditorDialog(existing: existing),
      ),
      saveEventBuilder: (members) => SaveFamilyEvent(members: members),
    );
  }
}

class _FamilyEditorDialog extends StatefulWidget {
  final FamilyMember? existing;

  const _FamilyEditorDialog({this.existing});

  @override
  State<_FamilyEditorDialog> createState() => _FamilyEditorDialogState();
}

class _FamilyEditorDialogState extends State<_FamilyEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _relationship;
  late final TextEditingController _occupation;
  late final TextEditingController _age;
  bool _dependentYn = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _relationship = TextEditingController(text: e?.relationship ?? '');
    _occupation = TextEditingController(text: e?.occupation ?? '');
    _age = TextEditingController(text: e?.age?.toString() ?? '');
    _dependentYn = e?.dependentYn ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    _occupation.dispose();
    _age.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      FamilyMember(
        id: widget.existing?.id,
        name: _name.text.trim(),
        relationship: _relationship.text.trim(),
        occupation: _occupation.text.trim().isNotEmpty
            ? _occupation.text.trim()
            : null,
        age: int.tryParse(_age.text.trim()),
        dependentYn: _dependentYn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecordEditorDialog(
      title: widget.existing != null
          ? 'Edit Family Member'
          : 'Add Family Member',
      formKey: _formKey,
      onSave: _save,
      fields: [
        ProfileTextField(label: 'Name', controller: _name, isRequired: true),
        ProfileTextField(
          label: 'Relation',
          controller: _relationship,
          isRequired: true,
        ),
        ProfileTextField(label: 'Profession', controller: _occupation),
        ProfileTextField(
          label: 'Age',
          controller: _age,
          keyboardType: TextInputType.number,
        ),
        ProfileSwitchField(
          label: 'Dependent',
          value: _dependentYn,
          onChanged: (value) => setState(() => _dependentYn = value),
        ),
      ],
    );
  }
}
