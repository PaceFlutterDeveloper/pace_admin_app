import 'package:flutter/material.dart';

class BuildInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  const BuildInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: iconColor ?? Colors.black54),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.white,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.all(4),
      side: BorderSide(color: Colors.white),
    );
  }
}
