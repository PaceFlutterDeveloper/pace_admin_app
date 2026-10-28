import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/events/presentation/today_events_cubit.dart';
import 'package:admin_app/staff/shell/staff_dock.dart';
import 'package:admin_app/staff/tasks/presentation/tasks_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Scaffold for every signed-in staff page: page content plus the floating dock.
class StaffShell extends StatefulWidget {
  const StaffShell({super.key, required this.child});

  final Widget child;

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  StaffTab _tab = StaffTab.home;
  late final TasksCubit _tasks = locator<TasksCubit>();
  late final TodayEventsCubit _events = locator<TodayEventsCubit>();

  @override
  void initState() {
    super.initState();
    if (!_tasks.isFresh) _tasks.load(quiet: true);
    if (!_events.isFresh) _events.load(quiet: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final path = GoRouterState.of(context).uri.path;
    _tab = staffTabForPath(path) ?? _tab;

    return Scaffold(
      backgroundColor: p.background,
      extendBody: true,
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
            child: BlocBuilder<TasksCubit, TasksState>(
              bloc: _tasks,
              builder: (context, taskState) {
                return BlocBuilder<TodayEventsCubit, TodayEventsState>(
                  bloc: _events,
                  builder: (context, eventState) {
                    final open = taskState is TasksLoaded
                        ? taskState.counts.open
                        : 0;
                    final today = eventState is TodayEventsLoaded
                        ? eventState.events.length
                        : 0;
                    return StaffDock(
                      current: _tab,
                      badges: {
                        if (open > 0) StaffTab.tasks: open,
                        if (today > 0) StaffTab.events: today,
                      },
                      onSelect: (tab) {
                        if (tab == _tab && path == tab.path) return;
                        goToStaffTab(context, tab);
                      },
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
