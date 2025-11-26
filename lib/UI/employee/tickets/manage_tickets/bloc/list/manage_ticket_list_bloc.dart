import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/manage_ticket_response_model.dart';
import '../../models/ticket_count_model.dart';
import '../../repository/ticket_repository.dart';
import 'manage_ticket_list_event.dart';
import 'manage_ticket_list_state.dart';

class ManageTicketListBloc
    extends Bloc<ManageTicketListEvent, ManageTicketListState> {
  final ManageTicketRepository _ticketRepository =
      locator<ManageTicketRepository>();
  CountsModel? countsModel;

  ManageTicketListBloc() : super(ManageTicketListInitial()) {
    on<FetchTicketListEvent>(_onFetchTicketList);
  }

  Future<void> _onFetchTicketList(
    FetchTicketListEvent event,
    Emitter<ManageTicketListState> emit,
  ) async {
    emit(ManageTicketListLoading());

    final res = await _ticketRepository.getTickets(
      action: event.action,
      endStat: event.endStat,
    );

    res.fold(
      (error) => emit(ManageTicketListError(
          message: error.message ?? 'Something went wrong')),
      (data) {
        if (data.counts != null) countsModel = data.counts;
        emit(ManageTicketListLoaded(
          ticketResponseModel: ManageTicketResponseModel(
            data: data.data,
            message: data.message,
            status: data.status,
            counts: countsModel,
          ),
          action: event.action,
          endStat: event.endStat,
        ));
      },
    );
  }
}
