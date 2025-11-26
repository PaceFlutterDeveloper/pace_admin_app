// lib/UI/notification/components/notification_list.dart

import 'package:admin_app/UI/notification/components/notification_group.dart';
import 'package:admin_app/UI/notification/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notificationsList;
  final ScrollController controller;
  final bool isLoadingMore;
  final bool hasMore;

  const NotificationList({
    Key? key,
    required this.notificationsList,
    required this.controller,
    required this.isLoadingMore,
    required this.hasMore,
  }) : super(key: key);

  /// Group notifications by dateAdded
  Map<String, List<NotificationModel>> groupByDate(
      List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> map = {};
    for (var n in notifications) {
      map.putIfAbsent(n.dateAdded, () => []).add(n);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByDate(notificationsList);
    final dates = grouped.keys.toList();

    return ListView.builder(
      controller: controller,
      // padding: EdgeInsets.all(12.0.w),
      itemCount: dates.length + 1, // +1 for footer
      itemBuilder: (ctx, idx) {
        if (idx < dates.length) {
          final date = dates[idx];
          final items = grouped[date]!;
          return NotificationGroup(
              date: DateFormat("d MMMM yyyy")
                  .format(DateFormat("dd-MM-yyyy").parse(date)),
              notifications: items);
        }

        // footer slot:
        if (isLoadingMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (!hasMore) {
          return Center(
            child: Text(
              'No more notifications',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        } else {
          // when neither loading nor ended, show nothing
          return const SizedBox.shrink();
        }
      },
    );
  }
}
