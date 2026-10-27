import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:flutter/material.dart';

/// Round photo with the person's initials when there is no photo.
class StaffAvatar extends StatelessWidget {
  const StaffAvatar({
    super.key,
    required this.name,
    this.photo,
    this.size = 44,
  });

  final String name;
  final String? photo;
  final double size;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final url = photo?.trim() ?? '';
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: p.amberSoft, shape: BoxShape.circle),
      child: Text(
        _initials,
        style: sora(size * 0.34, weight: FontWeight.w700, color: p.amberText),
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}
