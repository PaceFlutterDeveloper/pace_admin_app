import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/home/components/select_user.dart';
import 'package:admin_app/UI/home/components/user_tile.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : _scaffoldKey = scaffoldKey;

  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ConstColors.backgroundColor,
      child: ListView(
        //   padding: EdgeInsets.fromLTRB(16.0, 60.h, 16.0, 8.0),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 10.h, 16.0, 8.0),
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: UserTile(
                      onTap: () {
                        _scaffoldKey.currentState!.closeDrawer();
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20.0)),
                        ),
                        builder: (context) => const SelectUser(),
                      );
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFF5F6F9),
                        shape: OvalBorder(),
                      ),
                      child: const Center(child: Icon(Icons.swap_vert)),
                    ),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              locator<AuthCubit>().logout();
              // Handle tap action here
            },
          ),
        ],
      ),
    );
  }
}
