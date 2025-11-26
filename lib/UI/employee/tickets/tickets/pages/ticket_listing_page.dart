// lib/UI/employee/tickets/pages/ticket_list_page.dart

// ignore_for_file: use_build_context_synchronously

import 'package:admin_app/UI/employee/tickets/tickets/components/ticket_card.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_response_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/pages/ticket_create_page.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/core/utils/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketListPage extends StatelessWidget {
  const TicketListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        title: const Text('My Tickets'),
      ),
      body: BlocConsumer<TicketsCubit, TicketsState>(
        listener: (context, state) {
          DebugLogger.log(
              '👂 [UI] Listener received state: ${state.runtimeType}');
          if (state is TicketAddSuccess) {
            DebugLogger.log(
                '🔄 [UI] Detected TicketAddSuccess, refreshing tickets...');
          }
        },
        builder: (context, state) {
          DebugLogger.log(
              '🖌️ [UI] Builder rebuilding with state: ${state.runtimeType}');
          if (state is TicketsLoading) {
            DebugLogger.log('⏳ [UI] Showing loading indicator');
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TicketsLoadingError) {
            DebugLogger.log('❌ [UI] Showing error: ${state.message}');
            return Center(child: Text(state.message));
          }
          if (state is TicketsLoadingSuccess) {
            final TicketResponseModel resp = state.tickets;
            final tickets = resp.data!;
            DebugLogger.log('✅ [UI] Showing ${tickets.length} tickets');

            if (tickets.isEmpty) {
              return const Center(child: Text('No tickets found'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                return TicketCard(ticket: tickets[idx]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DebugLogger.log('Navigating to create ticket');
          final shouldRefresh = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TicketsCubit>(),
                child: const TicketCreatePage(),
              ),
            ),
          );

          // if (shouldRefresh == true) {
          //   DebugLogger.log('Refreshing ticket list after creation');
          //   context.read<TicketsCubit>().fetchTickets();
          // }
        },
        tooltip: 'Raise Ticket',
        child: const Icon(Icons.add),
      ),
    );
  }
}
