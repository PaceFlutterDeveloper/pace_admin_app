import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/components/ticket_priority_badge.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_avatar.dart';
import 'package:admin_app/core/widgets/app_badge.dart';
import 'package:admin_app/core/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ManageTicketCard extends StatelessWidget {
  final ManageTicketModel ticket;
  final VoidCallback? onTicketUpdated;

  const ManageTicketCard({
    super.key,
    required this.ticket,
    this.onTicketUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final formattedDate =
        DateFormat('MMM d, yyyy · h:mm a').format(DateTime.parse(ticket.createdAt));

    return AppCard(
      onTap: () async {
        final updated = await context.pushNamed<bool>(
          Routes.manageTicketDetailPage.name,
          extra: {
            'ticketId': ticket.id.toString(),
            'isPushNotification': false,
          },
        );

        if (updated == true) {
          onTicketUpdated?.call();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: ticket.requesterName,
                size: AppAvatarSize.sm,
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.requesterName,
                      style: theme.textTheme.titleMedium,
                    ),
                    AppSpacing.vGapXs,
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: colors.textTertiary,
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            '#${ticket.id} · ${ticket.category}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vGapSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              TicketPriorityBadge(priorityName: ticket.priorityName),
              AppBadge.neutral(
                label: ticket.locationName,
                icon: CupertinoIcons.location_solid,
                size: AppBadgeSize.small,
              ),
              AppBadge.neutral(
                label: ticket.blockName,
                icon: CupertinoIcons.building_2_fill,
                size: AppBadgeSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
