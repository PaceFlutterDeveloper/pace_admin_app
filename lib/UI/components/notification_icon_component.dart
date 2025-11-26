import 'dart:developer';

import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationIconComponent extends StatelessWidget {
  const NotificationIconComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: locator<Box<AuthModel>>().listenable(),
        builder: (context, Box<AuthModel> box, child) {
          // Retrieve the active login model
          AuthModel? activeUser =
              box.values.where((login) => login.isActive).isNotEmpty
                  ? box.values.firstWhere((login) => login.isActive)
                  : null;
          return GestureDetector(
            onTap: () {
              log("Notification Page");
              context.pushNamed(Routes.getNotifications.name);
            },
            child: Badge(
                isLabelVisible: true,
                label: activeUser!.notificationCount == 0
                    ? const SizedBox()
                    : Container(
                        width: 25.h,
                        height: 25.h,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              1000,
                            ),
                            border: Border.all(
                              color: const Color(0xFFB22222),
                              width: 2.w,
                            )),
                        child: Center(
                          child: Text(
                            activeUser.notificationCount.toString(),
                            style: const TextStyle(color: Color(0xFFB22222)),
                          ),
                        ),
                      ),
                offset: Offset(-5.w, 0),
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 47.w,
                  height: 47.w,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF4F5FF),
                    shape: OvalBorder(),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/notification.svg",
                      height: 30.w,
                      width: 30.w,
                    ),
                  ),
                )),
          );
        });
  }
}
