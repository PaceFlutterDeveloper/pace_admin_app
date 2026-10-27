// lib/staff/tickets/tickets/cubit/tickets_cubit.dart

import 'dart:io';

import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/staff/tickets/tickets/repository/ticket_repository.dart';
import 'package:admin_app/core/utils/debug_logger.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketRepository _ticketRepo = locator<TicketRepository>();

  final LoadMarker _loaded = LoadMarker();
  final SessionScope _scope = SessionScope();
  final SessionScope _detail = SessionScope();

  TicketsCubit() : super(TicketsLoading());

  /// Whether the list was loaded recently for the active user.
  bool get isFresh => _loaded.isFresh();

  /// Drops tickets so the next account cannot see them.
  void dropSession() {
    _scope.invalidate();
    _detail.invalidate();
    _loaded.clear();
    if (!isClosed) emit(TicketsLoading());
  }

  /// 1️⃣ Fetch all (or “my”) tickets.
  ///
  /// With [quiet] the list already on screen stays visible while it
  /// refreshes; no loading state is emitted and errors are ignored.
  Future<void> fetchTickets({bool quiet = false}) async {
    DebugLogger.log('📦 [CUBIT] fetchTickets() called');
    final keep = quiet && _loaded.holds() && state is TicketsLoadingSuccess;
    final stamp = _scope.begin();
    if (!keep) {
      emit(TicketsLoading());
      DebugLogger.log('🔄 [CUBIT] State changed to: TicketsLoading');
    }

    final result = await _ticketRepo.getTickets();
    if (isClosed || !_scope.current(stamp)) return;
    result.fold(
      (error) {
        DebugLogger.log('❌ [CUBIT] Ticket fetch error: ${error.message}');
        if (keep) return;
        emit(TicketsLoadingError(message: error.message));
        DebugLogger.log('🔄 [CUBIT] State changed to: TicketsLoadingError');
      },
      (resp) {
        DebugLogger.log(
          '✅ [CUBIT] Ticket fetch success. Found ${resp.data?.length ?? 0} tickets',
        );
        _loaded.mark();
        emit(TicketsLoadingSuccess(tickets: resp));
        DebugLogger.log('🔄 [CUBIT] State changed to: TicketsLoadingSuccess');
      },
    );
  }

  /// Fetch a single ticket by ID

  Future<void> fetchSingleTicket({required int id}) async {
    final stamp = _detail.begin();
    emit(SingleTicketLoading());
    final result = await _ticketRepo.getSingleTicket(id: id);
    if (isClosed || !_detail.current(stamp)) return;
    result.fold(
      (error) => emit(SingleTicketError(message: error.message)),
      (resp) => emit(SingleTicketSuccess(ticketResponseModel: resp)),
    );
  }

  /// 2️⃣ Fetch form configuration (types, categories, etc.)
  Future<void> fetchFormConfig() async {
    emit(TicketsConfigFetchLoading());
    final result = await _ticketRepo.getTcketFormConfig();
    result.fold(
      (error) => emit(TicketsConfigFetchError(message: error.message)),
      (config) => emit(TicketsConfigFetchSuccess(formConfigModel: config)),
    );
  }

  /// 3️⃣ Raise a new ticket
  Future<void> raiseTicket({
    required int ticketTypeId,
    required int categoryId,
    required int locationId,
    required int priorityId,
    required String description,
    File? attachment,
  }) async {
    DebugLogger.log('📝 [CUBIT] raiseTicket() called');
    emit(TicketAddLoading());
    DebugLogger.log('🔄 [CUBIT] State changed to: TicketAddLoading');
    final result = await _ticketRepo.createTicket(
      ticketTypeId: ticketTypeId,
      categoryId: categoryId,
      locationId: locationId,
      priorityId: priorityId,
      description: description,
      attachment: attachment,
    );

    result.fold(
      (error) {
        DebugLogger.log('❌ [CUBIT] Ticket creation error: ${error.message}');
        emit(TicketAddError(message: error.message));
        DebugLogger.log('🔄 [CUBIT] State changed to: TicketAddError');
      },
      (resp) {
        if (resp.status) {
          DebugLogger.log('✅ [CUBIT] Ticket created successfully! ID: ${resp}');
          emit(TicketAddSuccess(result: resp));
          DebugLogger.log('🔄 [CUBIT] State changed to: TicketAddSuccess');

          DebugLogger.log('🔄 [CUBIT] Auto-refreshing ticket list...');
          fetchTickets(); // This should trigger the refresh
        } else {
          DebugLogger.log('⚠️ [CUBIT] Ticket creation failed: ${resp.message}');
          emit(TicketAddError(message: resp.message));
          DebugLogger.log('🔄 [CUBIT] State changed to: TicketAddError');
        }
      },
    );
  }
}
