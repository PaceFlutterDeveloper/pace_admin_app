import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: Colors.blue[600]!, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
