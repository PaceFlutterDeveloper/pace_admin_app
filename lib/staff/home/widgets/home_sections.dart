import 'package:admin_app/staff/home/menu/staff_menu_tile.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// One quick-stat card: glass icon, big number, caption.
class QuickStatCard extends StatelessWidget {
  const QuickStatCard({
    super.key,
    required this.glyph,
    required this.accent,
    required this.label,
    required this.onTap,
    this.value,
  });

  final String glyph;
  final StaffAccent accent;
  final String label;
  final VoidCallback onTap;

  /// Null shows a "Soon" marker for modules without a backend yet.
  final String? value;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final tint = p.tint(accent);
    return StaffCard(
      radius: 20,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // A faint accent wash so each stat has its own colour.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint.background.withValues(alpha: p.isDark ? 0.4 : 0.5),
              tint.background.withValues(alpha: 0),
            ],
            stops: const [0, 0.7],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassIconTile(
              glyph: glyph,
              accent: accent,
              size: 38,
              radius: 13,
              iconSize: 19,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 26,
              child: value != null
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value!,
                        style: sora(
                          20,
                          weight: FontWeight.w800,
                          color: p.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Soon',
                        style: sora(
                          15,
                          weight: FontWeight.w700,
                          color: p.muted,
                        ),
                      ),
                    ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(11.5, weight: FontWeight.w500, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card of up to four live modules for one-tap access from Home.
class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key, required this.tiles});

  final List<StaffMenuTile> tiles;

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: staffMenuGridDelegate(context),
        children: tiles,
      ),
    );
  }
}

/// Skeleton for [QuickAccessCard] while the menu loads.
class QuickAccessSkeleton extends StatelessWidget {
  const QuickAccessSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Shimmer.fromColors(
      baseColor: p.surfaceRaised,
      highlightColor: p.surface,
      child: StaffCard(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 4; i++)
              const StaffSkeleton(width: 58, height: 58, radius: 20),
          ],
        ),
      ),
    );
  }
}
