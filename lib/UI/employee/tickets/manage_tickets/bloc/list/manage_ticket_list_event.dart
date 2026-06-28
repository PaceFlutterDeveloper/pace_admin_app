import 'package:equatable/equatable.dart';

abstract class ManageTicketListEvent extends Equatable {
  const ManageTicketListEvent();

  @override
  List<Object?> get props => [];
}

class FetchTicketListEvent extends ManageTicketListEvent {
  final String? action;
  final int? endStat;

  const FetchTicketListEvent({this.action, this.endStat});

  @override
  List<Object?> get props => [action, endStat];
}

class RefreshManageTicketsEvent extends ManageTicketListEvent {
  final String? action;
  final int? endStat;

  const RefreshManageTicketsEvent({this.action, this.endStat});

  @override
  List<Object?> get props => [action, endStat];
}
