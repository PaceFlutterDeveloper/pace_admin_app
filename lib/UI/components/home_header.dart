import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Grab screen width & height
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive values (tweak the multipliers to suit your design)
    final avatarSize = w * 0.12; // e.g. ~48px on a 400px-wide screen
    final avatarPadding = w * 0.01; // ~4px
    final spacing = w * 0.02; // ~8px
    final fontSize = w * 0.04; // ~16px

    return ValueListenableBuilder<Box<AuthModel>>(
      valueListenable: locator<Box<AuthModel>>().listenable(),
      builder: (context, box, _) {
        final user = box.values.firstWhere(
          (u) => u.isActive,
          orElse: () => AuthModel.empty(),
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: Padding(
                padding: EdgeInsets.all(avatarPadding),
                child: Container(
                  decoration: ShapeDecoration(
                    shape: const OvalBorder(),
                    image: DecorationImage(
                      image: (user.logo != null && user.logo!.isNotEmpty)
                          ? NetworkImage(user.logo!)
                          : const AssetImage("assets/image/user.png")
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // Spacing between avatar and text
            SizedBox(width: spacing),

            // School name
            Flexible(
              child: Text(
                user.schoolName,
                style: TextStyle(
                  color: const Color(0xFF2D2D2D),
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
