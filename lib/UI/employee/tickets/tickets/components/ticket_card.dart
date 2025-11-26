// lib/UI/employee/tickets/widgets/ticket_card.dart

import 'package:admin_app/UI/employee/tickets/manage_tickets/components/build_info_chip.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatefulWidget {
  final TicketModel ticket;
  const TicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  _TicketCardState createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  static const int _descriptionLimit = 100; // ↔︎ your chosen threshhold
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final description = ticket.description;
    final isLong = description.length > _descriptionLimit;

    // parse & format date
    final dt = DateTime.parse(ticket.createdAt);
    final formattedDate = DateFormat('MMM d, yyyy, h:mm a').format(dt);

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          Routes.ticketDetailPage.name,
          extra: {
            'ticketId': widget.ticket.id.toString(),
            'isPushNotification': false,
          },
          // Pass `MenuModel`
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
                  Text(
                    '#${ticket.id} . ${ticket.category}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    formattedDate,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
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
