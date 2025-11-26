// lib/UI/employee/tickets/widgets/ticket_card.dart

import 'package:admin_app/UI/employee/tickets/manage_tickets/components/build_info_chip.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/components/name_tile.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ManageTicketCard extends StatefulWidget {
  final ManageTicketModel ticket;
  const ManageTicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  _TicketCardState createState() => _TicketCardState();
}

class _TicketCardState extends State<ManageTicketCard> {
  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    // parse & format date
    final dt = DateTime.parse(ticket.createdAt);
    final formattedDate = DateFormat('MMM d, yyyy, h:mm a').format(dt);

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          Routes.manageTicketDetailPage.name,
          extra: {
            'ticketId': widget.ticket.id.toString(),
            'isPushNotification': false,
          },
        );
      },
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFF9FAFB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NameTile(
                        fullName: ticket.requesterName,
                        time: formattedDate,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '#${ticket.id} . ${ticket.category}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Category & Location Chips ──────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    avatar: Icon(Icons.flag, size: 16, color: Colors.white),
                    label: Text(ticket.priorityName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        )),
                    backgroundColor: ticket.priorityName == "Medium"
                        ? Colors.red.shade300
                        : ticket.priorityName == "High"
                            ? Colors.red
                            : Colors.red.shade100,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.all(4),
                    side: BorderSide(
                      color: ticket.priorityName == "Medium"
                          ? Colors.red.shade400
                          : ticket.priorityName == "High"
                              ? Colors.red
                              : Colors.red.shade100,
                    ),
                  ),
                  BuildInfoChip(
                      icon: Icons.pin_drop, label: ticket.locationName),
                  BuildInfoChip(
                      icon: Icons.location_city_rounded,
                      label: ticket.blockName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
