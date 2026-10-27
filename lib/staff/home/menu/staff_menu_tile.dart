import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Glass tile with a label, as used in the Menu grid and sub-menu pages.
class StaffMenuTile extends StatefulWidget {
  const StaffMenuTile({
    super.key,
    required this.label,
    required this.glyph,
    required this.accent,
    required this.onTap,
    this.badge = 0,
    this.soon = false,
  });

  final String label;
  final String glyph;
  final StaffAccent accent;
  final VoidCallback onTap;
  final int badge;
  final bool soon;

  @override
  State<StaffMenuTile> createState() => _StaffMenuTileState();
}

class _StaffMenuTileState extends State<StaffMenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Semantics(
      button: true,
      label: widget.soon ? '${widget.label}, coming soon' : widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 110),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: widget.soon ? 0.62 : 1,
                child: GlassIconTile(
                  glyph: widget.glyph,
                  accent: widget.accent,
                  size: 58,
                  radius: 20,
                  iconSize: 25,
                  strokeWidth: 1.8,
                  child: widget.badge > 0
                      ? Positioned(
                          top: -6,
                          right: -6,
                          child: StaffCountBadge(widget.badge),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: sora(
                  11.5,
                  weight: FontWeight.w600,
                  height: 1.2,
                  color: widget.soon ? p.muted : p.text,
                ),
              ),
              if (widget.soon) ...[const SizedBox(height: 3), const SoonPill()],
            ],
          ),
        ),
      ),
    );
  }
}

/// 4-column grid delegate for [StaffMenuTile]s. The row height grows with the
/// system text size so two-line labels and the "Soon" pill never overflow.
SliverGridDelegate staffMenuGridDelegate(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    mainAxisSpacing: 14,
    crossAxisSpacing: 8,
    mainAxisExtent: 118 + (scale - 1) * 64,
  );
}
