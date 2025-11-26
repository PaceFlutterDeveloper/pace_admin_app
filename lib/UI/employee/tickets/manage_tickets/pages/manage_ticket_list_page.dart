import 'dart:io';

import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_event.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_state.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/components/custom_ticket_tabBar.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/components/manage_ticket_card.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/components/non_collapsed_header.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      body: BlocBuilder<ManageTicketListBloc, ManageTicketListState>(
        builder: (context, state) {
          int all = _lastAll;
          int inProgress = _lastInProgress;
          int finished = _lastFinished;

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
              SizedBox(
                height: Platform.isIOS ? 260.h : 230.h,
                child: NonCollapsedHeader(
                  all: all,
                  finished: finished,
                  inProgress: inProgress,
                  topPadding: MediaQuery.of(context).padding.top,
                ),
              ),
              SizedBox(
                height: 54.h,
                child: CustomTicketTabBar(
                  selectedIndex: _currentTabIndex,
                  allCount: all,
                  inProgressCount: inProgress,
                  finishCount: finished,
                  onTabChanged: (newIndex) {
                    _tabController.animateTo(newIndex);
                  },
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<ManageTicketListBloc>().add(
            FetchTicketListEvent(
              action: widget.myTickets ? "assigned" : null,
              endStat: widget.myTickets ? widget.isEnd : null,
            ),
          );
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageTicketListBloc, ManageTicketListState>(
      builder: (context, state) {
        if (state is ManageTicketListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ManageTicketListLoaded) {
          final List<ManageTicketModel> tickets =
              state.ticketResponseModel.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, idx) => ManageTicketCard(ticket: tickets[idx]),
          );
        } else if (state is ManageTicketListError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
