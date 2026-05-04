import 'package:admin_app/UI/components/liquid_glass_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomOverlap = liquidGlassNavbarBodyOverlap(context);

    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomOverlap),
        child: child,
      ),
      bottomNavigationBar: const LiquidGlassUserBottomNav(),
    );
  }
}
