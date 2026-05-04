import 'dart:math' as math;
import 'dart:ui';

import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Tab definition for the floating glass navigation bar.
class NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<NavTab> kAppGlassNavTabs = [
  NavTab(
    icon: CupertinoIcons.house,
    activeIcon: CupertinoIcons.house_fill,
    label: 'Home',
  ),
  NavTab(
    icon: CupertinoIcons.doc_text,
    activeIcon: CupertinoIcons.doc_text_fill,
    label: 'Tickets',
  ),
  NavTab(
    icon: CupertinoIcons.bell,
    activeIcon: CupertinoIcons.bell_fill,
    label: 'Alerts',
  ),
  NavTab(
    icon: CupertinoIcons.person,
    activeIcon: CupertinoIcons.person_fill,
    label: 'Profile',
  ),
];

/// Vertical space to reserve so content clears the floating pill + safe area.
double glassNavBarBodyOverlap(BuildContext context) {
  final safe = MediaQuery.paddingOf(context).bottom;
  const floatGap = AppSpacing.sm * 2;
  return math.max(
    AppSizes.bodyBottomInsetFloatingNav,
    safe + floatGap + AppSizes.bottomNavHeight,
  );
}

/// Resolves which shell tab is active for [uri].
int glassShellTabIndex(Uri uri) {
  final p = uri.path;
  if (p == Routes.userProfile.path) return 3;
  if (p == Routes.getNotifications.path) return 2;
  if (p.startsWith(Routes.tickets.path) ||
      p.startsWith(Routes.manageTickets.path)) {
    return 1;
  }
  return 0;
}

void glassShellOnTabTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go(Routes.home.path);
      break;
    case 1:
      context.go(Routes.tickets.path);
      break;
    case 2:
      context.go(Routes.getNotifications.path);
      break;
    case 3:
      context.go(Routes.userProfile.path);
      break;
  }
}

/// Floating iOS-style glass pill navigation (4 tabs).
class AppGlassNavBar extends StatelessWidget {
  const AppGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.ticketsBadgeTotal = 0,
    this.showAlertsDot = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  /// When > 0, shows a red dot on the Tickets tab.
  final int ticketsBadgeTotal;
  final bool showAlertsDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = scheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.navBarPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: AppSizes.bottomNavHeight,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(AppRadius.navBarPill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: List.generate(kAppGlassNavTabs.length, (i) {
              final tab = kAppGlassNavTabs[i];
              final selected = i == currentIndex;

              final showTicketDot = i == 1 && ticketsBadgeTotal > 0;
              final showBellDot = i == 2 && showAlertsDot;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: AppDurations.fast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Icon(
                            selected ? tab.activeIcon : tab.icon,
                            size: 22,
                            color: selected
                                ? primary
                                : Colors.grey.shade400,
                          ),
                        ),
                        if (showTicketDot || showBellDot)
                          Positioned(
                            right: showTicketDot ? 2 : 0,
                            top: 0,
                            child: Container(
                              width: AppSpacing.sm,
                              height: AppSpacing.sm,
                              decoration: BoxDecoration(
                                color: scheme.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.surfaceContainerDark
                                      : Colors.white,
                                  width: AppSpacing.xs / 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Shell navigation bar wired to [GoRouter] and auth notification state.
class AppGlassShellNavBar extends StatelessWidget {
  const AppGlassShellNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final index = glassShellTabIndex(routerState.uri);

    return ValueListenableBuilder<Box<AuthModel>>(
      valueListenable: locator<Box<AuthModel>>().listenable(),
      builder: (context, box, _) {
        final user = box.values.firstWhere(
          (u) => u.isActive,
          orElse: () => AuthModel.empty(),
        );

        return AppGlassNavBar(
          currentIndex: index,
          ticketsBadgeTotal: 0,
          showAlertsDot: user.notificationCount > 0,
          onTap: (i) => glassShellOnTabTap(context, i),
        );
      },
    );
  }
}
