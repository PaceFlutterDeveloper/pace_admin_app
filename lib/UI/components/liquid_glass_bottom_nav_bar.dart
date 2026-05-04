import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/components/initial_avatar.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glass_liquid_navbar/glass_liquid_navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

const double _kLiquidNavPillHeight = 64;
const double _kLiquidNavFloatingOffset = 16;

/// Bottom padding for scaffold body with [LiquidGlassNavbar] + [extendBody].
double liquidGlassNavbarBodyOverlap(BuildContext context) =>
    _kLiquidNavPillHeight +
    _kLiquidNavFloatingOffset +
    MediaQuery.paddingOf(context).bottom;

int shellTabCurrentIndex(Uri uri) {
  final path = uri.path;
  if (path == Routes.getNotifications.path) return 1;
  if (path == Routes.userProfile.path) return 2;
  return 0;
}

LiquidGlassTheme _liquidGlassNavTheme(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final primary = scheme.primary;

  return Theme.of(context).brightness == Brightness.dark
      ? LiquidGlassTheme.dark(
          selectedColor: primary,
          unselectedColor: Colors.white.withValues(alpha: 0.42),
          indicatorColor: primary.withValues(alpha: 0.32),
          pillHeight: _kLiquidNavPillHeight,
          iconSize: 26,
        )
      : LiquidGlassTheme.light(
          selectedColor: primary,
          unselectedColor: scheme.onSurface.withValues(alpha: 0.42),
          indicatorColor: primary.withValues(alpha: 0.16),
          pillHeight: _kLiquidNavPillHeight,
          iconSize: 26,
        );
}

/// Glass-style bottom navigation for the main authenticated shell route.
class LiquidGlassUserBottomNav extends StatelessWidget {
  const LiquidGlassUserBottomNav({super.key});

  static void _onTabTap(BuildContext context, int index) {
    if (index == 1) {
      context.go(Routes.getNotifications.path);
    } else if (index == 2) {
      context.go(Routes.userProfile.path);
    } else {
      context.go(Routes.home.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final currentIndex = shellTabCurrentIndex(routerState.uri);

    return ValueListenableBuilder<Box<AuthModel>>(
      valueListenable: locator<Box<AuthModel>>().listenable(),
      builder: (context, box, _) {
        final user = box.values.firstWhere(
          (u) => u.isActive,
          orElse: () => AuthModel.empty(),
        );

        final items = [
          const LiquidNavItem(
            icon: CupertinoIcons.house_fill,
            label: 'Home',
          ),
          LiquidNavItem(
            customIcon: _BellWithBadge(count: user.notificationCount),
            label: 'Notifications',
          ),
          LiquidNavItem(
            customIcon: _ProfileShellNavAvatar(user: user),
            label: 'Profile',
          ),
        ];

        return LiquidGlassNavbar(
          items: items,
          currentIndex: currentIndex,
          onTap: (i) => _onTabTap(context, i),
          theme: _liquidGlassNavTheme(context),
          showLabels: false,
          animationDuration: const Duration(milliseconds: 340),
          enableHaptics: true,
          floatingOffset: _kLiquidNavFloatingOffset,
          isFullWidth: false,
        );
      },
    );
  }
}

/// Package 0.2.x ignores [LiquidNavItem.badge]; draw count badge here.
class _BellWithBadge extends StatelessWidget {
  const _BellWithBadge({required this.count});

  final int count;
  static const double _slot = 26;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _slot,
      height: _slot,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Icon(
            CupertinoIcons.bell_fill,
            size: _slot * 0.92,
            color: scheme.primary,
          ),
          if (count > 0)
            Positioned(
              right: -6,
              top: -8,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16),
                padding: EdgeInsets.symmetric(
                  horizontal: count > 9 ? 4 : 0,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: scheme.error, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    fontSize: count > 99 ? 8 : 10,
                    fontWeight: FontWeight.w700,
                    color: scheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileShellNavAvatar extends StatelessWidget {
  const _ProfileShellNavAvatar({required this.user});

  final AuthModel user;
  static const double _size = 26;

  @override
  Widget build(BuildContext context) {
    final nameLabel = user.name.isNotEmpty ? user.name : '?';

    if (user.profilePicture.isEmpty) {
      return InitialAvatar(name: nameLabel, size: _size);
    }

    return ClipOval(
      child: Image.network(
        user.profilePicture,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            InitialAvatar(name: nameLabel, size: _size),
      ),
    );
  }
}
