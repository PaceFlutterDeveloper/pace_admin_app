import 'package:admin_app/UI/notification/cubit/notification_cubit.dart';
import 'package:admin_app/UI/notification/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notificationModel;

  const NotificationCard({
    Key? key,
    required this.notificationModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to adjust layout based on device size
    final screenWidth = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: () {
        context.read<NotificationCubit>().markAsRead(notificationModel.id);
        final appPage = notificationModel.appPage;
        final segments = appPage.split('/');
        final maybeId = segments.length > 2 ? segments.last : null;

        if (appPage.startsWith('/manageTicketDetailPage')) {
          if (maybeId != null && int.tryParse(maybeId) != null) {
            context.push(appPage); // Navigate to detailed ticket page
          } else {
            context.push('/manageTickets'); // Navigate to ticket list
          }
        } else if (appPage.startsWith('/ticketDetailPage')) {
          if (maybeId != null && int.tryParse(maybeId) != null) {
            context.push(appPage); // Navigate to detailed ticket page
          } else {
            context.push('/tickets'); // Navigate to different ticket list
          }
        } else {
          context.push(appPage); // Default navigation
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(
            screenWidth * 0.03), // Padding adjusted to screen size
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: const Color(0xFFEAECF0),
            ),
          ),
          color:
              const Color.fromARGB(255, 255, 255, 255), // Light blue background
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with red dot indicator
            Stack(
              alignment: Alignment.topRight,
              children: [
                SvgPicture.asset('assets/icons/not.svg'),
                if (notificationModel.readStat == 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: screenWidth * 0.02, // Dot size adjusted
                      height: screenWidth * 0.02,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: screenWidth * 0.03), // Space between icon and text

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          notificationModel.head,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 16.sp // Font size based on screen width
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notificationModel.timeAgo,
                        style: TextStyle(
                          color: const Color(0xFF667085),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: screenWidth *
                          0.015), // Adjusted space between title and message

                  // Message content
                  Text(
                    notificationModel.notification,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: screenWidth * 0.035, // Font size adjusted
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
