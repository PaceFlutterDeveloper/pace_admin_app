import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class CareersBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CareersBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Container(
      height: h * 0.08,
      decoration: BoxDecoration(
        color: ConstColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            Icons.home,
            'Home',
            0,
            w,
            h,
          ),
          _buildNavItem(
            context,
            Icons.bookmark,
            'My jobs',
            1,
            w,
            h,
          ),
          _buildNavItem(
            context,
            Icons.message,
            'Messages',
            2,
            w,
            h,
          ),
          _buildNavItem(
            context,
            Icons.person,
            'Profile',
            3,
            w,
            h,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    double w,
    double h,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.01,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? ConstColors.blueColor : ConstColors.textLight,
              size: w * 0.06,
            ),
            SizedBox(height: h * 0.005),
            Text(
              label,
              style: TextStyle(
                fontSize: w * 0.032,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? ConstColors.blueColor : ConstColors.textLight,
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: h * 0.002),
                height: 2,
                width: w * 0.08,
                decoration: BoxDecoration(
                  color: ConstColors.blueColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
