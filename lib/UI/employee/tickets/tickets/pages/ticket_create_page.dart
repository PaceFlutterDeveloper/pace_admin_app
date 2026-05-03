// lib/UI/employee/tickets/pages/ticket_create_page.dart

import 'dart:io';

import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/form_config_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/core/utils/alert_helper.dart';
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(title: const Text('Raise Ticket')),
      body: BlocConsumer<TicketsCubit, TicketsState>(
        listener: (context, state) {
          // if (state is TicketAddSuccess) {
          //   DebugLogger.log('Ticket created successfully, returning to list');
          //   context.read<TicketsCubit>().fetchTickets();
          //   Navigator.of(context).pop(true); // Pass true to indicate success
          // }
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
            return const Center(child: CircularProgressIndicator());
          }
          // 2) Config error
          if (state is TicketsConfigFetchError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          }
          // 3) Config success → show form
          if (state is TicketsConfigFetchSuccess) {
            final config = state.formConfigModel;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // ── Ticket Type ───────────────────────────────
                    DropdownButtonFormField<int>(
                      decoration:
                          const InputDecoration(labelText: 'Ticket Type'),
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

                    const SizedBox(height: 12),

                    // ── Category ─────────────────────────────────
                    DropdownButtonFormField<int>(
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

                    const SizedBox(height: 12),

                    // ── Block ────────────────────────────────────
                    DropdownButtonFormField<int>(
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

                    const SizedBox(height: 12),

                    // ── Location ─────────────────────────────────
                    DropdownButtonFormField<int>(
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

                    const SizedBox(height: 12),

                    // ── Priority ─────────────────────────────────
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: config.priorities.map((p) {
                        return DropdownMenuItem(
                          value: int.parse(p.priorityId),
                          child: Text(p.priorityName),
                        );
                      }).toList(),
                      value: _selectedPriorityId,
                      onChanged: (val) =>
                          setState(() => _selectedPriorityId = val),
                      validator: (v) =>
                          v == null ? 'Please select a priority' : null,
                    ),

                    const SizedBox(height: 12),

                    // ── Description ───────────────────────────────
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter a description'
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // ── Attachment picker ─────────────────────────
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickAttachment,
                          icon: const Icon(Icons.attach_file),
                          label: Text(_attachment == null
                              ? 'Add Attachment'
                              : 'Change Attachment'),
                        ),
                        if (_attachment != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(_attachment!.path.split('/').last)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          // default / other states
          return const SizedBox.shrink();
        },
      ),

      // ── Submit button / loading ──────────────────────────
      bottomNavigationBar: BlocBuilder<TicketsCubit, TicketsState>(
        builder: (context, state) {
          if (state is TicketAddLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit Ticket'),
            ),
          );
        },
      ),
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
