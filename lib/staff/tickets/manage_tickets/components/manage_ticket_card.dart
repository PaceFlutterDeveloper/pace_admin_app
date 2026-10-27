import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManageTicketCard extends StatelessWidget {
  final ManageTicketModel ticket;
  const ManageTicketCard({Key? key, required this.ticket}) : super(key: key);

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
      requester: ticket.requesterName,
      hasAttachment: ticket.attachment?.isNotEmpty ?? false,
      onTap: () {
        context.pushNamed(
          Routes.manageTicketDetailPage.name,
          extra: {
            'ticketId': ticket.id.toString(),
            'isPushNotification': false,
          },
        );
      },
    );
  }
}
