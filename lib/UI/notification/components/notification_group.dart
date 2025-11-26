import 'package:admin_app/UI/notification/components/notification_card.dart';
import 'package:admin_app/UI/notification/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationGroup extends StatelessWidget {
  final String date;
  final List<NotificationModel> notifications;

  const NotificationGroup({
    Key? key,
    required this.date,
    required this.notifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: const Color(0xFFEAECF0),
              ),
            ),
            color: const Color.fromARGB(
                255, 255, 255, 255), // Light blue background
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ),
        ...notifications
            .map((notification) =>
                NotificationCard(notificationModel: notification))
            .toList(),
      ],
    );
  }
}
