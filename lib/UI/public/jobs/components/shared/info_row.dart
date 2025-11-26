import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double width;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: width * 0.035,
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
