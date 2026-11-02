import 'dart:developer';

import 'package:admin_app/staff/auth/cubit/auth_cubit.dart';
import 'package:admin_app/staff/auth/login_page.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/auth/users_page.dart';
import 'package:admin_app/staff/class_attendance/page/grade_attendance_page.dart';
import 'package:admin_app/staff/shell/staff_shell.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/home/menu/staff_menu_page.dart';
import 'package:admin_app/staff/events/presentation/events_page.dart';
import 'package:admin_app/staff/home/pages/staff_coming_soon_page.dart';
import 'package:admin_app/staff/tasks/presentation/tasks_page.dart';
import 'package:admin_app/staff/attendance_calendar/page/emp_attendance_page.dart';
import 'package:admin_app/staff/profile/page/profile_page.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/list/manage_ticket_list_event.dart';
import 'package:admin_app/staff/tickets/manage_tickets/pages/manage_ticket_detail_page.dart';
import 'package:admin_app/staff/tickets/manage_tickets/pages/manage_ticket_list_page.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/pages/ticket_detail_page.dart';
import 'package:admin_app/staff/tickets/tickets/pages/ticket_listing_page.dart';
import 'package:admin_app/staff/transport/nfc_mappy/page/page.dart';
import 'package:admin_app/staff/home/components/sub_menu_page.dart';
import 'package:admin_app/staff/internal_web/presentation/internal_web_page.dart';
import 'package:admin_app/staff/home/home_page.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/notification/cubit/notification_cubit.dart';
import 'package:admin_app/staff/notification/page/notification_page.dart';
import 'package:admin_app/staff/account/components/update_password_page.dart';
import 'package:admin_app/staff/leave/presentation/leave_page.dart';
import 'package:admin_app/staff/approvals/presentation/approvals_page.dart';
import 'package:admin_app/staff/notices/presentation/notices_page.dart';
import 'package:admin_app/staff/directory/presentation/directory_page.dart';
import 'package:admin_app/staff/timetable/presentation/timetable_page.dart';
import 'package:admin_app/staff/reports/presentation/reports_page.dart';
import 'package:admin_app/staff/notification_settings/presentation/notification_settings_page.dart';
import 'package:admin_app/staff/sessions/presentation/login_sessions_page.dart';
import 'package:admin_app/careers/application/bloc/application_bloc.dart';
import 'package:admin_app/careers/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/careers/jobs/pages/job_detail_page.dart';
import 'package:admin_app/careers/jobs/pages/jobs_page.dart';
import 'package:admin_app/careers/jobs/services/jobs_api_service.dart';
import 'package:admin_app/careers/shared/theme/careers_theme.dart';
import 'package:admin_app/careers/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/careers/user/services/careers_user_service.dart';
import 'package:admin_app/careers/user/pages/complete_profile/complete_profile_page.dart';
import 'package:admin_app/staff/students/pages/students_page.dart';
import 'package:admin_app/core/routes/shell_route_observer.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/dismiss_keyboard.dart';
import 'package:admin_app/core/update/app_update_controller.dart';
import 'package:admin_app/core/utils/go_router_refresh_stream.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/face_attendance/presentation/pages/attendance_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

const _signedInSurfaceKey = 'signedInSurface';

bool _hasActiveStaff() {
  return locator<Box<AuthModel>>().values.any((login) => login.isActive);
}

/// Staff home when that session is still active. Careers when a candidate is
/// the latest session, or when nobody is signed in.
String _resumeLocation() {
  final surface = Hive.box('settingsBox').get(_signedInSurfaceKey) as String?;
  final candidate = locator<CareersUserService>().isCareersUserLoggedIn();
  if (surface == 'careers' && candidate) return Routes.careers.path;
  if (_hasActiveStaff()) return Routes.home.path;
  return Routes.careers.path;
}

/// Staff launches stay off the careers jobs API. Careers still uses it for
/// the minimum app version when the jobs list has not loaded yet.
bool opensStaffHome() => _resumeLocation() == Routes.home.path;

