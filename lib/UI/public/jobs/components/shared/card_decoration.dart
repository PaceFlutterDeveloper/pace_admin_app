import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class CardDecoration {
  static BoxDecoration build(double w) {
    return BoxDecoration(
      color: ConstColors.whiteColor,
      borderRadius: BorderRadius.circular(w * 0.03),
      border: Border.all(
        color: ConstColors.borderColor,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
