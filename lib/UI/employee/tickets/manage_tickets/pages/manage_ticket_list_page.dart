import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_bloc.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_event.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/bloc/list/manage_ticket_list_state.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/components/manage_ticket_card.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/components/manage_tickets_summary_card.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_response_model.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/utils/manage_ticket_search_filter.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/shell_route_observer.dart';
import 'package:admin_app/core/widgets/app_app_bar.dart';
import 'package:admin_app/core/widgets/app_empty_state.dart';
import 'package:admin_app/core/widgets/app_refresh_indicator.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageTicketListPage extends StatefulWidget {
  const ManageTicketListPage({super.key});

  @override
  State<ManageTicketListPage> createState() => _ManageTicketListPageState();
}

class _ManageTicketListPageState extends State<ManageTicketListPage>
    with SingleTickerProviderStateMixin, RouteAware {
  late final TabController _tabController;
  late final List<TextEditingController> _searchControllers;
  int _currentTabIndex = 0;

  int _lastAll = 0;
  int _lastInProgress = 0;
  int _lastFinished = 0;

  @override
  void initState() {
    super.initState();
    _searchControllers = List.generate(3, (_) => TextEditingController());
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchForTab(_currentTabIndex, refresh: false);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final index = _tabController.index;
    if (index != _currentTabIndex) {
      setState(() => _currentTabIndex = index);
      _fetchForTab(index, refresh: false);
    }
  }

  void _fetchForTab(int index, {required bool refresh}) {
    final bloc = context.read<ManageTicketListBloc>();
    final event = _eventForTab(index);
    bloc.add(
      refresh
          ? RefreshManageTicketsEvent(
              action: event.action,
              endStat: event.endStat,
            )
          : event,
    );
  }

  FetchTicketListEvent _eventForTab(int index) {
    switch (index) {
      case 1:
        return const FetchTicketListEvent(action: 'assigned', endStat: 0);
      case 2:
        return const FetchTicketListEvent(action: 'assigned', endStat: 1);
      default:
        return const FetchTicketListEvent();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      shellRouteObserver.unsubscribe(this);
      shellRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    shellRouteObserver.unsubscribe(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    for (final controller in _searchControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    _fetchForTab(_currentTabIndex, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.pageBg,
      appBar: const AppAppBar(title: 'Manage Tickets'),
      body: BlocBuilder<ManageTicketListBloc, ManageTicketListState>(
        builder: (context, state) {
          if (state is ManageTicketListLoaded &&
              state.ticketResponseModel.counts != null) {
            _lastAll = state.ticketResponseModel.counts!.unassigned;
            _lastInProgress =
                state.ticketResponseModel.counts!.assignedActive;
            _lastFinished = state.ticketResponseModel.counts!.assignedClosed;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: ManageTicketsSummaryCard(
                  toDoCount: _lastAll,
                  inProgressCount: _lastInProgress,
                  doneCount: _lastFinished,
                ),
              ),
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  if (index != _currentTabIndex) {
                    setState(() => _currentTabIndex = index);
                    _fetchForTab(index, refresh: false);
                  }
                },
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 2.5,
                dividerColor:
                    isDark ? AppColors.dividerDark : AppColors.dividerLight,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'To Do ($_lastAll)'),
                  Tab(text: 'In Progress ($_lastInProgress)'),
                  Tab(text: 'Done ($_lastFinished)'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: AppSearchField(
                  key: ValueKey('manage_tickets_search_$_currentTabIndex'),
                  controller: _searchControllers[_currentTabIndex],
                  hint:
                      'Search by ticket #, date, person, or priority',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _TicketsTab(
                      myTickets: false,
                      searchQuery: _searchControllers[0].text,
                      onClearSearch: () {
                        _searchControllers[0].clear();
                        setState(() {});
                      },
                    ),
                    _TicketsTab(
                      myTickets: true,
                      isEnd: 0,
                      searchQuery: _searchControllers[1].text,
                      onClearSearch: () {
                        _searchControllers[1].clear();
                        setState(() {});
                      },
                    ),
                    _TicketsTab(
                      myTickets: true,
                      isEnd: 1,
                      searchQuery: _searchControllers[2].text,
                      onClearSearch: () {
                        _searchControllers[2].clear();
                        setState(() {});
                      },
                    ),
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
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const _TicketsTab({
    required this.myTickets,
    this.isEnd,
    this.searchQuery = '',
    this.onClearSearch,
  });

  @override
  State<_TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<_TicketsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String get _tabKey => ManageTicketListBloc.tabKey(
        action: widget.myTickets ? 'assigned' : null,
        endStat: widget.isEnd,
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ManageTicketListBloc, ManageTicketListState>(
      builder: (context, state) {
        final bloc = context.read<ManageTicketListBloc>();
        final cached = bloc.cachedFor(
          action: widget.myTickets ? 'assigned' : null,
          endStat: widget.isEnd,
        );

        final isLoadingThisTab =
            state is ManageTicketListLoading && state.tabKey == _tabKey;
        final isLoadedThisTab = state is ManageTicketListLoaded &&
            ManageTicketListBloc.tabKey(
                  action: state.action,
                  endStat: state.endStat,
                ) ==
                _tabKey;

        ManageTicketResponseModel? response;
        if (isLoadedThisTab) {
          response = state.ticketResponseModel;
        } else {
          response = cached;
        }

        if (isLoadingThisTab && response == null) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is ManageTicketListError && response == null) {
          return Center(
            child: Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (response == null) {
          return const SizedBox.shrink();
        }

        final tickets = response.data ?? [];
        final filteredTickets = ManageTicketSearchFilter.apply(
          tickets,
          widget.searchQuery,
        );
        final hasActiveSearch = widget.searchQuery.trim().isNotEmpty;

        return AppRefreshIndicator(
          onRefresh: () async {
            bloc.add(
              RefreshManageTicketsEvent(
                action: widget.myTickets ? 'assigned' : null,
                endStat: widget.isEnd,
              ),
            );
            await bloc.stream.firstWhere(
              (s) =>
                  s is ManageTicketListLoaded ||
                  s is ManageTicketListError,
            );
          },
          child: tickets.isEmpty
              ? CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState.noData(
                        title: 'No tickets found',
                        subtitle:
                            'There are no tickets in this category yet.',
                      ),
                    ),
                  ],
                )
              : filteredTickets.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyState.noResults(
                            onAction: hasActiveSearch
                                ? widget.onClearSearch
                                : null,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filteredTickets.length,
                      separatorBuilder: (_, __) => AppSpacing.vGapSm,
                      itemBuilder: (_, idx) => ManageTicketCard(
                        ticket: filteredTickets[idx],
                        onTicketUpdated: () {
                          bloc.add(
                            RefreshManageTicketsEvent(
                              action: widget.myTickets ? 'assigned' : null,
                              endStat: widget.isEnd,
                            ),
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }
}
