import 'package:admin_app/staff/notification/components/notification_card.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';

/// A date label followed by its notification rows.
class NotificationGroup extends StatelessWidget {
  final String date;
  final List<NotificationModel> notifications;
  final ValueChanged<NotificationModel> onOpen;
  final double horizontalPadding;

  const NotificationGroup({
    super.key,
    required this.date,
    required this.notifications,
    required this.onOpen,
    this.horizontalPadding = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          date.toUpperCase(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            4,
          ),
        ),
        for (final n in notifications)
          NotificationCard(
            notificationModel: n,
            horizontalPadding: horizontalPadding,
            onTap: () => onOpen(n),
          ),
      ],
    );
  }
}
