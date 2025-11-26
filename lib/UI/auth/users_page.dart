import 'dart:developer' as developer;

import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/components/button_component.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/services/authentication_service.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final AuthenticationService authService = locator<AuthenticationService>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive constants
    final sidePadding = w * 0.05; // ~20px on 400px-wide
    final titleFontSize = w * 0.045; // ~18px
    final listFontSize = w * 0.04; // ~16px
    final subtitleFontSize = w * 0.035; // ~14px
    final avatarRadius = w * 0.07; // ~28px
    final iconSize = w * 0.06; // ~24px
    final buttonHeight = h * 0.07; // ~56px
    final buttonBottomPad = h * 0.025; // ~20px

    final Box<AuthModel> userBox = locator<Box<AuthModel>>();

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Users',
          style: TextStyle(
            color: const Color(0xFF101828),
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const BackButton(color: Colors.black87),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        child: ValueListenableBuilder<Box<AuthModel>>(
          valueListenable: userBox.listenable(),
          builder: (context, box, _) {
            final users = box.values.toList();

            if (users.isEmpty) {
              return Center(
                child: Text(
                  "No users available",
                  style: TextStyle(
                    fontSize: listFontSize,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(bottom: buttonBottomPad + buttonHeight),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                developer.log(user.toString());

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: h * 0.015),
                  onTap: () {
                    locator<AuthCubit>().switchUser(
                      userName: user.userName,
                      schoolCode: user.schoolCode,
                      userId: user.userId,
                      context: context,
                    );
                    context.go(Routes.home.path);
                  },
                  leading: user.notificationCount == 0
                      ? CircleAvatar(
                          backgroundImage: user.profilePicture.isNotEmpty
                              ? NetworkImage(user.profilePicture)
                              : const AssetImage("assets/image/user.png")
                                  as ImageProvider,
                        )
                      : Badge(
                          label: Text(user.notificationCount.toString()),
                          child: CircleAvatar(
                            backgroundImage: user.profilePicture.isNotEmpty
                                ? NetworkImage(user.profilePicture)
                                : const AssetImage("assets/image/user.png")
                                    as ImageProvider,
                          ),
                        ),
                  title: Text(
                    user.userName,
                    style: TextStyle(
                      fontSize: listFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: user.designation,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextSpan(
                          text: " (${user.schoolCode})",
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    user.isActive ? Icons.check_circle : Icons.circle,
                    color: user.isActive ? Colors.green : Colors.grey,
                    size: iconSize,
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          sidePadding,
          0,
          sidePadding,
          buttonBottomPad,
        ),
        child: ButtonComponent(
          buttonText: "Add Account",
          onTap: () async {
            final ok = await authService.authenticate();
            if (ok) context.push(Routes.loginPage.path);
          },
        ),
      ),
    );
  }
}
