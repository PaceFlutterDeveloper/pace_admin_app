import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ApplicationEmptyState extends StatelessWidget {
  const ApplicationEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.fileLines,
                size: 48.w,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Applications Yet',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'You haven\'t applied to any jobs yet.\nStart exploring opportunities!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to job listings
                Navigator.pop(context);
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Jobs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 16.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
