import 'package:flutter/material.dart';

/// UAE Dirham (AED) glyph — used instead of a generic dollar icon for salary.
class AedCurrencyIcon extends StatelessWidget {
  final double size;
  final Color color;
  final FontWeight fontWeight;

  const AedCurrencyIcon({
    super.key,
    this.size = 14,
    required this.color,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          'د.إ',
          style: TextStyle(
            fontSize: size * 0.78,
            fontWeight: fontWeight,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }
}
