import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/shell/staff_shell.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/tickets/tickets/components/ticket_card.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/staff/tickets/tickets/pages/ticket_create_page.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TicketListPage extends StatelessWidget {
  const TicketListPage({Key? key}) : super(key: key);

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
          if (state is TicketsLoadingSuccess) {
            final total = state.tickets.data?.length ?? 0;
            subtitle = '${openTicketCount(state)} open · $total total';
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
            final tickets = state.tickets.data ?? const [];
            if (tickets.isEmpty) {
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
              body = RefreshIndicator(
                color: p.amberText,
                backgroundColor: p.surface,
                onRefresh: () => context.read<TicketsCubit>().fetchTickets(),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, idx) => TicketCard(ticket: tickets[idx]),
                ),
              );
            }
          } else {
            body = const SizedBox.shrink();
          }

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
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}
