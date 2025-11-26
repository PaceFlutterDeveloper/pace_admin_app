import 'package:admin_app/UI/components/initial_avatar.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_event.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_state.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/status_option.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/core/utils/alert_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ManageTicketDetailPage extends StatefulWidget {
  final int ticketId;
  final bool isPushNotification;
  const ManageTicketDetailPage(
      {Key? key, required this.ticketId, this.isPushNotification = false})
      : super(key: key);

  @override
  State<ManageTicketDetailPage> createState() => _ManageTicketDetailPageState();
}

class _ManageTicketDetailPageState extends State<ManageTicketDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ManageTicketDetailBloc>()
        .add(FetchTicketDetailEvent(id: widget.ticketId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageTicketDetailBloc, ManageTicketDetailState>(
      listener: (context, state) async {
        if (state is ManageTicketDetailUpdated) {
          if (state.status) {
            context
                .read<ManageTicketDetailBloc>()
                .add(FetchTicketDetailEvent(id: widget.ticketId));
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
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(ManageTicketDetailState state) {
    if (state is ManageTicketDetailLoading ||
        state is ManageTicketDetailUpdating) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ManageTicketDetailError) {
      return Center(child: Text(state.message));
    }

    if (state is ManageTicketDetailLoaded) {
      final ticket = state.ticketResponseModel.ticket;
      final createdAt = DateFormat('MMM d, yyyy, h:mm a')
          .format(DateTime.parse(ticket.createdAt));

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Expanded(
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
                    const Divider(height: 32, color: Color(0xFFEAECF0)),
                    Text('Reported By',
                        style: TextStyle(
                          color: const Color(0xFF101828),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InitialAvatar(
                            size: 30.w,
                            name: ticket.requesterName.split(' ').first),
                        const SizedBox(width: 8),
                        Text(
                          ticket.requesterName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF101828),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            _buildBottomBar(context, state)
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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

  Widget _buildBottomBar(BuildContext context, ManageTicketDetailState state) {
    if (state is ManageTicketDetailLoaded) {
      final ticket = state.ticketResponseModel.ticket;

      if (ticket.assignedTo == null) {
        return _buildActionBar(
          label: 'Accept',
          color: Colors.green,
          onTap: () {
            context.read<ManageTicketDetailBloc>().add(UpdateTicketStatusEvent(
                  id: widget.ticketId,
                  action: 'accept_ticket',
                ));
          },
        );
      } else if (ticket.endStat == 0 &&
          (ticket.statusOptions?.isNotEmpty ?? false)) {
        return _buildActionBar(
          label: 'Update Status',
          color: Colors.black,
          onTap: () => _showStatusDialog(context, ticket.statusOptions!),
        );
      }
    }
    return SizedBox.shrink();
  }

  Widget _buildActionBar({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, List<StatusOption> options) {
    final commentController = TextEditingController();
    StatusOption? selected;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Update Status',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                DropdownButtonFormField<StatusOption>(
                  decoration: InputDecoration(
                    labelText: 'New status',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  items: options
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.statusName),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selected = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selected == null
                            ? null
                            : () {
                                context
                                    .read<ManageTicketDetailBloc>()
                                    .add(UpdateTicketStatusEvent(
                                      id: widget.ticketId,
                                      action: 'update_status',
                                      statusId: selected!.statusId,
                                      comment: commentController.text.trim(),
                                    ));
                                Navigator.of(dialogCtx).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
