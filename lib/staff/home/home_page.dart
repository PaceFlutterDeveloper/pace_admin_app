import 'dart:async';

import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/routes/shell_route_observer.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/events/presentation/today_events_cubit.dart';
import 'package:admin_app/staff/events/presentation/today_events_section.dart';
import 'package:admin_app/staff/tasks/presentation/my_tasks_section.dart';
import 'package:admin_app/staff/tasks/presentation/tasks_cubit.dart';
import 'package:admin_app/staff/home/cubit/home_cubit.dart';
import 'package:admin_app/staff/home/menu/staff_menu_catalog.dart';
import 'package:admin_app/staff/home/menu/staff_menu_tile.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/utils/active_staff_user.dart';
import 'package:admin_app/staff/home/utils/home_attendance_summary.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/home/widgets/attendance_hero_card.dart';
import 'package:admin_app/staff/home/widgets/dashboard_home_header.dart';
import 'package:admin_app/staff/home/widgets/home_dashboard_models.dart';
import 'package:admin_app/staff/home/widgets/home_sections.dart';
import 'package:admin_app/staff/session/staff_session_service.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

/// Staff home: header, attendance hero, quick stats and tasks.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final TodayEventsCubit _events = locator<TodayEventsCubit>();
  final TasksCubit _tasks = locator<TasksCubit>();
  final DashboardCubit _dashboard = locator<DashboardCubit>();
  String _sessionUser = '';

  @override
  void initState() {
    super.initState();
    _sessionUser = activeStaffKey();
    staffSessionListenable().addListener(_onSession);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAll();
      unawaited(locator<StaffSessionService>().registerDevice());
    });
  }

  /// Home stays alive under other routes. When the signed-in account changes,
  /// reload instead of keeping the previous person's home on screen.
  void _onSession() {
    if (!mounted) return;
    final next = activeStaffKey();
    if (next == _sessionUser) return;
    _sessionUser = next;
    if (activeStaffUser().userId.isEmpty) return;
    _loadAll(force: true);
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
    staffSessionListenable().removeListener(_onSession);
    shellRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// The hero reads the summary, so coming back refreshes that.
  @override
  void didPopNext() {
    if (!mounted) return;
    unawaited(_dashboard.load());
  }

  /// Summary, menu, tasks, and today's events. The attendance month loads
  /// on that screen. Data that is still fresh stays on screen.
  Future<void> _loadAll({bool force = false}) async {
    final home = context.read<HomeCubit>();
    await Future.wait([
      if (force || !_events.isFresh) _events.load(quiet: true),
      if (force || !_tasks.isFresh) _tasks.load(quiet: true),
      if (force || !home.isFresh) home.getMenu(quiet: true),
      if (force || !_dashboard.isFresh) _dashboard.load(),
    ]);
  }

  List<MenuModel> _menus() {
    return context.read<HomeCubit>().state.maybeWhen(
      success: (m) => m,
      orElse: () => const <MenuModel>[],
    );
  }

  void _open(String page, String fallbackName) {
    pushMenuPage(context, _menus(), page, fallbackName);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;

    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        state.whenOrNull(error: (msg) => AppToast.error(context, msg));
      },
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: p.amberText,
          backgroundColor: p.surface,
          onRefresh: () => _loadAll(force: true),
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const DashboardHomeHeader(),
              BlocBuilder<DashboardCubit, StaffDashboard?>(
                bloc: _dashboard,
                builder: (context, dashboard) {
                  return BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, attendanceState) {
                      final server = dashboard?.attendance;
                      final bundle = server != null
                          ? summariesFromDashboard(server, DateTime.now())
                          : attendanceState.when(
                              initial: _attendanceDashboardPlaceholder,
                              loading: _attendanceDashboardPlaceholder,
                              loadingSuccess: (list) =>
                                  buildAttendanceDashboardSummaries(
                                    list,
                                    DateTime.now(),
                                  ),
                              laodingFailure: (_) =>
                                  _attendanceDashboardPlaceholder(),
                            );
                      return AttendanceHeroCard(
                        todayAttendance: bundle.today,
                        monthlyStats: bundle.month,
                        onStats: () =>
                            _open(Routes.userAttendance.name, 'Attendance'),
                      );
                    },
                  );
                },
              ),
              BlocBuilder<DashboardCubit, StaffDashboard?>(
                bloc: _dashboard,
                builder: (context, dashboard) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: QuickStatCard(
                              glyph: StaffGlyphs.tasks,
                              accent: StaffAccent.blue,
                              label: 'Tasks due',
                              value: dashboard?.tasksDueToday?.toString(),
                              onTap: () => context.push(Routes.tasks.path),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: QuickStatCard(
                              glyph: StaffGlyphs.clock,
                              accent: StaffAccent.pink,
                              label: 'Overdue',
                              value: dashboard?.tasksOverdue?.toString(),
                              onTap: () => context.push(Routes.tasks.path),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: QuickStatCard(
                              glyph: StaffGlyphs.mega,
                              accent: StaffAccent.amber,
                              label: 'Notices',
                              value:
                                  (dashboard?.unreadNotices ?? 0).toString(),
                              onTap: () =>
                                  context.pushNamed(Routes.notices.name),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((dashboard?.approvalsPending ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: _ApprovalsBanner(
                          count: dashboard!.approvalsPending!,
                          onTap: () => context.pushNamed(Routes.approvals.name),
                        ),
                      ),
                  ],
                ),
              ),
              BlocProvider.value(
                value: _events,
                child: const TodayEventsSection(),
              ),
              SectionHeader(
                title: 'Quick access',
                action: 'See all',
                onAction: () => context.push(Routes.menu.path),
              ),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) => state.maybeWhen(
                  success: (menus) {
                    final live = [
                      for (final group in buildStaffMenu(menus))
                        ...group.items.where((entry) => !entry.isSoon),
                    ].take(4);
                    if (live.isEmpty) return const SizedBox.shrink();
                    return QuickAccessCard(
                      tiles: [
                        for (final e in live)
                          StaffMenuTile(
                            label: e.label,
                            glyph: e.style.glyph,
                            accent: e.style.accent,
                            iconUrl: e.iconUrl,
                            onTap: () => openStaffMenu(context, e.menu!),
                          ),
                      ],
                    );
                  },
                  error: (_) => const SizedBox.shrink(),
                  orElse: () => const QuickAccessSkeleton(),
                ),
              ),
              BlocProvider.value(value: _tasks, child: const MyTasksSection()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown on Home only for approvers with something waiting.
class _ApprovalsBanner extends StatelessWidget {
  const _ApprovalsBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const GlassIconTile(
            glyph: StaffGlyphs.check,
            accent: StaffAccent.amber,
            size: 36,
            radius: 12,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? '1 approval waiting for you'
                  : '$count approvals waiting for you',
              style: sora(13, weight: FontWeight.w600, color: p.text),
            ),
          ),
          StaffIcon(StaffGlyphs.chevronRight, size: 18, color: p.muted),
        ],
      ),
    );
  }
}
