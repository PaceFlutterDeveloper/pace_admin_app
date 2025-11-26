import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Personal information',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2080B2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: const ShapeDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/image/user.png")
                              as ImageProvider,
                          fit: BoxFit.fill,
                        ),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Account details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Name
            buildAccountDetailTile(
              title: 'NAME',
              value: 'Mohamed Hashiq Valiyakath Hashim Hashim Valiyakath',
              showEditIcon: false,
            ),
            const SizedBox(height: 8),
            // Email
            buildAccountDetailTile(
              title: 'E-MAIL',
              value: 'mohamedhashiqvh@gmail.com',
            ),
            const SizedBox(height: 8),
            // Phone Number
            buildAccountDetailTile(
              title: 'PHONE NUMBER',
              value: '+971 54 463 9909',
            ),
            const SizedBox(height: 8),
            // National ID with Verified Status
            buildAccountDetailTile(
              title: 'NATIONAL ID',
              value: '784-XXXX-XXXX670-6',
              verifiedStatus: 'Verified',
              verifiedIcon: Icons.check_circle,
            ),
            const Spacer(),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed(Routes.updatePassword.name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget buildAccountDetailTile({
    required String title,
    required String value,
    bool showEditIcon = true,
    String? verifiedStatus,
    IconData? verifiedIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showEditIcon)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
          ],
        ),
        // Display verified status if provided
        if (verifiedStatus != null)
          Row(
            children: [
              Icon(
                verifiedIcon,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                verifiedStatus,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
