import 'package:admin_app/UI/employee/tickets/tickets/components/ticket_priority_badge.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_app_bar.dart';
import 'package:admin_app/core/widgets/app_badge.dart';
import 'package:admin_app/core/widgets/app_card.dart';
import 'package:admin_app/core/widgets/app_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TicketDetailPage extends StatelessWidget {
  final bool isPushNotification;
  final int ticketId;

  const TicketDetailPage({
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.pageBg,
      appBar: AppAppBar(
        title: 'Ticket Details',
        onBackPressed: () => _handleBack(context),
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
            return const Center(child: AppLoadingIndicator());
          }
          if (state is SingleTicketError) {
            return Center(
              child: Text(
                state.message,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
          if (state is SingleTicketSuccess) {
            final ticket = state.ticketResponseModel.ticket;
            final colors = context.appColors;
            final createdAt = DateFormat('MMM d, yyyy · h:mm a')
                .format(DateTime.parse(ticket.createdAt));

            return AppRefreshIndicator(
              onRefresh: () async {
                await context
                    .read<TicketsCubit>()
                    .fetchSingleTicket(id: ticketId);
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
                          style: theme.textTheme.headlineSmall,
                        ),
                        AppSpacing.vGapXs,
                        Text(
                          createdAt,
                          style: theme.textTheme.bodySmall?.copyWith(
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
                          style: theme.textTheme.titleMedium,
                        ),
                        AppSpacing.vGapSm,
                        Text(
                          ticket.description,
                          style: theme.textTheme.bodyMedium,
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
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
