// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/components/button_component.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/services/authentication_service.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SelectUser extends StatefulWidget {
  const SelectUser({Key? key}) : super(key: key);

  @override
  State<SelectUser> createState() => _SelectUserState();
}

class _SelectUserState extends State<SelectUser> {
  final AuthenticationService authService = locator<AuthenticationService>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive values
    final horizontalPadding = w * 0.04; // ~16px on 400px-wide screen
    final titleBottomGap = h * 0.012; // ~10px on 800px-high screen
    final listBottomPadding = h * 0.02; // ~16px
    final titleFontSize = w * 0.045; // ~18px
    final nameFontSize = w * 0.04; // ~15px
    final subtitleFontSize = w * 0.033; // ~13px
    final buttonTopPadding = h * 0.012; // ~10px
    final buttonBottomPadding = h * 0.025; // ~20px

    final Box<AuthModel> userBox = locator<Box<AuthModel>>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: buttonTopPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Accounts",
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: titleBottomGap),

          // User list
          Expanded(
            child: ValueListenableBuilder<Box<AuthModel>>(
              valueListenable: userBox.listenable(),
              builder: (context, box, _) {
                final users = box.values.toList();
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      "No users available",
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: listBottomPadding),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    logger.e(user.toString());

                    return ListTile(
                      onTap: () async {
                        final isAuthenticated =
                            await authService.authenticate();
                        if (isAuthenticated) {
                          locator<AuthCubit>().switchUser(
                            userName: user.userName,
                            schoolCode: user.schoolCode,
                            userId: user.userId,
                            context: context,
                          );
                          log("Authenticated! Proceed with account management.");
                        } else {
                          log("Authentication failed. Access denied.");
                        }
                      },
                      leading: user.notificationCount == 0
                          ? CircleAvatar(
                              radius: w * 0.06, // ~24px
                              backgroundImage: user.profilePicture.isNotEmpty
                                  ? NetworkImage(user.profilePicture)
                                  : const AssetImage("assets/image/user.png")
                                      as ImageProvider,
                            )
                          : Badge(
                              label: Text(
                                user.notificationCount.toString(),
                                style: TextStyle(
                                  fontSize: subtitleFontSize * 0.8,
                                  color: Colors.white,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: w * 0.06,
                                backgroundImage: user.profilePicture.isNotEmpty
                                    ? NetworkImage(user.profilePicture)
                                    : const AssetImage("assets/image/user.png")
                                        as ImageProvider,
                              ),
                            ),
                      title: Text(
                        user.userName,
                        style: TextStyle(
                          fontSize: nameFontSize,
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
                        size: w * 0.06, // ~24px
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Add Account button
          Padding(
            padding: EdgeInsets.only(
              top: buttonTopPadding,
              bottom: buttonBottomPadding,
            ),
            child: ButtonComponent(
              buttonText: "Add Account",
              onTap: () async {
                final isAuthenticated = await authService.authenticate();
                if (isAuthenticated) {
                  context.push(Routes.loginPage.path);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
