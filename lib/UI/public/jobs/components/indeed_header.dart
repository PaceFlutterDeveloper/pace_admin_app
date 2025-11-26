import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class IndeedHeader extends StatelessWidget {
  const IndeedHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.04,
        vertical: h * 0.015,
      ),
      decoration: BoxDecoration(
        color: ConstColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo/Title
          Text(
            'indeed',
            style: TextStyle(
              fontSize: w * 0.06,
              fontWeight: FontWeight.w700,
              color: ConstColors.blueColor,
            ),
          ),

          // Action Icons
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: ConstColors.textDark,
                size: w * 0.06,
              ),
              SizedBox(width: w * 0.04),
            ],
          ),
        ],
      ),
    );
  }
}