final List<String> globalPaths = [
  Routes.home.path,
  Routes.root.path,
  Routes.getNotifications.path,
  Routes.userProfile.path,
  Routes.updatePassword.path,
];
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Shows the admin login over careers without changing the route.
/// The careers shell and the root navigator share keys, so a route change
/// between them throws a duplicate GlobalKey error.
final ValueNotifier<bool> secretAdminLoginOpen = ValueNotifier(false);
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

JobsApiService _careersJobsApiService() {
  return JobsApiService(
    apiService: locator<ApiService>(),
    onJobsPayload: locator<AppUpdateController>().evaluate,
  );
}

int? _jobIdFromGoState(GoRouterState state) {
  final extra = state.extra;
  if (extra is int) return extra;
  if (extra is String) return int.tryParse(extra);
  return int.tryParse(state.uri.queryParameters['job_id'] ?? '');
}

/// How long a dock destination takes to fade in.
const Duration _staffTabFade = Duration(milliseconds: 220);

/// Dock destinations, and the transparent drill-downs (notification centre,
/// sub menus), fade through: the previous tab fades out in the first
/// part of the transition, then the new tab fades in. The staff pages are
/// transparent over the shell backdrop, so a plain fade-in or slide would show
/// both tabs merged on top of each other.
Page<void> _staffFadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: _staffTabFade,
    transitionsBuilder: (context, animation, secondaryAnimation, page) {
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.4, 1, curve: Curves.easeOut),
      );
      final fadeOut = ReverseAnimation(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0, 0.4, curve: Curves.easeIn),
        ),
      );
      return FadeTransition(
        opacity: fadeOut,
        child: FadeTransition(opacity: fadeIn, child: page),
      );
    },
  );
}

/// Screen title: the API menu name when the page was opened from the menu.
String _menuTitle(GoRouterState state, String fallback) {
  final extra = state.extra;
  if (extra is MenuModel && extra.menuName.trim().isNotEmpty) {
    return extra.menuName.trim();
  }
  return fallback;
}

