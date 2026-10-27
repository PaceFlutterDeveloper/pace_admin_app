import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/utils/alert_helper.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/detail/manage_ticket_detail_bloc.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/detail/manage_ticket_detail_event.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/detail/manage_ticket_detail_state.dart';
import 'package:admin_app/staff/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:admin_app/staff/tickets/manage_tickets/models/status_option.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ManageTicketDetailPage extends StatefulWidget {
  final int ticketId;
  final bool isPushNotification;
  const ManageTicketDetailPage({
    Key? key,
    required this.ticketId,
    this.isPushNotification = false,
  }) : super(key: key);

  @override
  State<ManageTicketDetailPage> createState() => _ManageTicketDetailPageState();
}

class _ManageTicketDetailPageState extends State<ManageTicketDetailPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<ManageTicketDetailBloc>().add(
      FetchTicketDetailEvent(id: widget.ticketId),
    );
  }

  void _back() {
    if (widget.isPushNotification || !context.canPop()) {
      context.go(Routes.home.path);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageTicketDetailBloc, ManageTicketDetailState>(
      listener: (context, state) async {
        if (state is ManageTicketDetailUpdated) {
          if (state.status) {
            _load();
            await showSuccessAlert(
              context,
              message: state.message,
              buttonText: 'Got it',
              onPressed: () => context.pop(true),
            );
          } else {
            await showErrorAlert(
              context,
              message: state.message,
              buttonText: 'Close',
              onPressed: () => context.pop(),
            );
          }
        }
      },
      builder: (context, state) {
        final loaded = state is ManageTicketDetailLoaded
            ? state.ticketResponseModel.ticket
            : null;
        return StaffPage(
          child: Column(
            children: [
              StaffPageHeader(
                title: loaded == null ? 'Ticket' : 'Ticket #${loaded.id}',
                subtitle: loaded?.category,
                onBack: _back,
              ),
              Expanded(child: _buildBody(state)),
              _buildBottomBar(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ManageTicketDetailState state) {
    final p = context.staff;
    if (state is ManageTicketDetailLoading ||
        state is ManageTicketDetailUpdating) {
      return Center(child: CircularProgressIndicator(color: p.amberText));
    }

    if (state is ManageTicketDetailError) {
      return StaffStateMessage(
        glyph: StaffGlyphs.ticket,
        title: 'Could not load ticket',
        message: state.message,
        actionLabel: 'Try again',
        onAction: _load,
        accent: StaffAccent.pink,
      );
    }

    if (state is ManageTicketDetailLoaded) {
      final ticket = state.ticketResponseModel.ticket;
      return _TicketBody(ticket: ticket);
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomBar(ManageTicketDetailState state) {
    if (state is! ManageTicketDetailLoaded) return const SizedBox.shrink();
    final ticket = state.ticketResponseModel.ticket;

    if (ticket.assignedTo == null) {
      return _ActionBar(
        label: 'Accept ticket',
        glyph: StaffGlyphs.check,
        onTap: () {
          context.read<ManageTicketDetailBloc>().add(
            UpdateTicketStatusEvent(
              id: widget.ticketId,
              action: 'accept_ticket',
            ),
          );
        },
      );
    }
    if (ticket.endStat == 0 && (ticket.statusOptions?.isNotEmpty ?? false)) {
      return _ActionBar(
        label: 'Update status',
        glyph: StaffGlyphs.sliders,
        onTap: () => _showStatusDialog(context, ticket.statusOptions!),
      );
    }
    return const SizedBox.shrink();
  }

  void _showStatusDialog(BuildContext context, List<StatusOption> options) {
    final commentController = TextEditingController();
    StatusOption? selected;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final p = dialogCtx.staff;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const GlassIconTile(
                          glyph: StaffGlyphs.sliders,
                          accent: StaffAccent.violet,
                          size: 40,
                          radius: 14,
                          iconSize: 19,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Update status',
                          style: sora(
                            17,
                            weight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<StatusOption>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'New status',
                      ),
                      items: options
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.statusName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => selected = value),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Comment (optional)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: p.muted,
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Opacity(
                            opacity: selected == null ? 0.45 : 1,
                            child: AmberButton(
                              label: 'Submit',
                              height: 46,
                              onPressed: selected == null
                                  ? null
                                  : () {
                                      context
                                          .read<ManageTicketDetailBloc>()
                                          .add(
                                            UpdateTicketStatusEvent(
                                              id: widget.ticketId,
                                              action: 'update_status',
                                              statusId: selected!.statusId,
                                              comment: commentController.text
                                                  .trim(),
                                            ),
                                          );
                                      Navigator.of(dialogCtx).pop();
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(commentController.dispose);
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({required this.ticket});

  final ManageTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final accent = ticketPriorityAccent(ticketPriorityOf(ticket.priorityName));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        StaffCard(
          radius: 24,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlassIconTile(
                    glyph: StaffGlyphs.ticket,
                    accent: accent,
                    size: 48,
                    radius: 16,
                    iconSize: 23,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.category.isEmpty ? 'Ticket' : ticket.category,
                          style: sora(
                            17,
                            weight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatTicketDate(ticket.createdAt),
                          style: sora(
                            12,
                            weight: FontWeight.w400,
                            color: p.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PriorityBadge(ticket.priorityName),
                  StatusBadge(name: ticket.statusName, colorHex: ticket.color),
                ],
              ),
            ],
          ),
        ),
        const SectionLabel(
          'DESCRIPTION',
          padding: EdgeInsets.fromLTRB(6, 18, 6, 8),
        ),
        StaffCard(
          radius: 22,
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              ticket.description.trim().isEmpty
                  ? 'No description was added.'
                  : ticket.description.trim(),
              style: sora(
                13.5,
                weight: FontWeight.w400,
                color: p.text,
                height: 1.6,
              ),
            ),
          ),
        ),
        if (ticket.attachment?.isNotEmpty ?? false) ...[
          const SectionLabel(
            'ATTACHMENT',
            padding: EdgeInsets.fromLTRB(6, 18, 6, 8),
          ),
          StaffCard(
            radius: 22,
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ticket.attachment!,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : SizedBox(
                        height: 160,
                        child: Center(
                          child: CircularProgressIndicator(color: p.amberText),
                        ),
                      ),
                errorBuilder: (_, __, ___) => SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'Attachment could not be loaded',
                      style: sora(12, weight: FontWeight.w500, color: p.muted),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SectionLabel(
          'DETAILS',
          padding: EdgeInsets.fromLTRB(6, 18, 6, 8),
        ),
        TicketGroup(
          children: [
            TicketInfoRow(
              glyph: StaffGlyphs.doc,
              accent: StaffAccent.blue,
              label: 'Type',
              value: ticket.ticketType,
            ),
            TicketInfoRow(
              glyph: StaffGlyphs.pin,
              accent: StaffAccent.green,
              label: 'Location',
              value: ticket.locationName,
            ),
            TicketInfoRow(
              glyph: StaffGlyphs.building,
              accent: StaffAccent.violet,
              label: 'Block',
              value: ticket.blockName,
            ),
          ],
        ),
        const SectionLabel(
          'REPORTED BY',
          padding: EdgeInsets.fromLTRB(6, 18, 6, 8),
        ),
        StaffCard(
          radius: 22,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              PersonTile(name: ticket.requesterName, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ticket.requesterName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: sora(14, weight: FontWeight.w600, color: p.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.label,
    required this.glyph,
    required this.onTap,
  });

  final String label;
  final String glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: AmberButton(label: label, glyph: glyph, onPressed: onTap),
    );
  }
}
