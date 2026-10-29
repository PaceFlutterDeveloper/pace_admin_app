import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/auth/cubit/auth_cubit.dart';
import 'package:admin_app/staff/auth/last_staff_profile.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/events/presentation/today_events_cubit.dart';
import 'package:admin_app/staff/shell/staff_dock.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

/// Scaffold for every signed-in staff page: page content plus the floating dock.
class StaffShell extends StatefulWidget {
  const StaffShell({super.key, required this.child});

  final Widget child;

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  StaffTab _tab = StaffTab.home;
  bool _switchingProfile = false;
  late final DashboardCubit _dashboard = locator<DashboardCubit>();
  late final TodayEventsCubit _events = locator<TodayEventsCubit>();

  /// Double tap on Profile returns to the profile this phone left last.
  /// With several saved profiles and no memory yet, the account list opens
  /// instead of guessing.
  Future<void> _switchToLastProfile() async {
    if (_switchingProfile) return;
    final accounts = locator<Box<AuthModel>>().values.toList();
    final target = lastSwitchedStaffProfile(
      accounts: accounts,
      token: storedLastStaffProfileToken(),
    );
    if (target == null) {
      final others = accounts.where((user) => !user.isActive).length;
      if (others > 1) {
        _openAccounts();
        return;
      }
      HapticFeedback.selectionClick();
      AppToast.info(context, 'Only one profile on this phone');
      return;
    }

    _switchingProfile = true;
    HapticFeedback.mediumImpact();
    try {
      await locator<AuthCubit>().switchUser(
        userName: target.userName,
        schoolCode: target.schoolCode,
        userId: target.userId,
      );
      if (!mounted) return;
      context.go(Routes.home.path);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Could not switch profile. Try again.');
      }
    } finally {
      _switchingProfile = false;
    }
  }

  void _openAccounts() {
    HapticFeedback.mediumImpact();
    context.push(Routes.usersPage.path);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final path = GoRouterState.of(context).uri.path;
    _tab = staffTabForPath(path) ?? _tab;

    return Scaffold(
      backgroundColor: p.background,
      extendBody: true,
      // Keep the floating dock on the screen edge. Letting the scaffold
      // resize would slide the dock up and sit it on top of the keyboard.
      resizeToAvoidBottomInset: false,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: StaffBackdrop()),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: staffDockBodyInset(context)),
              child: widget.child,
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: staffDockBottomOffset(context),
            child: BlocBuilder<DashboardCubit, StaffDashboard?>(
              bloc: _dashboard,
              builder: (context, dashboard) {
                return BlocBuilder<TodayEventsCubit, TodayEventsState>(
                  bloc: _events,
                  builder: (context, eventState) {
                    final pending = dashboard?.tasksPending ?? 0;
                    final today = eventState is TodayEventsLoaded
                        ? eventState.events.length
                        : 0;
                    return StaffDock(
                      current: _tab,
                      badges: {
                        if (pending > 0) StaffTab.tasks: pending,
                        if (today > 0) StaffTab.events: today,
                      },
                      onSelect: (tab) {
                        if (tab == _tab && path == tab.path) return;
                        goToStaffTab(context, tab);
                      },
                      onProfileDoubleTap: () {
                        _switchToLastProfile();
                      },
                      onProfileLongPress: _openAccounts,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tickets that are still open (end status 0 or unset).
int openTicketCount(TicketsLoadingSuccess state) {
  final list = state.tickets.data ?? const [];
  return list.where((t) => t.endStat == null || t.endStat == 0).length;
}
