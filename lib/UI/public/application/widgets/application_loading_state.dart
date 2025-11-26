import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplicationLoadingState extends StatelessWidget {
  const ApplicationLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            strokeWidth: 3.w,
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading your applications...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
