import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/shell/staff_shell.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/tickets/tickets/components/ticket_card.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/staff/tickets/tickets/models/ticket_model.dart';
import 'package:admin_app/staff/tickets/tickets/pages/ticket_create_page.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum _MyTicketTab { pending, inProgress, resolved }

class TicketListPage extends StatefulWidget {
  const TicketListPage({Key? key}) : super(key: key);

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  _MyTicketTab _tab = _MyTicketTab.pending;

  Future<void> _raiseTicket(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TicketsCubit>(),
          child: const TicketCreatePage(),
        ),
      ),
    );
  }

  static bool _matches(TicketModel ticket, _MyTicketTab tab) {
    final status = ticket.statusName.trim().toLowerCase();
    return switch (tab) {
      _MyTicketTab.pending => status == 'pending' || status == 'escalated',
      _MyTicketTab.inProgress =>
        status == 'in progress' || status == 'inprogress',
      _MyTicketTab.resolved =>
        status == 'resolved' || status == 'closed' || status == 'rejected',
    };
  }

  static List<TicketModel> _filter(
    List<TicketModel> tickets,
    _MyTicketTab tab,
  ) {
    return tickets.where((ticket) => _matches(ticket, tab)).toList();
  }

  String _emptyMessage(_MyTicketTab tab) {
    return switch (tab) {
      _MyTicketTab.pending => 'New tickets you raise will wait here.',
      _MyTicketTab.inProgress => 'Tickets being worked on will show up here.',
      _MyTicketTab.resolved => 'Resolved and closed tickets land here.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffPage(
      child: BlocBuilder<TicketsCubit, TicketsState>(
        // The create form shares this cubit; ignore its states so the list
        // does not blank out when the form is opened and dismissed.
        buildWhen: (_, next) =>
            next is TicketsLoading ||
            next is TicketsLoadingSuccess ||
            next is TicketsLoadingError,
        builder: (context, state) {
          String? subtitle;
          var pendingCount = 0;
          var inProgressCount = 0;
          var resolvedCount = 0;

          if (state is TicketsLoadingSuccess) {
            final all = state.tickets.data ?? const [];
            pendingCount = _filter(all, _MyTicketTab.pending).length;
            inProgressCount = _filter(all, _MyTicketTab.inProgress).length;
            resolvedCount = _filter(all, _MyTicketTab.resolved).length;
            subtitle =
                '${openTicketCount(state)} open · ${all.length} total';
          }

          Widget body;
          if (state is TicketsLoading) {
            body = const TicketListSkeleton();
          } else if (state is TicketsLoadingError) {
            body = StaffStateMessage(
              glyph: StaffGlyphs.ticket,
              title: 'Could not load tickets',
              message: state.message,
              actionLabel: 'Try again',
              onAction: () => context.read<TicketsCubit>().fetchTickets(),
              accent: StaffAccent.pink,
            );
          } else if (state is TicketsLoadingSuccess) {
            final all = state.tickets.data ?? const [];
            if (all.isEmpty) {
              body = StaffStateMessage(
                glyph: StaffGlyphs.inbox,
                title: 'No tickets yet',
                message:
                    'Anything you raise for maintenance, IT or admin will be tracked here.',
                actionLabel: 'Raise a ticket',
                onAction: () => _raiseTicket(context),
                accent: StaffAccent.pink,
              );
            } else {
              final tickets = _filter(all, _tab);
              if (tickets.isEmpty) {
                body = StaffStateMessage(
                  glyph: StaffGlyphs.inbox,
                  title: 'No tickets here',
                  message: _emptyMessage(_tab),
                  accent: StaffAccent.violet,
                );
              } else {
                body = RefreshIndicator(
                  color: p.amberText,
                  backgroundColor: p.surface,
                  onRefresh: () => context.read<TicketsCubit>().fetchTickets(),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, idx) => TicketCard(ticket: tickets[idx]),
                  ),
                );
              }
            }
          } else {
            body = const SizedBox.shrink();
          }

          final showSegments =
              state is TicketsLoadingSuccess &&
              (state.tickets.data?.isNotEmpty ?? false);

          return Column(
            children: [
              StaffPageHeader(
                title: 'My tickets',
                subtitle: subtitle,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.home.path);
                  }
                },
                trailing: StaffIconButton(
                  glyph: StaffGlyphs.plus,
                  active: true,
                  semanticLabel: 'Raise ticket',
                  onTap: () => _raiseTicket(context),
                ),
              ),
              if (showSegments)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: TicketSegments(
                    labels: const ['Pending', 'In progress', 'Resolved'],
                    counts: [pendingCount, inProgressCount, resolvedCount],
                    selected: _tab.index,
                    onChanged: (i) =>
                        setState(() => _tab = _MyTicketTab.values[i]),
                  ),
                ),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}
