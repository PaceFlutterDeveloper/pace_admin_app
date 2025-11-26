import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/components/initial_avatar.dart';
import 'package:admin_app/UI/components/notification_icon_component.dart';
import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserBottomNavBar extends StatelessWidget {
  const UserBottomNavBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUri = GoRouterState.of(context).uri;
    return ValueListenableBuilder<Box<AuthModel>>(
      valueListenable: locator<Box<AuthModel>>().listenable(),
      builder: (context, box, _) {
        final user = box.values.firstWhere(
          (user) => user.isActive,
          orElse: () => AuthModel.empty(),
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          height: 65.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  context.go(
                    Routes.home.path,
                  );
                },
                child: Container(
                  width: 47.w,
                  height: 47.w,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFF4F5FF),
                    shape: OvalBorder(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.home,
                      color: const Color(0xFF6E61FF),
                      size: 30.sp,
                    ),
                  ),
                ),
              ),
              NotificationIconComponent(),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    Routes.userProfile.name,
                    extra: MenuModel(
                      id: '',
                      menuKey: '',
                      menuVal: '',
                      menuName: 'My Profile',
                      page: '',
                      iconUrl: '',
                      parentId: '',
                      subMenu: [],
                    ), // Pass `MenuModel`
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    user.profilePicture.isEmpty
                        ? InitialAvatar(
                            name: user.name,
                            size: 47.w,
                          )
                        : Container(
                            width: 47.w,
                            height: 47.w,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: NetworkImage(user.profilePicture),
                                fit: BoxFit.cover,
                              ),
                              shape: OvalBorder(),
                            ),
                          ),
                    // SizedBox(
                    //   width: 8.w,
                    // ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       user.name,
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         color: const Color(0xFF2D2D2D),
                    //         fontSize: 16.sp,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //     Text(
                    //       user.schoolCode,
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         color: const Color(0xFF6E61FF),
                    //         fontSize: 12.sp,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
