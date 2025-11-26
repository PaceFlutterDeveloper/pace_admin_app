// lib/UI/employee/tickets/tickets/cubit/tickets_state.dart

import 'package:admin_app/UI/employee/tickets/tickets/models/single_ticket_response_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_response_model.dart';

import '../models/form_config_model.dart';
import '../models/raise_ticket_response.dart';

abstract class TicketsState {}

// fetching tickets
class TicketsLoading extends TicketsState {}

class TicketsLoadingSuccess extends TicketsState {
  final TicketResponseModel tickets;
  TicketsLoadingSuccess({required this.tickets});
}

class TicketsLoadingError extends TicketsState {
  final String message;
  TicketsLoadingError({required this.message});
}

// fetching a single ticket
class SingleTicketLoading extends TicketsState {}

class SingleTicketSuccess extends TicketsState {
  final SingleTicketResponseModel ticketResponseModel;
  SingleTicketSuccess({required this.ticketResponseModel});
}

class SingleTicketError extends TicketsState {
  final String message;
  SingleTicketError({required this.message});
}

// fetching ticket form config
class TicketsConfigFetchLoading extends TicketsState {}

class TicketsConfigFetchSuccess extends TicketsState {
  final FormConfigModel formConfigModel;
  TicketsConfigFetchSuccess({required this.formConfigModel});
}

class TicketsConfigFetchError extends TicketsState {
  final String message;
  TicketsConfigFetchError({required this.message});
}

// creating tickets
class TicketAddLoading extends TicketsState {}

class TicketAddSuccess extends TicketsState {
  final RaiseTicketResponse result;
  TicketAddSuccess({required this.result});
}

class TicketAddError extends TicketsState {
  final String message;
  TicketAddError({required this.message});
}
