import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final double width;

  const SectionTitle({
    Key? key,
    required this.title,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: width * 0.038,
        fontWeight: FontWeight.w700,
        color: ConstColors.textDark,
      ),
    );
  }
}
