import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_event.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_state.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/status_option.dart';
import 'package:admin_app/UI/employee/tickets/tickets/components/ticket_priority_badge.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/utils/alert_helper.dart';
import 'package:admin_app/core/widgets/app_app_bar.dart';
import 'package:admin_app/core/widgets/app_avatar.dart';
import 'package:admin_app/core/widgets/app_badge.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_card.dart';
import 'package:admin_app/core/widgets/app_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ManageTicketDetailPage extends StatelessWidget {
  final int ticketId;
  final bool isPushNotification;

  const ManageTicketDetailPage({
    super.key,
    required this.ticketId,
    this.isPushNotification = false,
  });

  void _handleBack(BuildContext context) {
    if (isPushNotification) {
      context.go(Routes.home.path);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ManageTicketDetailBloc, ManageTicketDetailState>(
      listener: (context, state) async {
        if (state is ManageTicketDetailUpdated) {
          if (state.status) {
            context
                .read<ManageTicketDetailBloc>()
                .add(FetchTicketDetailEvent(id: ticketId));
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
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.pageBg,
          appBar: AppAppBar(
            title: 'Ticket Details',
            onBackPressed: () => _handleBack(context),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ManageTicketDetailState state) {
    if (state is ManageTicketDetailLoading ||
        state is ManageTicketDetailUpdating) {
      return const Center(child: AppLoadingIndicator());
    }

    if (state is ManageTicketDetailError) {
      return Center(
        child: Text(
          state.message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (state is ManageTicketDetailLoaded) {
      final ticket = state.ticketResponseModel.ticket;
      final colors = context.appColors;
      final createdAt = DateFormat('MMM d, yyyy · h:mm a')
          .format(DateTime.parse(ticket.createdAt));

      return Column(
        children: [
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () async {
                context
                    .read<ManageTicketDetailBloc>()
                    .add(FetchTicketDetailEvent(id: ticketId));
                await context.read<ManageTicketDetailBloc>().stream.firstWhere(
                      (s) =>
                          s is ManageTicketDetailLoaded ||
                          s is ManageTicketDetailError,
                    );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${ticket.id} · ${ticket.category}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        AppSpacing.vGapXs,
                        Text(
                          createdAt,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                        ),
                        if (ticket.attachment?.isNotEmpty ?? false) ...[
                          AppSpacing.vGapMd,
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            child: Image.network(ticket.attachment!),
                          ),
                        ],
                        AppSpacing.vGapMd,
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        AppSpacing.vGapSm,
                        Text(
                          ticket.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        AppSpacing.vGapMd,
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            TicketPriorityBadge(
                                priorityName: ticket.priorityName),
                            AppBadge.neutral(
                              label:
                                  '${ticket.locationName}, ${ticket.blockName}',
                              icon: CupertinoIcons.location_solid,
                            ),
                          ],
                        ),
                        AppSpacing.vGapLg,
                        Text(
                          'Reported by',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                        ),
                        AppSpacing.vGapSm,
                        Row(
                          children: [
                            AppAvatar(
                              name: ticket.requesterName,
                              size: AppAvatarSize.sm,
                            ),
                            AppSpacing.hGapSm,
                            Text(
                              ticket.requesterName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, state),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomBar(BuildContext context, ManageTicketDetailState state) {
    if (state is! ManageTicketDetailLoaded) {
      return const SizedBox.shrink();
    }

    final ticket = state.ticketResponseModel.ticket;

    if (ticket.assignedTo == null) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton.primary(
            label: 'Accept Ticket',
            leadingIcon: CupertinoIcons.checkmark_circle,
            onPressed: () {
              context.read<ManageTicketDetailBloc>().add(
                    UpdateTicketStatusEvent(
                      id: ticketId,
                      action: 'accept_ticket',
                    ),
                  );
            },
          ),
        ),
      );
    }

    if (ticket.endStat == 0 &&
        (ticket.statusOptions?.isNotEmpty ?? false)) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton.primary(
            label: 'Update Status',
            leadingIcon: CupertinoIcons.arrow_2_circlepath,
            onPressed: () =>
                _showStatusDialog(context, ticket.statusOptions!),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showStatusDialog(BuildContext context, List<StatusOption> options) {
    final commentController = TextEditingController();
    StatusOption? selected;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Update Status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  AppSpacing.vGapMd,
                  DropdownButtonFormField<StatusOption>(
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
                  AppSpacing.vGapMd,
                  TextFormField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                    ),
                  ),
                  AppSpacing.vGapLg,
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.secondary(
                          label: 'Cancel',
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: AppButton.primary(
                          label: 'Submit',
                          enabled: selected != null,
                          onPressed: selected == null
                              ? null
                              : () {
                                  context
                                      .read<ManageTicketDetailBloc>()
                                      .add(UpdateTicketStatusEvent(
                                        id: ticketId,
                                        action: 'update_status',
                                        statusId: selected!.statusId,
                                        comment:
                                            commentController.text.trim(),
                                      ));
                                  Navigator.of(dialogCtx).pop();
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
