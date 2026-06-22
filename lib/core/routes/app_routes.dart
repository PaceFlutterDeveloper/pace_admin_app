import 'dart:developer';

import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/auth/login_page.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/auth/users_page.dart';
import 'package:admin_app/UI/class_attendance/page/grade_attendance_page.dart';
import 'package:admin_app/UI/components/scaffold_with_navbar.dart';
import 'package:admin_app/UI/employee/attendance/page/emp_attendance_page.dart';
import 'package:admin_app/UI/employee/profile/page/profile_page.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_event.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/pages/manage_ticket_detail_page.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/pages/manage_ticket_list_page.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/pages/ticket_detail_page.dart';
import 'package:admin_app/UI/employee/tickets/tickets/pages/ticket_listing_page.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/page/page.dart';
import 'package:admin_app/UI/home/components/sub_menu_page.dart';
import 'package:admin_app/UI/home/home_page.dart';
import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/UI/notification/cubit/notification_cubit.dart';
import 'package:admin_app/UI/notification/page/notification_page.dart';
import 'package:admin_app/UI/profile/components/update_password_page.dart';
import 'package:admin_app/UI/public/application/bloc/application_bloc.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/UI/public/jobs/pages/job_detail_page.dart';
import 'package:admin_app/UI/public/jobs/pages/jobs_page.dart';
import 'package:admin_app/UI/public/jobs/services/jobs_api_service.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/complete_profile_page.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/students/pages/students_page.dart';
import 'package:admin_app/core/routes/shell_route_observer.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/go_router_refresh_stream.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/features/attendance/presentation/pages/attendance_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

