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
import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/UI/students/cubit/students_cubit.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> setupInteractedMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage msg) {
    final data = msg.data;

    final page = data['data_page']?.toString();
    final ticketId = int.tryParse(data['ticket_id']?.toString() ?? '');
    if (page == null) return;
    if (page == Routes.manageTicketDetailPage.path) {
      if (ticketId != null) {
        AppRoute.router.goNamed(
          Routes.manageTicketDetailPage.name,
          extra: ticketId,
        );
      }
    } else if (page == Routes.ticketDetailPage.path) {
      if (ticketId != null) {
        AppRoute.router.goNamed(
          Routes.ticketDetailPage.name,
          extra: ticketId,
        );
      }
    } else {
      AppRoute.router.goNamed(Routes.getNotifications.name);
    }
  }

  @override
  void initState() {
    // setupInteractedMessage();

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NfcProvider(),
        ),
      ],
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
            // Ensure the context contains the correct provider before calling setStream
            AppRoute.setStream(context); // Call it after context is available
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: "Smart PACE",
              theme: ThemeData(
                textTheme: GoogleFonts.poppinsTextTheme(),
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: ConstColors.backgroundColor,
                appBarTheme: AppBarTheme(
                  centerTitle: false,
                  foregroundColor: ConstColors.backgroundColor,
                  surfaceTintColor: ConstColors.backgroundColor,
                  shadowColor: ConstColors.backgroundColor,
                  backgroundColor: Colors.white,
                  // elevation: 2,
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  actionsIconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  titleTextStyle: GoogleFonts.nunitoSans(
                    textStyle: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              routerConfig: AppRoute.router,
            );
          },
        ),
      ),
    );
  }
}
