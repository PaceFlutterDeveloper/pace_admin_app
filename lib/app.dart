import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/class_attendance/cubit/grade_attendance_cubit.dart';
import 'package:admin_app/UI/employee/attendance/cubit/attendance_cubit.dart';
import 'package:admin_app/UI/employee/profile/cubit/profile_cubit.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/detail/manage_ticket_detail_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/provider/nfc_provider.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/UI/notification/cubit/notification_cubit.dart';
import 'package:admin_app/UI/notification/services/firebase_service.dart';
import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/components/logout_dialog.dart';
import 'package:admin_app/UI/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/UI/students/cubit/students_cubit.dart';
import 'package:admin_app/config/themes/app_theme.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseService.handlePendingInitialMessage();
      FirebaseService.restoreCareersTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => NfcProvider())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => locator<AuthCubit>()),
          BlocProvider(create: (_) => locator<NotificationCubit>()),
          BlocProvider(create: (_) => locator<AttendanceCubit>()),
          BlocProvider(create: (_) => locator<AttendanceBloc>()),
          BlocProvider(create: (_) => locator<HomeCubit>()),
          BlocProvider(create: (_) => locator<ProfileCubit>()),
          BlocProvider(create: (_) => locator<GradeAttendanceCubit>()),
          BlocProvider(create: (_) => locator<StudentsCubit>()),
          BlocProvider(create: (_) => locator<StudentAttendanceBloc>()),
          BlocProvider(create: (_) => locator<TicketsCubit>()),
          BlocProvider(create: (_) => locator<ManageTicketListBloc>()),
          BlocProvider(create: (_) => locator<ManageTicketDetailBloc>()),
          BlocProvider(create: (_) => locator<UserBloc>()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 800),
          minTextAdapt: true,
          splitScreenMode: true,
          // Now `AppRoute.setStream(context)` is called inside the `builder` when context is correctly available
          builder: (context, child) {
            AppRoute.setStream(context);
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: "Smart PACE",
              theme: AppTheme.light(ConstColors.primary),
              darkTheme: AppTheme.dark(ConstColors.primary),
              themeMode: ThemeMode.light,
              routerConfig: AppRoute.router,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final clampedTextScaler = TextScaler.linear(
                  mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.2),
                );
                return MediaQuery(
                  data: mediaQuery.copyWith(textScaler: clampedTextScaler),
                  child: LogoutLoadingOverlay(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
