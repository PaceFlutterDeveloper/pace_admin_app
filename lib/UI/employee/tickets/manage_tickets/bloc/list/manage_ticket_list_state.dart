import 'package:equatable/equatable.dart';

import '../../models/manage_ticket_response_model.dart';

abstract class ManageTicketListState extends Equatable {
  const ManageTicketListState();

  @override
  List<Object?> get props => [];
}

class ManageTicketListInitial extends ManageTicketListState {}

class ManageTicketListLoading extends ManageTicketListState {}

class ManageTicketListLoaded extends ManageTicketListState {
  final ManageTicketResponseModel ticketResponseModel;
  final int? endStat;
  final String? action;

  const ManageTicketListLoaded({
    required this.ticketResponseModel,
    this.endStat,
    this.action,
  });

  @override
  List<Object?> get props => [ticketResponseModel, endStat, action];
}

class ManageTicketListError extends ManageTicketListState {
  final String message;

  const ManageTicketListError({required this.message});

  @override
  List<Object?> get props => [message];
}
