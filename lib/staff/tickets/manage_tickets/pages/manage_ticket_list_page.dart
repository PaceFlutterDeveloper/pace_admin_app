import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/list/manage_ticket_list_event.dart';
import 'package:admin_app/staff/tickets/manage_tickets/bloc/list/manage_ticket_list_state.dart';
import 'package:admin_app/staff/tickets/manage_tickets/components/manage_ticket_card.dart';
import 'package:admin_app/staff/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ManageTicketListPage extends StatefulWidget {
  const ManageTicketListPage({Key? key}) : super(key: key);

  @override
  State<ManageTicketListPage> createState() => _ManageTicketListPageState();
}

class _ManageTicketListPageState extends State<ManageTicketListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentTabIndex = 0;

  int _lastAll = 0;
  int _lastInProgress = 0;
  int _lastFinished = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          setState(() {
            _currentTabIndex = _tabController.index;
          });
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffPage(
      child: BlocBuilder<ManageTicketListBloc, ManageTicketListState>(
        builder: (context, state) {
          var all = _lastAll;
          var inProgress = _lastInProgress;
          var finished = _lastFinished;

          if (state is ManageTicketListLoaded &&
              state.ticketResponseModel.counts != null) {
            all = state.ticketResponseModel.counts!.unassigned;
            inProgress = state.ticketResponseModel.counts!.assignedActive;
            finished = state.ticketResponseModel.counts!.assignedClosed;

            _lastAll = all;
            _lastInProgress = inProgress;
            _lastFinished = finished;
          }

          return Column(
            children: [
              StaffPageHeader(
                title: 'Manage tickets',
                subtitle: 'Pick up, progress and close tickets',
                onBack: _back,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: TicketSegments(
                  labels: const ['To do', 'In progress', 'Done'],
                  counts: [all, inProgress, finished],
                  selected: _currentTabIndex,
                  onChanged: (i) => _tabController.animateTo(i),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _TicketsTab(myTickets: false),
                    _TicketsTab(myTickets: true, isEnd: 0),
                    _TicketsTab(myTickets: true, isEnd: 1),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TicketsTab extends StatefulWidget {
  final bool myTickets;
  final int? isEnd;

  const _TicketsTab({Key? key, required this.myTickets, this.isEnd})
    : super(key: key);

  @override
  State<_TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<_TicketsTab> {
  bool _initialized = false;

  void _fetch() {
    context.read<ManageTicketListBloc>().add(
      FetchTicketListEvent(
        action: widget.myTickets ? "assigned" : null,
        endStat: widget.myTickets ? widget.isEnd : null,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _fetch();
      _initialized = true;
    }
  }

  String get _emptyMessage {
    if (!widget.myTickets) return 'No tickets are waiting to be picked up.';
    return widget.isEnd == 1
        ? 'Tickets you close will be listed here.'
        : 'Tickets you accept will show up here.';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return BlocBuilder<ManageTicketListBloc, ManageTicketListState>(
      builder: (context, state) {
        if (state is ManageTicketListLoading) {
          return const TicketListSkeleton();
        } else if (state is ManageTicketListLoaded) {
          final List<ManageTicketModel> tickets =
              state.ticketResponseModel.data ?? [];
          if (tickets.isEmpty) {
            return StaffStateMessage(
              glyph: StaffGlyphs.inbox,
              title: 'No tickets here',
              message: _emptyMessage,
              accent: StaffAccent.violet,
            );
          }
          return RefreshIndicator(
            color: p.amberText,
            backgroundColor: p.surface,
            onRefresh: () async => _fetch(),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, idx) => ManageTicketCard(ticket: tickets[idx]),
            ),
          );
        } else if (state is ManageTicketListError) {
          return StaffStateMessage(
            glyph: StaffGlyphs.ticket,
            title: 'Could not load tickets',
            message: state.message,
            actionLabel: 'Try again',
            onAction: _fetch,
            accent: StaffAccent.pink,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
