import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/application_api_service.dart';
import 'application_events.dart';
import 'application_states.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ApplicationApiService _applicationApiService;
  String? _token;

  ApplicationBloc({
    required ApplicationApiService applicationApiService,
    String? token,
  })  : _applicationApiService = applicationApiService,
        _token = token,
        super(ApplicationInitial()) {
    on<LoadApplicationsEvent>(_onLoadApplications);
    on<LoadMoreApplicationsEvent>(_onLoadMoreApplications);
    on<RefreshApplicationsEvent>(_onRefreshApplications);
    on<FilterApplicationsByStatusEvent>(_onFilterApplicationsByStatus);
  }

  Future<void> _onLoadApplications(
    LoadApplicationsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());

    final result = await _applicationApiService.getMyApplications(
      candId: event.candId,
      page: 1,
      limit: event.limit,
      token: _token,
    );

    result.fold(
      (error) {
        log('Error loading applications: ${error.message}');
        emit(ApplicationError(message: error.message));
      },
      (response) {
        log('Successfully loaded ${response.data.applications.length} applications');
        emit(ApplicationLoaded(
          applications: response.data.applications,
          candidate: response.data.candidate,
          pagination: response.data.pagination,
          currentPage: 1,
          hasReachedMax: !response.data.pagination.hasNext,
        ));
      },
    );
  }

  Future<void> _onLoadMoreApplications(
    LoadMoreApplicationsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    if (state is ApplicationLoaded) {
      final currentState = state as ApplicationLoaded;
      if (currentState.hasReachedMax || state is ApplicationLoading) {
        return;
      }

      emit(ApplicationLoadingMore(
        applications: currentState.applications,
        candidate: currentState.candidate,
        pagination: currentState.pagination,
        currentPage: currentState.currentPage,
        hasReachedMax: currentState.hasReachedMax,
      ));

      final result = await _applicationApiService.getMyApplications(
        candId: event.candId,
        page: currentState.currentPage + 1,
        limit: event.limit,
        token: _token,
      );

      result.fold(
        (error) {
          log('Error loading more applications: ${error.message}');
          emit(ApplicationError(message: error.message));
        },
        (response) {
          log('Successfully loaded ${response.data.applications.length} more applications');
          emit(ApplicationLoaded(
            applications: [
              ...currentState.applications,
              ...response.data.applications
            ],
            candidate: currentState.candidate,
            pagination: response.data.pagination,
            currentPage: currentState.currentPage + 1,
            hasReachedMax: !response.data.pagination.hasNext,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshApplications(
    RefreshApplicationsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    add(LoadApplicationsEvent(candId: event.candId, limit: 20));
  }

  void _onFilterApplicationsByStatus(
    FilterApplicationsByStatusEvent event,
    Emitter<ApplicationState> emit,
  ) {
    if (state is ApplicationLoaded) {
      final currentState = state as ApplicationLoaded;
      emit(ApplicationLoaded(
        applications: currentState.applications,
        candidate: currentState.candidate,
        pagination: currentState.pagination,
        currentPage: currentState.currentPage,
        hasReachedMax: currentState.hasReachedMax,
        selectedStatus: event.status,
      ));
    }
  }
}
