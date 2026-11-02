import 'dart:io';

import 'package:admin_app/core/utils/alert_helper.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/staff/tickets/tickets/models/form_config_model.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
      // Shell already keeps the dock fixed; this page lifts only its own
      // content so the submit bar sits flush on the keyboard.
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: StaffBackdrop()),
          SafeArea(
            bottom: false,
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
                    StaffSearchableDropdownFormField<Category>(
                      key: ValueKey('category-$_selectedTypeId'),
                      label: 'Category',
                      searchHint: 'Search categories',
                      items: _filteredCategories,
                      labelOf: (c) => c.name,
                      value: _selectedCategoryId == null
                          ? null
                          : _filteredCategories
                              .where(
                                (c) =>
                                    int.parse(c.categoryId) ==
                                    _selectedCategoryId,
                              )
                              .firstOrNull,
                      onChanged: (val) => setState(
                        () => _selectedCategoryId = val == null
                            ? null
                            : int.parse(val.categoryId),
                      ),
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
                    StaffSearchableDropdownFormField<Location>(
                      key: ValueKey('location-$_selectedBlockId'),
                      label: 'Location',
                      searchHint: 'Search locations',
                      items: _filteredLocations,
                      labelOf: (l) => l.locationName,
                      value: _selectedLocationId == null
                          ? null
                          : _filteredLocations
                              .where(
                                (l) =>
                                    int.parse(l.locationId) ==
                                    _selectedLocationId,
                              )
                              .firstOrNull,
                      onChanged: (val) => setState(
                        () => _selectedLocationId = val == null
                            ? null
                            : int.parse(val.locationId),
                      ),
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
    final source = await showStaffSheet<_AttachmentSource>(
      context,
      title: 'Add attachment',
      builder: (context) {
        final p = context.staff;
        Widget option({
          required IconData icon,
          required String title,
          required String subtitle,
          required _AttachmentSource value,
        }) {
          return ListTile(
            leading: Icon(icon, color: p.amberText),
            title: Text(
              title,
              style: sora(14, weight: FontWeight.w600, color: p.text),
            ),
            subtitle: Text(
              subtitle,
              style: sora(11.5, weight: FontWeight.w400, color: p.muted),
            ),
            onTap: () => Navigator.pop(context, value),
          );
        }

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          children: [
            option(
              icon: Icons.photo_camera_outlined,
              title: 'Camera',
              subtitle: 'Take a new photo',
              value: _AttachmentSource.camera,
            ),
            option(
              icon: Icons.photo_library_outlined,
              title: 'Photos',
              subtitle: 'Choose from your library',
              value: _AttachmentSource.photos,
            ),
            option(
              icon: Icons.folder_outlined,
              title: 'Files',
              subtitle: 'Pick a document or image',
              value: _AttachmentSource.files,
            ),
          ],
        );
      },
    );
    if (source == null || !mounted) return;

    final file = switch (source) {
      _AttachmentSource.camera => await _pickImage(ImageSource.camera),
      _AttachmentSource.photos => await _pickImage(ImageSource.gallery),
      _AttachmentSource.files => await _pickFile(),
    };
    if (file == null || !mounted) return;
    setState(() => _attachment = file);
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) return null;
      return _stableAttachmentCopy(File(image.path), preferredName: image.name);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _pickFile() async {
    final result = await FilePicker.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return null;
    return File(path);
  }

  /// Keeps camera/gallery temp files alive after the picker dismisses on iOS.
  Future<File?> _stableAttachmentCopy(
    File source, {
    String? preferredName,
  }) async {
    try {
      if (!await source.exists()) return null;
      final dir = await getTemporaryDirectory();
      final rawName = (preferredName == null || preferredName.trim().isEmpty)
          ? source.uri.pathSegments.last
          : preferredName.trim();
      final safeName = rawName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
      final dest = File(
        '${dir.path}/ticket_att_${DateTime.now().millisecondsSinceEpoch}_$safeName',
      );
      return await source.copy(dest.path);
    } catch (_) {
      return source;
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

enum _AttachmentSource { camera, photos, files }

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
