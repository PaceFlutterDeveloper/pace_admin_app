import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;

  const ButtonComponent({
    Key? key,
    required this.buttonText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Adjust these multipliers as needed:
    final buttonHeight = h * 0.055; // ~44px on a 800px-high screen
    final borderRadius = w * 0.03; // ~11px on a 360px-wide screen
    final borderWidth = w * 0.0025; // ~1px
    final fontSize = w * 0.04; // ~15px
    // We want the button to fill its parent width, so we use double.infinity.

    return InkWell(
      onTap: onTap,
      child: Container(
        width: w,
        height: buttonHeight,
        decoration: ShapeDecoration(
          color: const Color(0xFF5B2ED4), // background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              width: borderWidth,
              color: const Color(0x59868686),
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          buttonText,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
