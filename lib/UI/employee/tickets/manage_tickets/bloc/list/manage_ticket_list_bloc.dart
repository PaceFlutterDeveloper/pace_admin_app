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
  final Map<String, ManageTicketResponseModel> _tabCache = {};

  ManageTicketListBloc() : super(ManageTicketListInitial()) {
    on<FetchTicketListEvent>(_onFetchTicketList);
    on<RefreshManageTicketsEvent>(_onRefreshManageTickets);
  }

  static String tabKey({String? action, int? endStat}) {
    if (action == null) return 'all';
    return 'assigned_$endStat';
  }

  ManageTicketResponseModel? cachedFor({String? action, int? endStat}) {
    return _tabCache[tabKey(action: action, endStat: endStat)];
  }

  void clearCache() => _tabCache.clear();

  Future<void> _onFetchTicketList(
    FetchTicketListEvent event,
    Emitter<ManageTicketListState> emit,
  ) async {
    final key = tabKey(action: event.action, endStat: event.endStat);
    emit(ManageTicketListLoading(tabKey: key));

    final res = await _ticketRepository.getTickets(
      action: event.action,
      endStat: event.endStat,
    );

    res.fold(
      (error) => emit(ManageTicketListError(
          message: error.message ?? 'Something went wrong')),
      (data) {
        if (data.counts != null) countsModel = data.counts;

        final response = ManageTicketResponseModel(
          data: data.data,
          message: data.message,
          status: data.status,
          counts: countsModel,
        );
        _tabCache[key] = response;

        emit(ManageTicketListLoaded(
          ticketResponseModel: response,
          action: event.action,
          endStat: event.endStat,
        ));
      },
    );
  }

  Future<void> _onRefreshManageTickets(
    RefreshManageTicketsEvent event,
    Emitter<ManageTicketListState> emit,
  ) async {
    clearCache();
    await _onFetchTicketList(
      FetchTicketListEvent(
        action: event.action,
        endStat: event.endStat,
      ),
      emit,
    );
  }
}
