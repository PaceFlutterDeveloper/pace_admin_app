import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class ConstGradient {
  static LinearGradient linearGradient =
      LinearGradient(begin: Alignment.bottomRight, colors: [
    ConstColors.primary,
    ConstColors.secondary,
  ]);
  static LinearGradient shimmerGradient = const LinearGradient(
    colors: [
      Color(0xFFEBEBF4),
      Color(0xFFF4F4F4),
      Color(0xFFEBEBF4),
    ],
    stops: [
      0.1,
      0.3,
      0.4,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );
}
