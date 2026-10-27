import 'package:admin_app/staff/notification/components/notification_group.dart';
import 'package:admin_app/staff/notification/components/notification_style.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:flutter/material.dart';

/// Grouped, scrollable notification list with a load-more footer.
class NotificationList extends StatelessWidget {
  final List<NotificationModel> notificationsList;
  final ScrollController controller;
  final bool isLoadingMore;
  final bool hasMore;
  final ValueChanged<NotificationModel> onOpen;
  final double horizontalPadding;
  final EdgeInsetsGeometry padding;

  const NotificationList({
    super.key,
    required this.notificationsList,
    required this.controller,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onOpen,
    this.horizontalPadding = 18,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final groups = groupNotifications(notificationsList);

    return ListView.builder(
      controller: controller,
      padding: padding,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: groups.length + 1,
      itemBuilder: (context, i) {
        if (i < groups.length) {
          final g = groups[i];
          return NotificationGroup(
            date: g.label,
            notifications: g.items,
            onOpen: onOpen,
            horizontalPadding: horizontalPadding,
          );
        }
        if (isLoadingMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: p.amberText,
                ),
              ),
            ),
          );
        }
        if (!hasMore && notificationsList.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                'You are all caught up',
                style: sora(11.5, weight: FontWeight.w500, color: p.muted),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
