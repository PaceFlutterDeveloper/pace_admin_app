import 'package:admin_app/staff/leave/data/leave_repository_impl.dart';
import 'package:admin_app/staff/leave/domain/leave_repository.dart';
import 'package:admin_app/staff/approvals/data/approvals_repository_impl.dart';
import 'package:admin_app/staff/approvals/domain/approvals_repository.dart';
import 'package:admin_app/staff/notices/data/notices_repository_impl.dart';
import 'package:admin_app/staff/notices/domain/notices_repository.dart';
import 'package:admin_app/staff/directory/data/directory_repository_impl.dart';
import 'package:admin_app/staff/directory/domain/directory_repository.dart';
import 'package:admin_app/staff/timetable/data/timetable_repository_impl.dart';
import 'package:admin_app/staff/timetable/domain/timetable_repository.dart';
import 'package:admin_app/staff/reports/data/reports_repository_impl.dart';
import 'package:admin_app/staff/reports/domain/reports_repository.dart';
import 'package:admin_app/staff/notification_settings/data/notification_settings_repository_impl.dart';
import 'package:admin_app/staff/notification_settings/domain/notification_settings_repository.dart';
import 'package:admin_app/staff/dashboard/data/dashboard_repository_impl.dart';
import 'package:admin_app/staff/dashboard/domain/dashboard_repository.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/events/presentation/events_agenda_cubit.dart';
import 'package:admin_app/staff/events/presentation/today_events_cubit.dart';
import 'package:admin_app/staff/events/data/events_repository_impl.dart';
import 'package:admin_app/staff/events/domain/events_repository.dart';
import 'package:admin_app/staff/tasks/data/tasks_repository_impl.dart';
import 'package:admin_app/staff/tasks/domain/tasks_repository.dart';
import 'package:admin_app/staff/tasks/presentation/tasks_cubit.dart';
import 'package:admin_app/staff/auth/cubit/auth_cubit.dart';
import 'package:admin_app/staff/session/staff_session_service.dart';
import 'package:admin_app/core/services/staff_session_expired_handler.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/auth/repository/auth_repository.dart';
import 'package:admin_app/staff/class_attendance/cubit/grade_attendance_cubit.dart';
import 'package:admin_app/staff/class_attendance/repository/class_attendance_repository.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/attendance_calendar/repository/attendance_repository.dart'
    as legacy_attendance;
import 'package:admin_app/staff/profile/cubit/profile_cubit.dart';
import 'package:admin_app/staff/profile/repository/profile_repository.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/detail/manage_ticket_detail_bloc.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/staff/tickets/manage_tickets/repository/ticket_repository.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/repository/ticket_repository.dart';
import 'package:admin_app/staff/transport/nfc_mappy/repository/repository.dart';
import 'package:admin_app/staff/home/cubit/home_cubit.dart';
import 'package:admin_app/staff/home/repository/home_repository.dart';
import 'package:admin_app/staff/notification/cubit/notification_cubit.dart';
import 'package:admin_app/staff/notification/repository/notification_repository.dart';
import 'package:admin_app/careers/application/bloc/application_bloc.dart';
import 'package:admin_app/careers/application/services/application_api_service.dart';
import 'package:admin_app/careers/shared/theme/careers_theme_controller.dart';
import 'package:admin_app/careers/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/careers/user/bloc/user_bloc.dart';
import 'package:admin_app/careers/user/bloc/user_events.dart';
import 'package:admin_app/careers/user/models/careers_user_model.dart';
import 'package:admin_app/careers/user/repository/careers_profile_repository.dart';
import 'package:admin_app/careers/user/services/auth_api_service.dart';
import 'package:admin_app/careers/user/services/careers_user_service.dart';
import 'package:admin_app/careers/user/services/profile_api_service.dart';
import 'package:admin_app/staff/theme/staff_theme_controller.dart';
import 'package:admin_app/staff/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/staff/students/cubit/students_cubit.dart';
import 'package:admin_app/staff/students/repository/students_repository.dart';
import 'package:admin_app/core/const/db_names.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/services/api_post_logger.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/update/app_update_controller.dart';
import 'package:admin_app/core/services/authentication_service.dart';
import 'package:admin_app/core/services/careers_session_expired_handler.dart';
import 'package:admin_app/staff/face_attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:admin_app/staff/face_attendance/data/datasources/geofence_local_datasource.dart';
import 'package:admin_app/staff/face_attendance/data/repositories/attendance_repository_impl.dart';
import 'package:admin_app/staff/face_attendance/domain/repositories/attendance_repository.dart'
    as attendance_domain;
