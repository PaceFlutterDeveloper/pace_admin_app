// lib/UI/employee/tickets/pages/ticket_detail_page.dart

import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TicketDetailPage extends StatefulWidget {
  final bool isPushNotification;

  /// A minimal ticket; we'll fetch the full detail by ID.
  final int ticketId;

  const TicketDetailPage(
      {Key? key, required this.ticketId, this.isPushNotification = false})
      : super(key: key);

  @override
  _TicketDetailPageState createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  @override
  void initState() {
    super.initState();
    // Kick off the API call to get the full detail:
    context.read<TicketsCubit>().fetchSingleTicket(id: widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Task Details',
          style: TextStyle(
            color: const Color(0xFF101828),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: BackButton(
          color: Colors.black87,
          onPressed: () {
            if (widget.isPushNotification) {
              context.go(Routes.home.path);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BlocConsumer<TicketsCubit, TicketsState>(
        listener: (context, state) {
          if (state is SingleTicketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SingleTicketLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SingleTicketError) {
            return Center(child: Text(state.message));
          }
          if (state is SingleTicketSuccess) {
            // unpack the fetched detail:
            final detail = state.ticketResponseModel;
            final ticket = detail.ticket; // TicketModel

            // format the date
            final dt = DateTime.parse(ticket.createdAt);
            final createdAt = DateFormat('MMM d, yyyy, h:mm a').format(dt);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    Text('#${ticket.id} • ${ticket.category}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    Text(
                      createdAt,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    if (ticket.attachment?.isNotEmpty ?? false) ...[
                      Image.network(ticket.attachment!),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFEAECF0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(ticket.description,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildChipInfo(
                          title: "Priority",
                          icon: Icons.flag,
                          label: ticket.priorityName,
                          bgColor: ticket.priorityName == "High"
                              ? Colors.red
                              : ticket.priorityName == "Medium"
                                  ? Colors.red.shade300
                                  : Colors.red.shade100,
                          textColor: Colors.white,
                        ),
                        _buildChipInfo(
                          title: "Location",
                          icon: Icons.location_on,
                          label: "${ticket.locationName}, ${ticket.blockName}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          // fallback
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildChipInfo({
    required String title,
    required IconData icon,
    required String label,
    Color bgColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF101828),
            )),
        Chip(
          avatar: Icon(icon, size: 16, color: textColor),
          label: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
          backgroundColor: bgColor,
          side: BorderSide(color: bgColor),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
