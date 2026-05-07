import 'dart:math' as math;
import 'dart:ui';

import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Fixed width per tab so the row scrolls inside the pill without shrinking items.
const double kGlassNavTabItemWidth = 72.0;

/// Tab definition for the floating glass navigation bar.
class NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  /// When positive, shows the attention dot (same visual for any positive count).
  final int badgeCount;

  const NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

/// Builds the ordered shell tabs (indices must stay aligned with [glassShellTabIndex]
/// / [glassShellOnTabTap]).
List<NavTab> buildGlassNavTabs({
  required int ticketsBadgeTotal,
  required bool showAlertsDot,
}) {
  return [
    const NavTab(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    NavTab(
      icon: CupertinoIcons.doc_text,
      activeIcon: CupertinoIcons.doc_text_fill,
      label: 'Tickets',
      badgeCount: ticketsBadgeTotal,
    ),
    const NavTab(
      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
      activeIcon: CupertinoIcons.person_crop_circle_badge_checkmark,
      label: 'Attendance',
    ),
    const NavTab(
      icon: CupertinoIcons.antenna_radiowaves_left_right,
      activeIcon: CupertinoIcons.dot_radiowaves_left_right,
      label: 'NFC',
    ),
    NavTab(
      icon: CupertinoIcons.bell,
      activeIcon: CupertinoIcons.bell_fill,
      label: 'Alerts',
      badgeCount: showAlertsDot ? 1 : 0,
    ),
    const NavTab(
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'Reports',
    ),
    const NavTab(
      icon: CupertinoIcons.calendar,
      activeIcon: CupertinoIcons.calendar_today,
      label: 'Schedule',
    ),
    const NavTab(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Profile',
    ),
  ];
}

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
  if (p == Routes.userProfile.path) return 7;
  if (p == Routes.getNotifications.path) return 4;
  if (p.startsWith(Routes.tickets.path) ||
      p.startsWith(Routes.manageTickets.path)) {
    return 1;
  }
  if (p == Routes.navAttendance.path) return 2;
  if (p == Routes.navReports.path) return 5;
  if (p == Routes.navSchedule.path) return 6;
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
      context.go(Routes.navAttendance.path);
      break;
    case 3:
      context.push(Routes.nfcMapping.path);
      break;
    case 4:
      context.go(Routes.getNotifications.path);
      break;
    case 5:
      context.go(Routes.navReports.path);
      break;
    case 6:
      context.go(Routes.navSchedule.path);
      break;
    case 7:
      context.go(Routes.userProfile.path);
      break;
  }
}

/// Hides platform overscroll indicators for the horizontal tab strip.
class _GlassNavScrollBehavior extends ScrollBehavior {
  const _GlassNavScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// Floating iOS-style glass pill navigation (horizontally scrollable tabs).
class AppGlassNavBar extends StatefulWidget {
  const AppGlassNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<AppGlassNavBar> createState() => _AppGlassNavBarState();
}

class _AppGlassNavBarState extends State<AppGlassNavBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index) {
    if (!_scrollController.hasClients) return;
    final clampedIndex = index.clamp(0, widget.tabs.length - 1);
    const horizontalPadding = AppSpacing.sm;
    final viewport = _scrollController.position.viewportDimension;
    final target = horizontalPadding +
        clampedIndex * kGlassNavTabItemWidth +
        kGlassNavTabItemWidth / 2 -
        viewport / 2;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      target.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(AppGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected(widget.currentIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = scheme.primary;

    final clampedIndex =
        widget.currentIndex.clamp(0, widget.tabs.length - 1).toInt();

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
          child: ScrollConfiguration(
            behavior: const _GlassNavScrollBehavior(),
            child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.tabs.length, (i) {
                    final tab = widget.tabs[i];
                    final selected = i == clampedIndex;
                    final showDot = tab.badgeCount > 0;

                    return SizedBox(
                      width: kGlassNavTabItemWidth,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.onTap(i);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToSelected(i);
                          });
                        },
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
                              if (showDot)
                                Positioned(
                                  right: 6,
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
        ),
      ),
    );
  }
}

/// Shell navigation bar wired to [GoRouter], ticket list state, and auth alerts.
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

        return BlocBuilder<TicketsCubit, TicketsState>(
          bloc: locator<TicketsCubit>(),
          buildWhen: (prev, next) =>
              next is TicketsLoadingSuccess ||
              next is TicketsLoading ||
              next is TicketsLoadingError,
          builder: (context, ticketState) {
            final ticketsBadgeTotal = ticketState is TicketsLoadingSuccess
                ? (ticketState.tickets.data?.length ?? 0)
                : 0;

            final tabs = buildGlassNavTabs(
              ticketsBadgeTotal: ticketsBadgeTotal,
              showAlertsDot: user.notificationCount > 0,
            );

            return AppGlassNavBar(
              tabs: tabs,
              currentIndex: index,
              onTap: (i) => glassShellOnTabTap(context, i),
            );
          },
        );
      },
    );
  }
}
