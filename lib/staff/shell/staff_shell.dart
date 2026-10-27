import 'package:admin_app/staff/shell/staff_dock.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:flutter/material.dart';
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
            child: StaffDock(
              current: _tab,
              onSelect: (tab) {
                if (tab == _tab && path == tab.path) return;
                goToStaffTab(context, tab);
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