final List<String> globalPaths = [
  Routes.home.path,
  Routes.root.path,
  Routes.getNotifications.path,
  Routes.userProfile.path,
  Routes.updatePassword.path,
];
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRoute {
  static late BuildContext context;

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.careers.path,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(context.watch<AuthCubit>().stream),
    routes: [
      GoRoute(
        path: Routes.root.path,
        name: Routes.root.name,
        redirect: (_, __) => Routes.careers.path,
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        observers: [shellRouteObserver],
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: Routes.home.path,
            name: Routes.home.name,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.navAttendance.path,
            name: Routes.navAttendance.name,
            builder: (context, _) => Scaffold(
              body: Center(
                child: Text(
                  'Attendance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          GoRoute(
            path: Routes.navReports.path,
            name: Routes.navReports.name,
            builder: (context, _) => Scaffold(
              body: Center(
                child: Text(
                  'Reports',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          GoRoute(
            path: Routes.navSchedule.path,
            name: Routes.navSchedule.name,
            builder: (context, _) => Scaffold(
              body: Center(
                child: Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          GoRoute(
            path: Routes.getNotifications.path,
            name: Routes.getNotifications.name,
            builder: (_, __) => BlocProvider.value(
              value: locator<NotificationCubit>()..fetchNotifications(),
              child: const NotificationPage(),
            ),
          ),
          GoRoute(
            path: Routes.subMenuPage.path,
            name: Routes.subMenuPage.name,
            builder: (context, state) {
              final menuModel = state.extra as MenuModel;

              return SubMenuPage(menuModel: menuModel);
            },
          ),
          GoRoute(
            path: Routes.userProfile.path,
            name: Routes.userProfile.name,
            builder: (context, state) {
              final menuModel = state.extra is MenuModel
                  ? state.extra as MenuModel
                  : null;

              return ProfilePage(appTitle: menuModel?.menuName ?? 'My Profile');
            },
          ),
          GoRoute(
            path: Routes.classAttendance.path,
            name: Routes.classAttendance.name,
            builder: (context, state) {
              final menuModel = state.extra as MenuModel;
              return GradeAttendanceScreen(appTitle: menuModel.menuName);
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
                  return ManageTicketDetailPage(
                    ticketId: int.parse(_t),
                    isPushNotification: data['isPushNotification'] as bool,
                  );
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
                  return TicketDetailPage(
                    ticketId: int.parse(_t),
                    isPushNotification: data['isPushNotification'] as bool,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.students.path,
            name: Routes.students.name,
            builder: (context, state) {
              final grade = state.uri.queryParameters['grade'] ?? '';
              final section =
                  state.uri.queryParameters['section'] ??
                  ''; // Ensure key matches
              final title = state.uri.queryParameters['title'] ?? 'Students';

              if (grade.isEmpty || section.isEmpty) {
                return const Center(child: Text("Invalid student data"));
              }

              return StudentsPage(
                grade: grade,
                section: section,
                appTitle: title,
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
      // Jobs Shell Route - child pages own their Scaffold/AppBar
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: Routes.careers.path,
            name: Routes.careers.name,
            builder: (context, state) {
              final tabParam = state.uri.queryParameters['tab'];
              var initialTab = 0;
              if (tabParam == 'applications') initialTab = 1;
              if (tabParam == 'profile') initialTab = 2;

              final apiService = locator<ApiService>();
              final jobsApiService = JobsApiService(apiService: apiService);
              final token = locator<CareersUserService>()
                  .getCurrentCareersUser()
                  ?.sessionToken;

              return MultiBlocProvider(
                providers: [
                  BlocProvider<JobsBloc>(
                    create: (_) => JobsBloc(
                      jobsApiService: jobsApiService,
                      token: token,
                    ),
                  ),
                  BlocProvider<ApplicationBloc>(
                    create: (_) => locator<ApplicationBloc>(),
                  ),
                  BlocProvider<CareersProfileBloc>(
                    create: (_) => locator<CareersProfileBloc>(),
                  ),
                ],
                child: JobsPage(initialTabIndex: initialTab),
              );
            },
          ),
          GoRoute(
            path: Routes.jobDetail.path,
            name: Routes.jobDetail.name,
            builder: (context, state) {
              final jobId = state.extra as int;
              final apiService = locator<ApiService>();
              final jobsApiService = JobsApiService(apiService: apiService);
              final token = locator<CareersUserService>()
                  .getCurrentCareersUser()
                  ?.sessionToken;

              return MultiBlocProvider(
                providers: [
                  BlocProvider<JobsBloc>(
                    create: (_) => JobsBloc(
                      jobsApiService: jobsApiService,
                      token: token,
                    ),
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
        builder: (_, __) => UpdatePasswordScreen(),
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
        builder: (_, __) => const UsersPage(),
      ),
      GoRoute(
        path: Routes.nfcMapping.path,
        name: Routes.nfcMapping.name,
        builder: (_, __) => const NfcMapyScreen(),
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

      // Case 1: Admin login is hidden — always land on careers instead
      if (state.matchedLocation == Routes.loginPage.path) {
        log("Admin login is hidden. Redirecting to careers.");
        return Routes.careers.path;
      }

      // Case 1.5: Allow direct access to Jobs-related pages for non-logged-in users
      if (state.matchedLocation == Routes.careers.path ||
          state.matchedLocation.startsWith(Routes.jobDetail.path) ||
          state.matchedLocation.startsWith(Routes.careersProfile.path) ||
          state.matchedLocation.startsWith(
            Routes.careersCompleteProfile.path,
          )) {
        log("Accessing Jobs page, allowing access for all users.");
        return null;
      }
      if (!hasActiveUser && loginBox.values.isNotEmpty) {
        log("No active user found. users is existing.");
        return Routes.usersPage.path;
      }
      // Case 2: Unauthenticated users see careers instead of admin login
      if (!hasActiveUser) {
        log("No active user found. Redirecting to careers.");
        return Routes.careers.path;
      }

      // Case 3: Root always opens careers
      if (state.matchedLocation == Routes.root.path) {
        log("Redirecting from root to careers.");
        return Routes.careers.path;
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
  updatePassword("/updatePassword"),
  classAttendance('/classAttendance'),
  students('/students'),
  manageTickets('/manageTickets'),
  manageTicketDetailPage('/manageTicketDetailPage'),
  tickets('/tickets'),
  ticketDetailPage('/ticketDetailPage'),
  nfcMapping("/nfcMapping"),
  careers('/careers'),
  jobDetail('/job-detail'),
  careersProfile('/careers-profile'),
  careersCompleteProfile('/careers-complete-profile'),
  // employee pages
  userAttendance('/userAttendance'),

  /// Face + geofence check-in (new). Legacy calendar stays on [userAttendance].
  faceAttendance('/faceAttendance'),

  /// Bottom-nav placeholders (scrollable shell tabs).
  navAttendance('/navAttendance'),
  navReports('/navReports'),
  navSchedule('/navSchedule');

  final String path;

  const Routes(this.path);
}
