import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_model.dart';
import 'package:intl/intl.dart';

class ManageTicketSearchFilter {
  const ManageTicketSearchFilter._();

  static List<ManageTicketModel> apply(
    List<ManageTicketModel> tickets,
    String query,
  ) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return tickets;
    return tickets.where((t) => matches(t, trimmed)).toList();
  }

  static bool matches(ManageTicketModel ticket, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    final ticketNumberQuery = q.startsWith('#') ? q.substring(1) : q;
    if (ticket.id.toString().contains(ticketNumberQuery)) return true;

    if (ticket.requesterName.toLowerCase().contains(q)) return true;

    if (ticket.priorityName.toLowerCase().contains(q)) return true;

    return _matchesDate(ticket.createdAt, q);
  }

  static bool _matchesDate(String createdAt, String query) {
    try {
      final date = DateTime.parse(createdAt);
      final candidates = [
        DateFormat('MMM d, yyyy').format(date),
        DateFormat('MMM d, yyyy · h:mm a').format(date),
        DateFormat('yyyy-MM-dd').format(date),
        DateFormat('d/M/yyyy').format(date),
        DateFormat('M/d/yyyy').format(date),
        DateFormat('MMMM d, yyyy').format(date),
        DateFormat('yyyy').format(date),
        DateFormat('MMM').format(date),
        DateFormat('MMMM').format(date),
        DateFormat('d').format(date),
      ];

      for (final candidate in candidates) {
        if (candidate.toLowerCase().contains(query)) return true;
      }
    } catch (_) {}

    return createdAt.toLowerCase().contains(query);
  }
}
