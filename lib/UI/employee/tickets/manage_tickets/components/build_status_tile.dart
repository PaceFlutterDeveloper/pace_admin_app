// ignore_for_file: must_be_immutable

import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildStatusTile extends StatelessWidget {
  final IconData icon;
  Color? iconColor;
  final String label;
  final int count;
  BuildStatusTile(
      {super.key,
      required this.icon,
      required this.label,
      required this.count,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F8F8),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFEBECEE), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? ConstColors.purple, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: ConstColors.textDark,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '$count',
            style: const TextStyle(
              color: ConstColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
