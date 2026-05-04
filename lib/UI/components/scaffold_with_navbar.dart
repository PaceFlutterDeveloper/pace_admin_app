import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_glass_nav_bar.dart';
import 'package:flutter/material.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    const floatGap = AppSpacing.sm * 2;

    return Scaffold(
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: glassNavBarBodyOverlap(context),
              ),
              child: child,
            ),
          ),
          Positioned(
            left: AppSpacing.lg - AppSpacing.xs,
            right: AppSpacing.lg - AppSpacing.xs,
            bottom: bottomSafe + floatGap,
            child: const AppGlassShellNavBar(),
          ),
        ],
      ),
    );
  }
}
