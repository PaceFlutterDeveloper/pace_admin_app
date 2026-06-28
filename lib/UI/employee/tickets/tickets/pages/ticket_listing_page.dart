// lib/UI/employee/tickets/pages/ticket_list_page.dart

// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/UI/employee/tickets/tickets/components/ticket_card.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_response_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/pages/ticket_create_page.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/shell_route_observer.dart';
import 'package:admin_app/core/widgets/app_app_bar.dart';
import 'package:admin_app/core/widgets/app_empty_state.dart';
import 'package:admin_app/core/widgets/app_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> with RouteAware {
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
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    context.read<TicketsCubit>().fetchTickets();
  }

  TicketResponseModel? _ticketsFromState(TicketsState state, TicketsCubit cubit) {
    if (state is TicketsLoadingSuccess) return state.tickets;
    return cubit.cachedTickets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.pageBg,
      appBar: const AppAppBar(title: 'My Tickets'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ticketCreated = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => TicketsCubit()..fetchFormConfig(),
                child: const TicketCreatePage(),
              ),
            ),
          );

          if (ticketCreated == true && context.mounted) {
            context.read<TicketsCubit>().fetchTickets();
          }
        },
        tooltip: 'Raise Ticket',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TicketsCubit, TicketsState>(
        builder: (context, state) {
          final cubit = context.read<TicketsCubit>();
          final ticketsResponse = _ticketsFromState(state, cubit);

          if (state is TicketsLoading && ticketsResponse == null) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is TicketsLoadingError && ticketsResponse == null) {
            return Center(
              child: Text(
                state.message,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          if (ticketsResponse != null) {
            final tickets = ticketsResponse.data ?? [];

            return AppRefreshIndicator(
              onRefresh: () => cubit.fetchTickets(),
              child: tickets.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyState.noData(
                            title: 'No tickets yet',
                            subtitle: 'Tap + to raise your first ticket.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => AppSpacing.vGapSm,
                      itemBuilder: (ctx, idx) {
                        return TicketCard(ticket: tickets[idx]);
                      },
                    ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
