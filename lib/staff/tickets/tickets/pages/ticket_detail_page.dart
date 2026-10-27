import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/staff/tickets/tickets/models/ticket_model.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TicketDetailPage extends StatefulWidget {
  final bool isPushNotification;

  /// A minimal ticket; we'll fetch the full detail by ID.
  final int ticketId;

  const TicketDetailPage({
    Key? key,
    required this.ticketId,
    this.isPushNotification = false,
  }) : super(key: key);

  @override
  _TicketDetailPageState createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<TicketsCubit>().fetchSingleTicket(id: widget.ticketId);
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
    final p = context.staff;
    return StaffPage(
      child: BlocConsumer<TicketsCubit, TicketsState>(
        listener: (context, state) {
          if (state is SingleTicketError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          TicketModel? ticket;
          Widget body = const SizedBox.shrink();

          if (state is SingleTicketLoading) {
            body = Center(child: CircularProgressIndicator(color: p.amberText));
          } else if (state is SingleTicketError) {
            body = StaffStateMessage(
              glyph: StaffGlyphs.ticket,
              title: 'Could not load ticket',
              message: state.message,
              actionLabel: 'Try again',
              onAction: _load,
              accent: StaffAccent.pink,
            );
          } else if (state is SingleTicketSuccess) {
            ticket = state.ticketResponseModel.ticket;
            body = _MyTicketBody(ticket: ticket);
          }

          return Column(
            children: [
              StaffPageHeader(
                title: ticket == null ? 'Ticket' : 'Ticket #${ticket.id}',
                subtitle: ticket?.category,
                onBack: _back,
              ),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}

class _MyTicketBody extends StatelessWidget {
  const _MyTicketBody({required this.ticket});

  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final accent = ticketPriorityAccent(ticketPriorityOf(ticket.priorityName));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
      ],
    );
  }
}
