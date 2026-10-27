import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/ticket_repository.dart';
import 'manage_ticket_detail_event.dart';
import 'manage_ticket_detail_state.dart';

class ManageTicketDetailBloc
    extends Bloc<ManageTicketDetailEvent, ManageTicketDetailState> {
  final ManageTicketRepository _ticketRepository =
      locator<ManageTicketRepository>();
  final SessionScope _scope = SessionScope();

  ManageTicketDetailBloc() : super(ManageTicketDetailInitial()) {
    on<ClearTicketDetailEvent>((_, emit) => emit(ManageTicketDetailInitial()));
    on<FetchTicketDetailEvent>(_onFetchTicketDetail);
    on<UpdateTicketStatusEvent>(_onUpdateTicketStatus);
  }

  /// Drops the open ticket so the next account cannot see it.
  void dropSession() {
    _scope.invalidate();
    add(const ClearTicketDetailEvent());
  }

  Future<void> _onFetchTicketDetail(
    FetchTicketDetailEvent event,
    Emitter<ManageTicketDetailState> emit,
  ) async {
    final stamp = _scope.begin();
    emit(ManageTicketDetailLoading());
    final res = await _ticketRepository.getSingleTicket(id: event.id);
    if (isClosed || !_scope.current(stamp)) return;
    res.fold(
      (error) => emit(
        ManageTicketDetailError(
          message: error.message ?? 'Error fetching ticket',
        ),
      ),
      (data) => emit(ManageTicketDetailLoaded(ticketResponseModel: data)),
    );
  }

  Future<void> _onUpdateTicketStatus(
    UpdateTicketStatusEvent event,
    Emitter<ManageTicketDetailState> emit,
  ) async {
    final stamp = _scope.begin();
    emit(ManageTicketDetailUpdating());
    final res = await _ticketRepository.updateManageTicket(
      id: event.id,
      actiion: event.action,
      statusId: event.statusId,
      comment: event.comment,
    );
    if (isClosed || !_scope.current(stamp)) return;
    res.fold(
      (error) => emit(
        ManageTicketDetailUpdateError(
          message: error.message ?? 'Error updating status',
        ),
      ),
      (data) => emit(
        ManageTicketDetailUpdated(message: data.message, status: data.status),
      ),
    );
  }
}
