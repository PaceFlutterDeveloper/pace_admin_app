import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/application_api_service.dart';
import 'application_events.dart';
import 'application_states.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ApplicationApiService _applicationApiService;
  final String? _token;

  ApplicationBloc({
    required ApplicationApiService applicationApiService,
    String? token,
  }) : _applicationApiService = applicationApiService,
       _token = token,
       super(ApplicationInitial()) {
    on<LoadApplicationsEvent>(_onLoadApplications, transformer: droppable());
    on<LoadMoreApplicationsEvent>(_onLoadMoreApplications);
    on<RefreshApplicationsEvent>(_onRefreshApplications);
    on<FilterApplicationsByStatusEvent>(_onFilterApplicationsByStatus);
    on<CheckApplicationEvent>(_onCheckApplication);
    on<ApplyJobEvent>(_onApplyJob);
    on<ResetJobApplyStateEvent>(_onResetJobApplyState);
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
        log(
          'Successfully loaded ${response.data.applications.length} applications',
        );
        emit(
          ApplicationLoaded(
            applications: response.data.applications,
            candidate: response.data.candidate,
            pagination: response.data.pagination,
            currentPage: 1,
            hasReachedMax: !response.data.pagination.hasNext,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreApplications(
    LoadMoreApplicationsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    if (state is! ApplicationLoaded) return;

    final currentState = state as ApplicationLoaded;
    if (currentState.hasReachedMax || state is ApplicationLoadingMore) {
      return;
    }

    emit(
      ApplicationLoadingMore(
        applications: currentState.applications,
        candidate: currentState.candidate,
        pagination: currentState.pagination,
        currentPage: currentState.currentPage,
        hasReachedMax: currentState.hasReachedMax,
      ),
    );

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
        log(
          'Successfully loaded ${response.data.applications.length} more applications',
        );
        emit(
          ApplicationLoaded(
            applications: [
              ...currentState.applications,
              ...response.data.applications,
            ],
            candidate: currentState.candidate,
            pagination: response.data.pagination,
            currentPage: currentState.currentPage + 1,
            hasReachedMax: !response.data.pagination.hasNext,
          ),
        );
      },
    );
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
      emit(
        ApplicationLoaded(
          applications: currentState.applications,
          candidate: currentState.candidate,
          pagination: currentState.pagination,
          currentPage: currentState.currentPage,
          hasReachedMax: currentState.hasReachedMax,
          selectedStatus: event.status,
        ),
      );
    }
  }

  Future<void> _onCheckApplication(
    CheckApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(JobApplyChecking());

    final result = await _applicationApiService.checkApplication(
      jobId: event.jobId,
      candId: event.candId,
      token: _token,
    );

    result.fold(
      (error) => emit(JobApplyCheckError(message: error.message)),
      (response) => emit(JobApplyChecked(response: response)),
    );
  }

  Future<void> _onApplyJob(
    ApplyJobEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(JobApplySubmitting());

    final result = await _applicationApiService.applyJob(
      candId: event.candId,
      jobId: event.jobId,
      coverLetter: event.coverLetter,
      token: _token,
    );

    result.fold(
      (error) {
        final missingFields = error.data?['missing_fields'] is List
            ? List<String>.from(error.data!['missing_fields'] as List)
            : <String>[];
        emit(
          JobApplyError(message: error.message, missingFields: missingFields),
        );
      },
      (response) {
        emit(JobApplySuccess(response: response));
      },
    );
  }

  void _onResetJobApplyState(
    ResetJobApplyStateEvent event,
    Emitter<ApplicationState> emit,
  ) {
    emit(ApplicationInitial());
  }
}
