import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class DescriptionText extends StatelessWidget {
  final String text;
  final double width;

  const DescriptionText({Key? key, required this.text, required this.width})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: width * 0.035,
        fontWeight: FontWeight.w400,
        color: ConstColors.textDark,
        height: 1.5,
      ),
    );
  }
}
