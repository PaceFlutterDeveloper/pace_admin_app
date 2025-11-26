// lib/UI/employee/tickets/widgets/initial_avatar.dart

import 'package:flutter/material.dart';

class InitialAvatar extends StatelessWidget {
  final String name;
  final double size;

  const InitialAvatar({
    Key? key,
    required this.name,
    this.size = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return const SizedBox();

    final firstLetter = trimmedName[0].toUpperCase();

    // A–Z to hue (0–360)
    final hue = ((firstLetter.codeUnitAt(0) - 'A'.codeUnitAt(0)).clamp(0, 25)) *
        (360 / 26);
    final bgColor = HSLColor.fromAHSL(1.0, hue, 0.5, 0.85).toColor();
    final fontColor = Colors.black87;

    final textStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(color: fontColor, fontWeight: FontWeight.bold);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 10),
      ),
      child: Text(firstLetter, style: textStyle),
    );
  }
}
