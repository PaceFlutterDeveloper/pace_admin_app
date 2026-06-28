// lib/UI/employee/tickets/tickets/cubit/tickets_cubit.dart

import 'dart:io';

import 'package:admin_app/UI/employee/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/form_config_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_response_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/repository/ticket_repository.dart';
import 'package:admin_app/core/utils/debug_logger.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketRepository _ticketRepo = locator<TicketRepository>();

  TicketResponseModel? _cachedTickets;
  FormConfigModel? _cachedFormConfig;

  TicketsCubit() : super(TicketsLoading());

  TicketResponseModel? get cachedTickets => _cachedTickets;
  FormConfigModel? get cachedFormConfig => _cachedFormConfig;

  /// Re-emits the last successful list state after detail/create flows.
  void restoreListState() {
    if (_cachedTickets != null) {
      emit(TicketsLoadingSuccess(tickets: _cachedTickets!));
    } else {
      fetchTickets();
    }
  }

  /// 1️⃣ Fetch all (or “my”) tickets
  Future<void> fetchTickets() async {
    DebugLogger.log('📦 [CUBIT] fetchTickets() called');
    emit(TicketsLoading());
    DebugLogger.log('🔄 [CUBIT] State changed to: TicketsLoading');

    final result = await _ticketRepo.getTickets();
    result.fold(
      (error) {
        DebugLogger.log('❌ [CUBIT] Ticket fetch error: ${error.message}');
        emit(TicketsLoadingError(message: error.message));
        DebugLogger.log('🔄 [CUBIT] State changed to: TicketsLoadingError');
      },
      (resp) {
        DebugLogger.log(
            '✅ [CUBIT] Ticket fetch success. Found ${resp.data?.length ?? 0} tickets');
        _cachedTickets = resp;
        emit(TicketsLoadingSuccess(tickets: resp));
        DebugLogger.log('🔄 [CUBIT] State changed to: TicketsLoadingSuccess');
      },
    );
  }

  /// Fetch a single ticket by ID

  Future<void> fetchSingleTicket({required int id}) async {
    emit(SingleTicketLoading());
    final result = await _ticketRepo.getSingleTicket(id: id);
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
      (config) {
        _cachedFormConfig = config;
        emit(TicketsConfigFetchSuccess(formConfigModel: config));
      },
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
        } else {
          DebugLogger.log('⚠️ [CUBIT] Ticket creation failed: ${resp.message}');
          emit(TicketAddError(message: resp.message));
          DebugLogger.log('🔄 [CUBIT] State changed to: TicketAddError');
        }
      },
    );
  }
}
