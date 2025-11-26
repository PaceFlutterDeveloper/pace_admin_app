import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/auth/repository/auth_repository.dart';
import 'package:admin_app/UI/class_attendance/cubit/grade_attendance_cubit.dart';
import 'package:admin_app/UI/class_attendance/repository/class_attendance_repository.dart';
import 'package:admin_app/UI/employee/attendance/cubit/attendance_cubit.dart';
import 'package:admin_app/UI/employee/attendance/repository/attendance_repository.dart';
import 'package:admin_app/UI/employee/profile/cubit/profile_cubit.dart';
import 'package:admin_app/UI/employee/profile/repository/profile_repository.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/repository/ticket_repository.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/repository/ticket_repository.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/repository/repository.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/UI/home/repository/home_repository.dart';
import 'package:admin_app/UI/notification/cubit/notification_cubit.dart';
import 'package:admin_app/UI/notification/repository/notification_repository.dart';
import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:admin_app/UI/public/user/services/auth_api_service.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/UI/students/cubit/students_cubit.dart';
import 'package:admin_app/UI/students/repository/students_repository.dart';
import 'package:admin_app/core/const/db_names.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/services/authentication_service.dart';
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
  locator.registerSingleton<Dio>(dio);

  // Register ApiService
  locator.registerLazySingleton<ApiService>(
    () => ApiService(
      dio: locator<Dio>(), // Use registered Dio instance
    ),
  );
// Register authuntication Service
  locator.registerLazySingleton<AuthenticationService>(
    () => AuthenticationService(),
  );
  // Register Hive Adapters
  Hive.registerAdapter(AuthModelAdapter()); // Register the LoginModel adapter
  Hive.registerAdapter(
      CareersUserModelAdapter()); // Register the CareersUserModel adapter
  await Hive.openBox('settingsBox');

  // Open Hive Box for LoginModel and register it
  var loginBox = await Hive.openBox<AuthModel>(LoginBox);
  locator.registerSingleton<Box<AuthModel>>(loginBox);

  // Open Hive Box for CareersUserModel and register it
  var careersUserBoxInstance =
      await Hive.openBox<CareersUserModel>(careersUserBox);
  locator.registerSingleton<Box<CareersUserModel>>(careersUserBoxInstance);

  // Register AuthRepository and AuthCubit
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<AuthCubit>(
    () => AuthCubit(),
  );

  // Register AuthRepository and AuthCubit
  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(apiService: locator<ApiService>()),
  );
  locator.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(),
  );
  locator.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<AttendanceCubit>(
    () => AttendanceCubit(),
  );
// Register HomeRepository and HomeCubit
  locator.registerLazySingleton<HomeRepository>(
    () => HomeRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<HomeCubit>(
    () => HomeCubit(),
  );

  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(),
  );

  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<ClassAttendanceRepository>(
    () => ClassAttendanceRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<GradeAttendanceCubit>(
    () => GradeAttendanceCubit(),
  );
  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<StudentsRepository>(
    () => StudentsRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<StudentsCubit>(
    () => StudentsCubit(),
  );
  locator.registerLazySingleton<StudentAttendanceBloc>(
    () => StudentAttendanceBloc(),
  );
  // Other Hive Boxes can be registered similarly if needed

  // Register HomeRepository and HomeCubit
  locator.registerLazySingleton<ManageTicketRepository>(
    () => ManageTicketRepository(
      apiService: locator<ApiService>(),
    ),
  );

  locator.registerLazySingleton<TicketRepository>(
    () => TicketRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<NfcMappRepository>(
    () => NfcMappRepository(
      apiService: locator<ApiService>(),
    ),
  );
  locator.registerLazySingleton<TicketsCubit>(
    () => TicketsCubit(),
  );
  locator.registerLazySingleton<ManageTicketListBloc>(
    () => ManageTicketListBloc(),
  );
  locator.registerLazySingleton<ManageTicketDetailBloc>(
    () => ManageTicketDetailBloc(),
  );

  // Register CareersUserService
  locator.registerLazySingleton<CareersUserService>(
    () => CareersUserService(),
  );

  // Register AuthApiService
  locator.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiService: locator<ApiService>()),
  );

  // Register UserBloc
  locator.registerLazySingleton<UserBloc>(
    () => UserBloc(
      apiService: locator<ApiService>(),
      careersUserService: locator<CareersUserService>(),
    ),
  );
}
