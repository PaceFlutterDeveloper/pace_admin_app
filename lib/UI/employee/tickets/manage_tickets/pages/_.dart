// // lib/UI/employee/tickets/pages/ticket_list_page.dart

// import 'package:admin_app/UI/employee/tickets/manage_tickets/components/manage_ticket_card.dart';
// import 'package:admin_app/core/themes/const_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../cubit/manage_ticket_cubit_cubit.dart';
// import '../cubit/manage_ticket_cubit_state.dart';
// import '../models/manage_ticket_model.dart';

// class ManageTicketListPage extends StatelessWidget {
//   const ManageTicketListPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         backgroundColor: ConstColors.backgroundColor,
//         appBar: AppBar(
//           title: const Text('Tickets'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'All Tickets'),
//               Tab(text: 'Pending Tickets'),
//               Tab(text: 'Completed Tickets'),
//             ],
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             _TicketsTab(myTickets: false),
//             _TicketsTab(
//               myTickets: true,
//               isEnd: 0,
//             ),
//             _TicketsTab(
//               myTickets: true,
//               isEnd: 1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// A small widget that spins up its own cubit and fetches either all tickets
// /// or just “my tickets” depending on [myTickets].
// class _TicketsTab extends StatelessWidget {
//   final bool myTickets;
//   final int? isEnd;

//   const _TicketsTab({
//     Key? key,
//     required this.myTickets,
//     this.isEnd,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<ManageTicketCubit>(
//       create: (_) {
//         final cubit = ManageTicketCubit();
//         if (myTickets) {
//           cubit.getTickets(
//               action: "assigned",
//               endSat:
//                   isEnd); // you’ll need to implement this in your cubit/repo
//         } else {
//           cubit.getTickets();
//         }
//         return cubit;
//       },
//       child: BlocBuilder<ManageTicketCubit, ManageTicketState>(
//         builder: (context, state) {
//           if (state is ManageTicketLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is ManageTicketLoaded) {
//             final List<ManageTicketModel> tickets = state.ManageTickets.data!;
//             if (tickets.isEmpty) {
//               return const Center(child: Text('No tickets found'));
//             }
//             return ListView.separated(
//               padding: const EdgeInsets.all(16),
//               itemCount: tickets.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 12),
//               itemBuilder: (_, idx) => ManageTicketCard(ticket: tickets[idx]),
//             );
//           } else if (state is ManageTicketError) {
//             return Center(child: Text(state.message));
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }
