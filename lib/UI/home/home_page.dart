import 'package:admin_app/UI/employee/attendance/cubit/attendance_cubit.dart';
import 'package:admin_app/UI/home/components/home_drawer.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/UI/home/utils/home_attendance_summary.dart';
import 'package:admin_app/UI/home/utils/menu_route_helper.dart';
import 'package:admin_app/UI/home/widgets/attendance_hero_card.dart';
import 'package:admin_app/UI/home/widgets/dashboard_home_header.dart';
import 'package:admin_app/UI/home/widgets/home_dashboard_models.dart';
import 'package:admin_app/UI/home/widgets/home_dashboard_shimmer.dart';
import 'package:admin_app/UI/home/widgets/module_card.dart';
import 'package:admin_app/UI/home/widgets/recent_activity_feed.dart';
import 'package:admin_app/UI/home/widgets/wide_card.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/routes/shell_route_observer.dart';
import 'package:admin_app/core/widgets/app_badge.dart';
import 'package:admin_app/core/widgets/app_dialogs.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_section_header.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/features/attendance/utils/attendance_permissions_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

({TodayAttendanceSummary today, MonthlyAttendanceSummary month})
_attendanceDashboardPlaceholder() {
  return (
    today: const TodayAttendanceSummary(),
    month: const MonthlyAttendanceSummary(
      percentage: 0,
      absences: 0,
      presentDays: 0,
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _scheduledMarkAttendancePermissionIntro = false;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      shellRouteObserver.unsubscribe(this);
      shellRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    shellRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    final now = DateTime.now();
    context.read<AttendanceCubit>().getAttendance(
      month: now.month,
      year: now.year,
    );
  }

  Future<void> _fetchMenu() async {
    await context.read<HomeCubit>().getMenu();
  }

  Future<void> _refreshHomeDashboard() async {
    final now = DateTime.now();
    await context.read<AttendanceCubit>().getAttendance(
      month: now.month,
      year: now.year,
    );
    await _fetchMenu();
  }

  Future<void> _maybeMarkAttendancePermissionIntro() async {
    if (!mounted) return;
    if (await AttendancePermissionsPrefs.isIntroCompleted()) return;
    if (await areMarkAttendancePermissionsGranted()) {
      await AttendancePermissionsPrefs.setIntroCompleted();
      return;
    }
    if (!mounted) return;

    final go = await showAppConfirmDialog(
      context: context,
      title: 'Mark Attendance',
      message:
          'Location and camera are used to confirm you are on campus and to verify '
          'your identity. You can enable them now, or later from Mark attendance in the menu.',
      confirmLabel: 'Continue',
      cancelLabel: 'Not now',
    );

    if (!mounted) return;
    if (go == true) {
      await requestMarkAttendancePermissions();
    }
    await AttendancePermissionsPrefs.setIntroCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (msg) => AppToast.error(context, msg),
          success: (_) {
            if (_scheduledMarkAttendancePermissionIntro) return;
            _scheduledMarkAttendancePermissionIntro = true;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _maybeMarkAttendancePermissionIntro();
              }
            });
          },
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: HomeDrawer(scaffoldKey: _scaffoldKey),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.when(
              initial: () => const HomeDashboardShimmer(),
              loading: () => const HomeDashboardShimmer(),
              error: (message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppErrorState.generic(
                    message: message,
                    onRetry: _fetchMenu,
                  ),
                ),
              ),
              success: (menus) => _HomeDashboardView(
                menus: menus,
                onRefresh: _refreshHomeDashboard,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeDashboardView extends StatefulWidget {
  const _HomeDashboardView({required this.menus, required this.onRefresh});

  final List<MenuModel> menus;
  final Future<void> Function() onRefresh;

  @override
  State<_HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<_HomeDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final now = DateTime.now();
      context.read<AttendanceCubit>().getAttendance(
        month: now.month,
        year: now.year,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activities = demoDashboardActivities().take(5).toList();
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: scheme.primary,
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm + 6,
                AppSpacing.sm,
                AppSpacing.sm + 6,
                AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const DashboardHomeHeader(),
                  const Gap(AppSpacing.md),
                  BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, attendanceState) {
                      final now = DateTime.now();
                      final bundle = attendanceState.when(
                        initial: _attendanceDashboardPlaceholder,
                        loading: _attendanceDashboardPlaceholder,
                        loadingSuccess: (list) =>
                            buildAttendanceDashboardSummaries(list, now),
                        laodingFailure: (_) =>
                            _attendanceDashboardPlaceholder(),
                      );
                      return AttendanceHeroCard(
                        todayAttendance: bundle.today,
                        monthlyStats: bundle.month,
                      );
                    },
                  ),
                  const Gap(AppSpacing.md + 4),
                  const AppSectionHeader(
                    title: 'Attendance',
                    padding: EdgeInsets.zero,
                  ),
                  const Gap(AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ModuleCard(
                          iconBg: const Color(0xFFE8EAF6),
                          iconData: CupertinoIcons.calendar,
                          iconColor: const Color(0xFF3949AB),
                          title: 'Attendance',
                          subtitle: 'View full history',
                          onTap: () => pushMenuPage(
                            context,
                            widget.menus,
                            Routes.userAttendance.name,
                            'Attendance',
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: ModuleCard(
                          iconBg: const Color(0xFFE8F5E9),
                          iconData: CupertinoIcons
                              .person_crop_circle_badge_checkmark,
                          iconColor: const Color(0xFF2E7D32),
                          title: 'Mark Attendance',
                          subtitle: 'Face + location',
                          badge: const AppBadge.success(label: 'Ready'),
                          onTap: () => pushMenuPage(
                            context,
                            widget.menus,
                            Routes.faceAttendance.name,
                            'Mark attendance',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.md + 4),
                  AppSectionHeader(
                    title: 'Tickets',
                    actionLabel: 'See all',
                    padding: EdgeInsets.zero,
                    onAction: () => context.go(Routes.tickets.path),
                  ),
                  const Gap(AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ModuleCard(
                          iconBg: const Color(0xFFFFF3E0),
                          iconData: CupertinoIcons.doc_text,
                          iconColor: const Color(0xFFE65100),
                          title: 'Manage Tickets',
                          subtitle: 'All staff tickets',
                          onTap: () => context.go(Routes.manageTickets.path),
                        ),
                      ),
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: ModuleCard(
                          iconBg: const Color(0xFFF3E5F5),
                          iconData: CupertinoIcons.checkmark_circle,
                          iconColor: const Color(0xFF7B1FA2),
                          title: 'My Tickets',
                          subtitle: 'Raised by you',
                          onTap: () => context.go(Routes.tickets.path),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.md + 4),
                  const AppSectionHeader(
                    title: 'Tools',
                    padding: EdgeInsets.zero,
                  ),
                  const Gap(AppSpacing.sm),
                  WideCard(
                    iconBg: const Color(0xFFE0F7FA),
                    iconData: CupertinoIcons.radiowaves_right,
                    iconColor: const Color(0xFF00838F),
                    title: 'NFC Mapping',
                    subtitle: 'Configure NFC tags & access points',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        'Admin',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3949AB),
                        ),
                      ),
                    ),
                    onTap: () => context.push(Routes.nfcMapping.path),
                  ),
                  const Gap(AppSpacing.sm),
                  WideCard(
                    iconBg: const Color(0xFFE8EAF6),
                    iconData: CupertinoIcons.person,
                    iconColor: const Color(0xFF3949AB),
                    title: 'Profile',
                    subtitle: 'Edit info, change password',
                    trailing: Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.26),
                    ),
                    onTap: () => context.go(Routes.userProfile.path),
                  ),
                  const Gap(AppSpacing.md + 4),
                  const AppSectionHeader(
                    title: 'Recent Activity',
                    padding: EdgeInsets.zero,
                  ),
                  const Gap(AppSpacing.sm),
                  RecentActivityFeed(activities: activities),
                  const Gap(AppSpacing.xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
