// lib/UI/employee/tickets/widgets/name_tile.dart

import 'package:flutter/material.dart';

class NameTile extends StatelessWidget {
  /// The full name to display, e.g. "John Doe" or "Alice"
  final String fullName;
  final String time;
  const NameTile({
    Key? key,
    required this.fullName,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = fullName.trim();
    if (name.isEmpty) return const SizedBox();

    // 1. Get the first word and its first letter
    final firstWord = name.split(RegExp(r'\s+')).first;
    final letter = firstWord[0].toUpperCase();

    // 2. Map A–Z to a hue (0°–360°)
    final base = 'A'.codeUnitAt(0);
    final offset = letter.codeUnitAt(0) - base; // 0 for A, 25 for Z
    final hue = (offset.clamp(0, 25)) * (360 / 26);

    // 3. Build a light pastel color from that hue
    final bgColor = HSLColor.fromAHSL(1.0, hue, 0.5, 0.85).toColor();
    final fontColor = Colors.black87;

    // 4. Merge incoming textStyle with our font color
    final nameStyle =
        (Theme.of(context).textTheme.bodyMedium)!.copyWith(color: fontColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Letter‐box
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(32 * 0.25),
          ),
          child: Text(
            letter,
            style: nameStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(width: 8),

        // Full (first) name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(firstWord, style: nameStyle),
            Text(
              time,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}
