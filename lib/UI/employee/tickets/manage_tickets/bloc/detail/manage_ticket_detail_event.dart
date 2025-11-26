import 'package:equatable/equatable.dart';

abstract class ManageTicketDetailEvent extends Equatable {
  const ManageTicketDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchTicketDetailEvent extends ManageTicketDetailEvent {
  final int id;

  const FetchTicketDetailEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateTicketStatusEvent extends ManageTicketDetailEvent {
  final int id;
  final String action;
  final int? statusId;
  final String? comment;

  const UpdateTicketStatusEvent({
    required this.id,
    required this.action,
    this.statusId,
    this.comment,
  });

  @override
  List<Object?> get props => [id, action, statusId, comment];
}
