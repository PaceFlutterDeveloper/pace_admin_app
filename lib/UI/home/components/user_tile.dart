import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/components/button_component.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserTile extends StatelessWidget {
  final void Function() onTap;

  const UserTile({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accessing the loginBox from dependency injection
    final Box<AuthModel> loginBox = locator<Box<AuthModel>>();

    return ValueListenableBuilder(
      valueListenable: loginBox.listenable(),
      builder: (context, Box<AuthModel> box, child) {
        // Retrieve the active login model
        AuthModel? activeUser =
            box.values.where((login) => login.isActive).isNotEmpty
                ? box.values.firstWhere((login) => login.isActive)
                : null;

        // Display a default user or the active user's data if available
        return activeUser == null
            ? ButtonComponent(buttonText: "LOGIN", onTap: onTap)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF2080B2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: activeUser.profilePicture != null
                                  ? NetworkImage(activeUser.profilePicture)
                                  : const AssetImage("assets/image/user.png")
                                      as ImageProvider,
                              fit: BoxFit.fill,
                            ),
                            shape: const OvalBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeUser.name ?? 'Guest User',
                        style: TextStyle(
                          color: const Color(0xFF191A2C),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        activeUser.schoolCode ?? '',
                        style: TextStyle(
                          color: const Color(0xFF535662),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
      },
    );
  }
}
