import 'package:equatable/equatable.dart';

import '../../models/manage_single_ticket_response_model.dart';

abstract class ManageTicketDetailState extends Equatable {
  const ManageTicketDetailState();

  @override
  List<Object?> get props => [];
}

class ManageTicketDetailInitial extends ManageTicketDetailState {}

class ManageTicketDetailLoading extends ManageTicketDetailState {}

class ManageTicketDetailLoaded extends ManageTicketDetailState {
  final ManageSingleTicketResponseModel ticketResponseModel;

  const ManageTicketDetailLoaded({required this.ticketResponseModel});

  @override
  List<Object?> get props => [ticketResponseModel];
}

class ManageTicketDetailError extends ManageTicketDetailState {
  final String message;

  const ManageTicketDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ManageTicketDetailUpdating extends ManageTicketDetailState {}

class ManageTicketDetailUpdated extends ManageTicketDetailState {
  final String message;
  final bool status;

  const ManageTicketDetailUpdated({
    required this.message,
    required this.status,
  });

  @override
  List<Object?> get props => [message, status];
}

class ManageTicketDetailUpdateError extends ManageTicketDetailState {
  final String message;

  const ManageTicketDetailUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
