import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/tickets/tickets/models/ticket_model.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  const TicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TicketTile(
      id: ticket.id,
      category: ticket.category,
      createdAt: ticket.createdAt,
      description: ticket.description,
      priority: ticket.priorityName,
      status: ticket.statusName,
      statusColor: ticket.color,
      location: ticket.locationName,
      block: ticket.blockName,
      hasAttachment: ticket.attachment?.isNotEmpty ?? false,
      onTap: () {
        context.pushNamed(
          Routes.ticketDetailPage.name,
          extra: {
            'ticketId': ticket.id.toString(),
            'isPushNotification': false,
          },
        );
      },
    );
  }
}
