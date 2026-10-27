import 'dart:io';

import 'package:admin_app/core/utils/alert_helper.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/staff/tickets/tickets/models/form_config_model.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TicketCreatePage extends StatefulWidget {
  final VoidCallback? onTicketCreated;

  const TicketCreatePage({super.key, this.onTicketCreated});

  @override
  State<TicketCreatePage> createState() => _TicketCreatePageState();
}

class _TicketCreatePageState extends State<TicketCreatePage> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedTypeId;
  int? _selectedCategoryId;
  int? _selectedBlockId;
  int? _selectedLocationId;
  int? _selectedPriorityId;
  final _descriptionController = TextEditingController();
  File? _attachment;

  List<Category> _filteredCategories = [];
  List<Location> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    // Kick off fetching the form config
    context.read<TicketsCubit>().fetchFormConfig();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Scaffold(
      backgroundColor: p.background,
      body: Stack(
        children: [
          const Positioned.fill(child: StaffBackdrop()),
          SafeArea(
            child: Column(
              children: [
                const StaffPageHeader(
                  title: 'Raise a ticket',
                  subtitle: 'Tell us what needs attention',
                ),
                Expanded(child: _buildContent()),
                _buildSubmitBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final p = context.staff;
    return BlocConsumer<TicketsCubit, TicketsState>(
      listener: (context, state) {
        if (state is TicketAddSuccess) {
          showSuccessAlert(
            context,
            message: state.result.message,
            onPressed: () {
              context.read<TicketsCubit>().fetchTickets();

              context.pop();
            },
          );
        }
        if (state is TicketAddError) {
          showErrorAlert(context, message: state.message);
        }
      },
      builder: (context, state) {
        // 1) Config loading
        if (state is TicketsConfigFetchLoading) {
          return Center(child: CircularProgressIndicator(color: p.amberText));
        }
        // 2) Config error
        if (state is TicketsConfigFetchError) {
          return StaffStateMessage(
            glyph: StaffGlyphs.ticket,
            title: 'Could not load the form',
            message: state.message,
            actionLabel: 'Try again',
            onAction: () => context.read<TicketsCubit>().fetchFormConfig(),
            accent: StaffAccent.pink,
          );
        }
        // 3) Config success → show form
        if (state is TicketsConfigFetchSuccess) {
          final config = state.formConfigModel;
          return Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                const SectionLabel(
                  'WHAT IS THE ISSUE?',
                  padding: EdgeInsets.fromLTRB(6, 6, 6, 8),
                ),
                _FormCard(
                  children: [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Ticket type',
                      ),
                      items: config.types.map((t) {
                        return DropdownMenuItem(
                          value: int.parse(t.typeId),
                          child: Text(t.typeName),
                        );
                      }).toList(),
                      value: _selectedTypeId,
                      onChanged: (val) {
                        setState(() {
                          _selectedTypeId = val;
                          _filteredCategories = config.categories
                              .where((c) => int.parse(c.typeId) == val)
                              .toList();
                          _selectedCategoryId = null;
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Please select a type' : null,
                    ),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _filteredCategories.map((c) {
                        return DropdownMenuItem(
                          value: int.parse(c.categoryId),
                          child: Text(c.name),
                        );
                      }).toList(),
                      value: _selectedCategoryId,
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                      validator: (v) =>
                          v == null ? 'Please select a category' : null,
                    ),
                  ],
                ),
                const SectionLabel(
                  'WHERE?',
                  padding: EdgeInsets.fromLTRB(6, 18, 6, 8),
                ),
                _FormCard(
                  children: [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Block'),
                      items: config.blocks.map((b) {
                        return DropdownMenuItem(
                          value: int.parse(b.blockId),
                          child: Text(b.blockName),
                        );
                      }).toList(),
                      value: _selectedBlockId,
                      onChanged: (val) {
                        setState(() {
                          _selectedBlockId = val;
                          _filteredLocations = config.locations
                              .where((l) => int.parse(l.blockId) == val)
                              .toList();
                          _selectedLocationId = null;
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Please select a block' : null,
                    ),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Location'),
                      items: _filteredLocations.map((l) {
                        return DropdownMenuItem(
                          value: int.parse(l.locationId),
                          child: Text(l.locationName),
                        );
                      }).toList(),
                      value: _selectedLocationId,
                      onChanged: (val) =>
                          setState(() => _selectedLocationId = val),
                      validator: (v) =>
                          v == null ? 'Please select a location' : null,
                    ),
                  ],
                ),
                const SectionLabel(
                  'DETAILS',
                  padding: EdgeInsets.fromLTRB(6, 18, 6, 8),
                ),
                _FormCard(
                  children: [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: config.priorities.map((pr) {
                        return DropdownMenuItem(
                          value: int.parse(pr.priorityId),
                          child: Text(pr.priorityName),
                        );
                      }).toList(),
                      value: _selectedPriorityId,
                      onChanged: (val) =>
                          setState(() => _selectedPriorityId = val),
                      validator: (v) =>
                          v == null ? 'Please select a priority' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a description'
                          : null,
                    ),
                    _AttachmentTile(
                      file: _attachment,
                      onPick: _pickAttachment,
                      onClear: () => setState(() => _attachment = null),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // default / other states
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSubmitBar() {
    final p = context.staff;
    return BlocBuilder<TicketsCubit, TicketsState>(
      builder: (context, state) {
        final loading = state is TicketAddLoading;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: AmberButton(
            label: 'Submit ticket',
            glyph: StaffGlyphs.check,
            loading: loading,
            onPressed: _submitForm,
          ),
        );
      },
    );
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<TicketsCubit>().raiseTicket(
        ticketTypeId: _selectedTypeId!,
        categoryId: _selectedCategoryId!,
        locationId: _selectedLocationId!,
        priorityId: _selectedPriorityId!,
        description: _descriptionController.text.trim(),
        attachment: _attachment,
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

/// Card that spaces its form fields evenly.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.file,
    required this.onPick,
    required this.onClear,
  });

  final File? file;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final name = file?.path.split('/').last;
    return Material(
      color: p.surfaceRaised,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const GlassIconTile(
                glyph: StaffGlyphs.paperclip,
                accent: StaffAccent.blue,
                size: 36,
                radius: 12,
                iconSize: 17,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name ?? 'Add an attachment (optional)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sora(
                    13,
                    weight: name == null ? FontWeight.w500 : FontWeight.w600,
                    color: name == null ? p.muted : p.text,
                  ),
                ),
              ),
              if (name != null)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: StaffIcon(
                      StaffGlyphs.close,
                      size: 18,
                      color: p.muted,
                    ),
                  ),
                )
              else
                StaffIcon(
                  StaffGlyphs.plus,
                  size: 18,
                  color: p.muted,
                  strokeWidth: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
