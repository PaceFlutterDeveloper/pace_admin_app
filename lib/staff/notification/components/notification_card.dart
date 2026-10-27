import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/notification/components/notification_style.dart';
import 'package:admin_app/staff/notification/cubit/notification_cubit.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Marks [n] read and opens the screen it points at.
///
/// Mirrors the long-standing behaviour of the notification list: ticket
/// detail links fall back to the matching ticket list when they carry no id.
void openNotification(
  GoRouter router,
  NotificationCubit cubit,
  NotificationModel n,
) {
  cubit.markAsRead(n.id);
  final appPage = n.appPage;
  if (appPage.isEmpty) return;

  final segments = appPage.split('/');
  final maybeId = segments.length > 2 ? segments.last : null;
  final hasId = maybeId != null && int.tryParse(maybeId) != null;

  if (appPage.startsWith('/manageTicketDetailPage')) {
    router.push(hasId ? appPage : Routes.manageTickets.path);
  } else if (appPage.startsWith('/ticketDetailPage')) {
    router.push(hasId ? appPage : Routes.tickets.path);
  } else {
    router.push(appPage);
  }
}

/// One notification row: glass icon, title, preview, time and unread dot.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notificationModel,
    required this.onTap,
    this.horizontalPadding = 18,
  });

  final NotificationModel notificationModel;
  final VoidCallback onTap;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final n = notificationModel;
    final look = notificationLook(n);
    final unread = n.readStat == 0;
    final title = n.head.trim().isNotEmpty ? n.head.trim() : n.notification;
    final body = n.head.trim().isNotEmpty ? n.notification : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassIconTile(
              glyph: look.glyph,
              accent: look.accent,
              size: 42,
              radius: 15,
              iconSize: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: sora(
                      13,
                      weight: unread ? FontWeight.w700 : FontWeight.w600,
                      color: p.text,
                      height: 1.3,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: sora(
                        11.5,
                        weight: FontWeight.w400,
                        color: p.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  n.timeAgo,
                  style: sora(11, weight: FontWeight.w400, color: p.muted),
                ),
                const SizedBox(height: 8),
                if (unread)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: p.amber,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 9),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