import 'package:admin_app/staff/face_attendance/domain/usecases/capture_and_verify_face_usecase.dart';
import 'package:admin_app/staff/face_attendance/domain/usecases/check_geofence_usecase.dart';
import 'package:admin_app/staff/face_attendance/domain/usecases/submit_attendance_usecase.dart';
import 'package:admin_app/staff/face_attendance/presentation/bloc/attendance_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

GetIt locator = GetIt.instance;

Future<void> serviceLocators() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register instances in GetIt
  locator.registerSingleton<HiveInterface>(Hive); // Register Hive instance

  // Register Dio instance
  final dio = Dio();
  dio.interceptors.add(ApiPostLogger.interceptor);
  locator.registerSingleton<Dio>(dio);

  // Register ApiService
  locator.registerLazySingleton<ApiService>(
    () => ApiService(
      dio: locator<Dio>(), // Use registered Dio instance
    ),
  );
  locator.registerLazySingleton<AppUpdateController>(
    () => AppUpdateController(apiService: locator<ApiService>()),
  );

  // Register authuntication Service
  locator.registerLazySingleton<AuthenticationService>(
    () => AuthenticationService(),
  );
  // Register Hive Adapters
  Hive.registerAdapter(AuthModelAdapter()); // Register the LoginModel adapter
  Hive.registerAdapter(
    CareersUserModelAdapter(),
  ); // Register the CareersUserModel adapter
  final settingsBox = await Hive.openBox('settingsBox');
  locator.registerSingleton<CareersThemeController>(
    CareersThemeController(box: settingsBox),
  );
  locator.registerSingleton<StaffThemeController>(
    StaffThemeController(box: settingsBox),
  );

  // Open Hive Box for LoginModel and register it
  var loginBox = await Hive.openBox<AuthModel>(LoginBox);
  locator.registerSingleton<Box<AuthModel>>(loginBox);

  // Open Hive Box for CareersUserModel and register it
  var careersUserBoxInstance = await Hive.openBox<CareersUserModel>(
    careersUserBox,
  );
  locator.registerSingleton<Box<CareersUserModel>>(careersUserBoxInstance);

  // Register AuthRepository and AuthCubit
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<StaffSessionService>(
    () => StaffSessionService(apiService: locator<ApiService>()),
  );
  StaffSessionExpiredHandler.onExpired = () async {
    await locator<AuthCubit>().logout(notifyServer: false);
    final overlay =
        AppRoute.router.routerDelegate.navigatorKey.currentState?.overlay;
    if (overlay != null) {
      AppToast.warning(
        overlay.context,
        'Your session has ended. Please sign in again.',
      );
    }
  };
  locator.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authRepository: locator<AuthRepository>(),
      session: locator<StaffSessionService>(),
    ),
  );

  // Register AuthRepository and AuthCubit
  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<NotificationCubit>(() => NotificationCubit());
  locator.registerLazySingleton<legacy_attendance.AttendanceRepository>(
    () => legacy_attendance.AttendanceRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<AttendanceCubit>(() => AttendanceCubit());
  locator.registerLazySingleton<GeofenceLocalDataSource>(
    () => GeofenceLocalDataSource(),
  );
  locator.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSource(dio: locator<Dio>()),
  );
  locator.registerLazySingleton<attendance_domain.AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: locator<AttendanceRemoteDataSource>(),
      localDataSource: locator<GeofenceLocalDataSource>(),
    ),
  );
  locator.registerLazySingleton<CheckGeofenceUseCase>(
    () =>
        CheckGeofenceUseCase(locator<attendance_domain.AttendanceRepository>()),
  );
  locator.registerLazySingleton<CaptureAndVerifyFaceUseCase>(
    () => CaptureAndVerifyFaceUseCase(),
  );
  locator.registerLazySingleton<SubmitAttendanceUseCase>(
    () => SubmitAttendanceUseCase(
      locator<attendance_domain.AttendanceRepository>(),
    ),
  );
  locator.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      checkGeofenceUseCase: locator<CheckGeofenceUseCase>(),
      captureAndVerifyFaceUseCase: locator<CaptureAndVerifyFaceUseCase>(),
      submitAttendanceUseCase: locator<SubmitAttendanceUseCase>(),
    ),
  );
  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<HomeRepository>(
    () => HomeRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<HomeCubit>(() => HomeCubit());

  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<ProfileCubit>(() => ProfileCubit());

  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<ClassAttendanceRepository>(
    () => ClassAttendanceRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<GradeAttendanceCubit>(
    () => GradeAttendanceCubit(),
  );
  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<StudentsRepository>(
    () => StudentsRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<StudentsCubit>(() => StudentsCubit());
  locator.registerLazySingleton<StudentAttendanceBloc>(
    () => StudentAttendanceBloc(),
  );
  // Other Hive Boxes can be registered similarly if needed

  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<ManageTicketRepository>(
    () => ManageTicketRepository(apiService: locator<ApiService>()),
  );

  locator.registerLazySingleton<TicketRepository>(
    () => TicketRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<NfcMappRepository>(
    () => NfcMappRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<EventsRepository>(
    () => ApiEventsRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<TodayEventsCubit>(() => TodayEventsCubit());
  locator.registerLazySingleton<EventsAgendaCubit>(() => EventsAgendaCubit());
  locator.registerLazySingleton<TasksRepository>(
    () => ApiTasksRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<TasksCubit>(() => TasksCubit());
  locator.registerLazySingleton<LeaveRepository>(
    () => ApiLeaveRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<ApprovalsRepository>(
    () => ApiApprovalsRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<NoticesRepository>(
    () => ApiNoticesRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<DirectoryRepository>(
    () => ApiDirectoryRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<TimetableRepository>(
    () => ApiTimetableRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<ReportsRepository>(
    () => ApiReportsRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<NotificationSettingsRepository>(
    () => ApiNotificationSettingsRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<DashboardRepository>(
    () => ApiDashboardRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<DashboardCubit>(() => DashboardCubit());
  locator.registerLazySingleton<TicketsCubit>(() => TicketsCubit());
  locator.registerLazySingleton<ManageTicketListBloc>(
    () => ManageTicketListBloc(),
  );
  locator.registerLazySingleton<ManageTicketDetailBloc>(
    () => ManageTicketDetailBloc(),
  );

  // Register CareersUserService
  locator.registerLazySingleton<CareersUserService>(() => CareersUserService());

  CareersSessionExpiredHandler.onExpired = () async {
    locator<UserBloc>().add(const LogoutEvent());
    AppRoute.router.go(Routes.careers.path);
  };

  // Register AuthApiService
  locator.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiService: locator<ApiService>()),
  );

  // Register ProfileApiService (careers candidate profile)
  locator.registerLazySingleton<ProfileApiService>(
    () => ProfileApiService(apiService: locator<ApiService>()),
  );

  // Register CareersProfileRepository
  locator.registerLazySingleton<CareersProfileRepository>(
    () => CareersProfileRepository(
      profileApiService: locator<ProfileApiService>(),
      careersUserService: locator<CareersUserService>(),
    ),
  );

  // Register CareersProfileBloc as factory: each profile screen gets its own
  // instance so page states don't leak between routes.
  locator.registerFactory<CareersProfileBloc>(
    () => CareersProfileBloc(repository: locator<CareersProfileRepository>()),
  );

  // Register UserBloc (careers candidate auth)
  locator.registerLazySingleton<UserBloc>(
    () => UserBloc(
      authApiService: locator<AuthApiService>(),
      careersUserService: locator<CareersUserService>(),
    ),
  );

  // Register ApplicationApiService (careers job applications)
  locator.registerLazySingleton<ApplicationApiService>(
    () => ApplicationApiService(apiService: locator<ApiService>()),
  );

  // Register ApplicationBloc as factory. Token is read per request so a
  // login that happens after the screen opens is picked up.
  locator.registerFactory<ApplicationBloc>(
    () => ApplicationBloc(
      applicationApiService: locator<ApplicationApiService>(),
      careersUserService: locator<CareersUserService>(),
    ),
  );
}
