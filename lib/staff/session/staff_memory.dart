import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/class_attendance/cubit/grade_attendance_cubit.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/events/presentation/events_agenda_cubit.dart';
import 'package:admin_app/staff/events/presentation/today_events_cubit.dart';
import 'package:admin_app/staff/home/cubit/home_cubit.dart';
import 'package:admin_app/staff/notification/cubit/notification_cubit.dart';
import 'package:admin_app/staff/profile/cubit/profile_cubit.dart';
import 'package:admin_app/staff/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/staff/students/cubit/students_cubit.dart';
import 'package:admin_app/staff/tasks/presentation/tasks_cubit.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/detail/manage_ticket_detail_bloc.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';

/// Drops every in-memory staff list. Call this when the signed-in account
/// changes, before the next screen can paint the previous person's data.
void clearStaffSessionMemory() {
  void drop<T extends Object>(void Function(T cubit) reset) {
    if (locator.isRegistered<T>()) reset(locator<T>());
  }

  drop<AttendanceCubit>((cubit) => cubit.dropSession());
  drop<HomeCubit>((cubit) => cubit.dropSession());
  drop<ProfileCubit>((cubit) => cubit.dropSession());
  drop<DashboardCubit>((cubit) => cubit.dropSession());
  drop<TodayEventsCubit>((cubit) => cubit.dropSession());
  drop<EventsAgendaCubit>((cubit) => cubit.dropSession());
  drop<TasksCubit>((cubit) => cubit.dropSession());
  drop<TicketsCubit>((cubit) => cubit.dropSession());
  drop<NotificationCubit>((cubit) => cubit.dropSession());
  drop<StudentsCubit>((cubit) => cubit.dropSession());
  drop<GradeAttendanceCubit>((cubit) => cubit.dropSession());
  drop<StudentAttendanceBloc>((bloc) => bloc.dropSession());
  drop<ManageTicketListBloc>((bloc) => bloc.dropSession());
  drop<ManageTicketDetailBloc>((bloc) => bloc.dropSession());
}