class AppRoute {
  static late BuildContext context;

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _resumeLocation(),
    observers: [DismissKeyboardNavigatorObserver()],
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(context.watch<AuthCubit>().stream),
    routes: [
      GoRoute(
        path: Routes.root.path,
        name: Routes.root.name,
        redirect: (_, __) => _resumeLocation(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        observers: [shellRouteObserver, DismissKeyboardNavigatorObserver()],
        builder: (context, state, child) {
          return StaffTheme.wrap(StaffShell(child: child));
        },
        routes: [
          GoRoute(
            path: Routes.home.path,
            name: Routes.home.name,
            pageBuilder: (_, state) =>
                _staffFadePage(state, const HomeScreen()),
          ),
          GoRoute(
            path: Routes.menu.path,
            name: Routes.menu.name,
            pageBuilder: (_, state) =>
                _staffFadePage(state, const StaffMenuPage()),
          ),
          GoRoute(
            path: Routes.tasks.path,
            name: Routes.tasks.name,
            pageBuilder: (_, state) => _staffFadePage(state, const TasksPage()),
          ),
          GoRoute(
            path: Routes.events.path,
            name: Routes.events.name,
            pageBuilder: (_, state) =>
                _staffFadePage(state, const EventsPage()),
          ),
          GoRoute(
            path: Routes.leave.path,
            name: Routes.leave.name,
            builder: (_, state) => LeavePage(title: _menuTitle(state, 'Leave')),
          ),
          GoRoute(
            path: Routes.approvals.path,
            name: Routes.approvals.name,
            builder: (_, state) =>
                ApprovalsPage(title: _menuTitle(state, 'Approvals')),
          ),
          GoRoute(
            path: Routes.circulars.path,
            name: Routes.circulars.name,
            builder: (_, state) =>
                NoticesPage(title: _menuTitle(state, 'Circulars')),
          ),
          // Legacy menu page key from older API builds.
          GoRoute(
            path: Routes.notices.path,
            name: Routes.notices.name,
            builder: (_, state) =>
                NoticesPage(title: _menuTitle(state, 'Circulars')),
          ),
          GoRoute(
            path: Routes.staff.path,
            name: Routes.staff.name,
            builder: (_, state) =>
                DirectoryPage(title: _menuTitle(state, 'Staff')),
          ),
          GoRoute(
            path: Routes.timetable.path,
            name: Routes.timetable.name,
            builder: (_, state) =>
                TimetablePage(title: _menuTitle(state, 'Timetable')),
          ),
          GoRoute(
            path: Routes.reports.path,
            name: Routes.reports.name,
            builder: (_, state) =>
                ReportsPage(title: _menuTitle(state, 'Reports')),
          ),
          GoRoute(
            path: Routes.notificationSettings.path,
            name: Routes.notificationSettings.name,
            builder: (_, state) => NotificationSettingsPage(
              title: _menuTitle(state, 'Notification settings'),
            ),
          ),
          GoRoute(
            path: Routes.loginSessions.path,
            name: Routes.loginSessions.name,
            builder: (_, __) => const LoginSessionsPage(),
          ),
          GoRoute(
            path: Routes.comingSoon.path,
            name: Routes.comingSoon.name,
            builder: (_, state) => StaffComingSoonPage(
              args: state.extra is ComingSoonArgs
                  ? state.extra as ComingSoonArgs
                  : ComingSoonArgs.settings,
            ),
          ),
          GoRoute(
            path: Routes.getNotifications.path,
            name: Routes.getNotifications.name,
            pageBuilder: (_, state) => _staffFadePage(
              state,
              BlocProvider.value(
                value: locator<NotificationCubit>()..fetchNotifications(),
                child: const NotificationPage(),
              ),
            ),
          ),
          GoRoute(
            path: Routes.subMenuPage.path,
            name: Routes.subMenuPage.name,
            pageBuilder: (context, state) {
              final menuModel = state.extra as MenuModel;

              return _staffFadePage(state, SubMenuPage(menuModel: menuModel));
            },
          ),
          GoRoute(
            path: Routes.internalWeb.path,
            name: Routes.internalWeb.name,
            pageBuilder: (_, state) {
              final menu = state.extra is MenuModel
                  ? state.extra as MenuModel
                  : MenuModel(
                      id: '0',
                      menuKey: 'internalWeb',
                      menuVal: '',
                      menuName: '',
                      page: null,
                      iconUrl: '',
                      parentId: '',
                      subMenu: const [],
                    );
              return _staffFadePage(state, InternalWebPage(menu: menu));
            },
          ),
          GoRoute(
            path: Routes.userProfile.path,
            name: Routes.userProfile.name,
            pageBuilder: (context, state) {
              final menuModel = state.extra is MenuModel
                  ? state.extra as MenuModel
                  : null;

              return _staffFadePage(
                state,
                ProfilePage(appTitle: menuModel?.menuName ?? 'My Profile'),
              );
            },
          ),
          GoRoute(
            path: Routes.classAttendance.path,
            name: Routes.classAttendance.name,
            pageBuilder: (context, state) {
              final menuModel = state.extra as MenuModel;
              return _staffFadePage(
                state,
                GradeAttendanceScreen(appTitle: menuModel.menuName),
              );
            },
          ),
          GoRoute(
            path: Routes.manageTickets.path,
            name: Routes.manageTickets.name,
            // builder: (context, state) => const ManageTicketListPage(),
            builder: (_, __) => BlocProvider.value(
              value: locator<ManageTicketListBloc>()
                ..add(const FetchTicketListEvent()),
              child: const ManageTicketListPage(),
            ),
            routes: [
              GoRoute(
                path: Routes.manageTicketDetailPage.path,
                name: Routes.manageTicketDetailPage.name,
                builder: (context, state) {
                  final data = state.extra as Map<String, dynamic>;
                  String _t = data['ticketId'] as String;
                  return ManageTicketDetailPage(ticketId: int.parse(_t));
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.tickets.path,
            name: Routes.tickets.name,
            builder: (context, state) {
              return BlocProvider(
                create: (_) => TicketsCubit()..fetchTickets(),
                child: const TicketListPage(),
              );
            },
            routes: [
              GoRoute(
                path: Routes.ticketDetailPage.path,
                name: Routes.ticketDetailPage.name,
                builder: (context, state) {
                  final data = state.extra as Map<String, dynamic>;
                  String _t = data['ticketId'] as String;
                  return TicketDetailPage(ticketId: int.parse(_t));
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.students.path,
            name: Routes.students.name,
            pageBuilder: (context, state) {
              final grade = state.uri.queryParameters['grade'] ?? '';
              final section = state.uri.queryParameters['section'] ?? '';
              final title = state.uri.queryParameters['title'] ?? 'Class';
              return _staffFadePage(
                state,
                StudentsPage(grade: grade, section: section, appTitle: title),
              );
            },
          ),
          GoRoute(
            path: Routes.userAttendance.path,
            name: Routes.userAttendance.name,
            builder: (context, state) {
              final menuModel = state.extra as MenuModel;
              return EmpAttendancePage(menuModel: menuModel);
            },
          ),
          GoRoute(
            path: Routes.faceAttendance.path,
            name: Routes.faceAttendance.name,
            builder: (context, state) {
              final menuModel = state.extra as MenuModel;
              return AttendancePage(title: menuModel.menuName);
            },
          ),
        ],
      ),
      // Jobs Shell Route - child pages own their Scaffold/AppBar.
      // The shell only applies the careers design system; admin keeps AppTheme.
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        observers: [DismissKeyboardNavigatorObserver()],
        builder: (context, state, child) => CareersTheme.wrap(child),
        routes: [
          GoRoute(
            path: Routes.careers.path,
            name: Routes.careers.name,
            builder: (context, state) {
              final tabParam = state.uri.queryParameters['tab'];
              var initialTab = 0;
              if (tabParam == 'applications') initialTab = 1;
              if (tabParam == 'profile') initialTab = 2;

              return MultiBlocProvider(
                providers: [
                  BlocProvider<JobsBloc>(
                    create: (_) =>
                        JobsBloc(jobsApiService: _careersJobsApiService()),
                  ),
                  BlocProvider<ApplicationBloc>(
                    create: (_) => locator<ApplicationBloc>(),
                  ),
                  BlocProvider<CareersProfileBloc>(
                    create: (_) => locator<CareersProfileBloc>(),
                  ),
                ],
                child: CareersEntry(initialTabIndex: initialTab),
              );
            },
          ),
          GoRoute(
            path: Routes.jobShare.path,
            name: Routes.jobShare.name,
            redirect: (_, state) {
              final page = state.uri.queryParameters['page'];
              final jobId = state.uri.queryParameters['id'];
              if (jobId == null || int.tryParse(jobId) == null) {
                return Routes.careers.path;
              }
              if (page != null && page != 'job') {
                return Routes.careers.path;
              }
              return '${Routes.jobDetail.path}?job_id=$jobId';
            },
            builder: (_, __) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: Routes.jobDetail.path,
            name: Routes.jobDetail.name,
            redirect: (_, state) {
              if (_jobIdFromGoState(state) == null) {
                return Routes.careers.path;
              }
              return null;
            },
            builder: (context, state) {
              final jobId = _jobIdFromGoState(state)!;

              return MultiBlocProvider(
                providers: [
                  BlocProvider<JobsBloc>(
                    create: (_) =>
                        JobsBloc(jobsApiService: _careersJobsApiService()),
                  ),
                  BlocProvider<ApplicationBloc>(
                    create: (_) => locator<ApplicationBloc>(),
                  ),
                  BlocProvider<CareersProfileBloc>(
                    create: (_) => locator<CareersProfileBloc>(),
                  ),
                ],
                child: JobDetailPage(jobId: jobId),
              );
            },
          ),
          GoRoute(
            path: Routes.careersProfile.path,
            name: Routes.careersProfile.name,
            redirect: (_, __) => '${Routes.careers.path}?tab=profile',
          ),
          GoRoute(
            path: Routes.careersCompleteProfile.path,
            name: Routes.careersCompleteProfile.name,
            builder: (context, state) => BlocProvider<CareersProfileBloc>(
              create: (context) => locator<CareersProfileBloc>(),
              child: const CompleteProfilePage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.updatePassword.path,
        name: Routes.updatePassword.name,
        builder: (_, __) => StaffTheme.wrap(const UpdatePasswordScreen()),
      ),
      GoRoute(
        path: Routes.loginPage.path,
        name: Routes.loginPage.name,
        builder: (_, __) => const LoginPage(),
      ),

      // employee screens/pages
      GoRoute(
        path: Routes.usersPage.path,
        name: Routes.usersPage.name,
        builder: (_, __) => StaffTheme.wrap(const UsersPage()),
      ),
      GoRoute(
        path: Routes.nfcMapping.path,
        name: Routes.nfcMapping.name,
        builder: (_, __) => StaffTheme.wrap(const NfcMapyScreen()),
      ),
    ],
    redirect: (_, GoRouterState state) async {
      // Access the login box to check for active users
      Box<AuthModel> loginBox = locator<Box<AuthModel>>();

      // Log initial navigation request
      log("Redirect function triggered with state: ${state.uri.toString()}");
      log("Current route: ${state.matchedLocation}");

      // Determine if there is an active user
      bool hasActiveUser = loginBox.values.any((login) => login.isActive);

      // Case 1: Admin login is hidden — always land on careers instead.
      if (state.matchedLocation == Routes.loginPage.path) {
        log("Admin login is hidden. Redirecting to careers.");
        return Routes.careers.path;
      }

      // Case 1.5: Allow direct access to Jobs-related pages for non-logged-in users
      if (state.matchedLocation == Routes.careers.path ||
          state.matchedLocation.startsWith(Routes.jobShare.path) ||
          state.matchedLocation.startsWith(Routes.jobDetail.path) ||
          state.matchedLocation.startsWith(Routes.careersProfile.path) ||
          state.matchedLocation.startsWith(
            Routes.careersCompleteProfile.path,
          )) {
        log("Accessing Jobs page, allowing access for all users.");
        return null;
      }
      if (!hasActiveUser && loginBox.values.isNotEmpty) {
        if (state.matchedLocation == Routes.usersPage.path) return null;
        log("No active user found. users is existing.");
        return Routes.usersPage.path;
      }
      // Case 2: Unauthenticated users see careers instead of admin login
      if (!hasActiveUser) {
        log("No active user found. Redirecting to careers.");
        return Routes.careers.path;
      }

      // Case 3: Root resumes the signed-in staff home, otherwise careers.
      if (state.matchedLocation == Routes.root.path) {
        final start = _resumeLocation();
        log("Redirecting from root to $start.");
        return start;
      }

      // Log that access to the route is allowed
      log("Access allowed to route: ${state.matchedLocation}");
      return null;
    },
  );

  AppRoute.setStream(BuildContext ctx) {
    context = ctx;
  }
}

enum Routes {
  root("/"),
  home("/home"),
  usersPage('/usersPage'),
  loginPage("/loginPage"),
  getNotifications("/getNotifications"),
  userProfile("/userProfile"),
  subMenuPage("/subMenuPage"),
  internalWeb("/internalWeb"),
  updatePassword("/updatePassword"),
  classAttendance('/classAttendance'),
  students('/students'),
  manageTickets('/manageTickets'),
  manageTicketDetailPage('/manageTicketDetailPage'),
  tickets('/tickets'),
  ticketDetailPage('/ticketDetailPage'),
  nfcMapping("/nfcMapping"),
  careers('/careers'),
  jobShare('/careers/index.php'),
  jobDetail('/job-detail'),
  careersProfile('/careers-profile'),
  careersCompleteProfile('/careers-complete-profile'),
  // employee pages
  userAttendance('/userAttendance'),

  /// Face + geofence check-in (new). Legacy calendar stays on [userAttendance].
  faceAttendance('/faceAttendance'),

  /// Staff dock destinations and the shared coming-soon page.
  menu('/menu'),
  tasks('/tasks'),
  events('/events'),
  comingSoon('/comingSoon'),

  /// Modules the API menu lists by these page names.
  leave('/leave'),
  approvals('/approvals'),
  circulars('/circulars'),
  notices('/notices'),
  staff('/staff'),
  timetable('/timetable'),
  reports('/reports'),
  notificationSettings('/notificationSettings'),
  loginSessions('/loginSessions');

  final String path;

  const Routes(this.path);
}
