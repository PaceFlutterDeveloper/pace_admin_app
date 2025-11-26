import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class MyJobsPage extends StatelessWidget {
  const MyJobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Jobs',
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.w700,
            color: ConstColors.textDark,
          ),
        ),
        backgroundColor: ConstColors.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: ConstColors.textDark,
          size: w * 0.06,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: w * 0.2,
              color: ConstColors.textLight,
            ),
            SizedBox(height: h * 0.02),
            Text(
              'No Saved Jobs Yet',
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.w600,
                color: ConstColors.textDark,
              ),
            ),
            SizedBox(height: h * 0.01),
            Text(
              'Jobs you save will appear here',
              style: TextStyle(
                fontSize: w * 0.035,
                color: ConstColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
