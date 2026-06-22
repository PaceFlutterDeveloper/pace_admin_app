import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? leading;
  final double width;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.leading,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = width * 0.035;

    return Row(
      children: [
        leading ??
            Icon(
              icon ?? Icons.info_outline,
              size: iconSize,
              color: ConstColors.textLight,
            ),
        SizedBox(width: width * 0.015),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: width * 0.032,
            fontWeight: FontWeight.w600,
            color: ConstColors.textDark,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
              color: ConstColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
