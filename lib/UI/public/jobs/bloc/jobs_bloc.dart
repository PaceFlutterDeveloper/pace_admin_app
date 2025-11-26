import 'dart:developer';

import 'package:admin_app/UI/public/jobs/bloc/jobs_events.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_states.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/UI/public/jobs/services/jobs_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bloc
class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final JobsApiService _jobsApiService;
  String? _token;

  JobsBloc({required JobsApiService jobsApiService, String? token})
      : _jobsApiService = jobsApiService,
        _token = token,
        super(JobsInitial()) {
    on<FetchJobsEvent>(_onFetchJobs);
    on<SearchJobsEvent>(_onSearchJobs);
    on<RefreshJobsEvent>(_onRefreshJobs);
    on<ClearFiltersEvent>(_onClearFilters);
    on<FetchJobDetailsEvent>(_onFetchJobDetails);
    on<FetchSchoolsEvent>(_onFetchSchools);
    on<SelectSchoolEvent>(_onSelectSchool);
    on<LoadMoreJobsEvent>(_onLoadMoreJobs);
  }

  void _onFetchJobs(FetchJobsEvent event, Emitter<JobsState> emit) async {
    // Preserve schools if we already have them
    List<SchoolModel> existingSchools = [];
    if (state is JobsLoaded) {
      existingSchools = (state as JobsLoaded).schools;
    }

    emit(JobsLoading());

    final result = await _jobsApiService.fetchJobs(
      search: event.searchQuery,
      schoolId: event.schoolId,
      employmentType: event.filterBy,
      page: 1,
      limit: 10,
      token: _token,
    );

    result.fold(
      (error) => emit(JobsError(error.message)),
      (response) {
        if (response.data.isNotEmpty) {
          List<JobModel> filteredJobs = response.data;

          // Apply client-side filtering for employment type
          if (event.filterBy != null && event.filterBy != 'All') {
            filteredJobs = filteredJobs.where((job) {
              switch (event.filterBy) {
                case 'Open':
                  return job.status == 'Open';
                case 'Full-time':
                  return job.employmentType == 'Full-time';
                case 'Part-time':
                  return job.employmentType == 'Part-time';
                case 'Engineering':
                  return job.title.toLowerCase().contains('engineer') ||
                      job.title.toLowerCase().contains('developer') ||
                      job.title.toLowerCase().contains('programmer');
                case 'Design':
                  return job.title.toLowerCase().contains('design') ||
                      job.title.toLowerCase().contains('ui') ||
                      job.title.toLowerCase().contains('ux');
                case 'Marketing':
                  return job.title.toLowerCase().contains('marketing') ||
                      job.title.toLowerCase().contains('sales') ||
                      job.title.toLowerCase().contains('promotion');
                default:
                  return true;
              }
            }).toList();
          }

          final totalPages = (response.total / response.limit).ceil();
          final hasMoreJobs = response.page < totalPages;

          emit(JobsLoaded(
            jobs: filteredJobs,
            searchQuery: event.searchQuery ?? '',
            filterBy: event.filterBy ?? 'All',
            selectedSchoolId: event.schoolId,
            schools: existingSchools, // Preserve existing schools
            currentPage: response.page,
            totalPages: totalPages,
            hasMoreJobs: hasMoreJobs,
          ));
        } else {
          emit(JobsError('No jobs found'));
        }
      },
    );
  }

  void _onSearchJobs(SearchJobsEvent event, Emitter<JobsState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      log('Searching with query: ${event.searchQuery}, preserving schools: ${currentState.schools.length}');
      add(FetchJobsEvent(
        searchQuery: event.searchQuery,
        filterBy: currentState.filterBy,
        schoolId: currentState.selectedSchoolId,
      ));
    } else {
      // If no JobsLoaded state, just fetch jobs with search query
      log('No JobsLoaded state, fetching jobs with search query only');
      add(FetchJobsEvent(
        searchQuery: event.searchQuery,
      ));
    }
  }

  void _onRefreshJobs(RefreshJobsEvent event, Emitter<JobsState> emit) {
    add(FetchJobsEvent(
      searchQuery: event.searchQuery,
      filterBy: event.filterBy,
      schoolId: event.schoolId,
    ));
  }

  void _onClearFilters(ClearFiltersEvent event, Emitter<JobsState> emit) {
    add(FetchJobsEvent());
  }

  void _onFetchJobDetails(
      FetchJobDetailsEvent event, Emitter<JobsState> emit) async {
    emit(JobDetailsLoading());

    final result = await _jobsApiService.fetchJobDetails(
      event.jobId,
      token: _token,
    );

    result.fold(
      (error) => emit(JobDetailsError(error.message)),
      (job) => emit(JobDetailsLoaded(job)),
    );
  }

  void _onFetchSchools(FetchSchoolsEvent event, Emitter<JobsState> emit) async {
    // Don't emit SchoolsLoading if we already have jobs loaded
    if (state is! JobsLoaded) {
      emit(SchoolsLoading());
    }

    final result = await _jobsApiService.fetchSchools(token: _token);

    result.fold(
      (error) {
        if (state is JobsLoaded) {
          // If we have jobs loaded, keep that state but update schools
          final currentState = state as JobsLoaded;
          emit(currentState.copyWith(schools: []));
        } else {
          emit(SchoolsError(error.message));
        }
      },
      (schoolResponse) {
        if (state is JobsLoaded) {
          // If we have jobs loaded, update the schools in the current state
          final currentState = state as JobsLoaded;
          emit(currentState.copyWith(schools: schoolResponse.data));
        } else {
          // If no jobs loaded yet, emit schools loaded
          emit(SchoolsLoaded(schoolResponse.data));
        }
      },
    );
  }

  void _onSelectSchool(SelectSchoolEvent event, Emitter<JobsState> emit) async {
    log('_onSelectSchool called with schoolId: ${event.schoolId}');
    log('Current state type: ${state.runtimeType}');
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      log('Current state: searchQuery=${currentState.searchQuery}, filterBy=${currentState.filterBy}, selectedSchoolId=${currentState.selectedSchoolId}');

      // Fetch jobs with the selected school filter
      log('Calling fetchJobs with: schoolId=${event.schoolId}, search=${currentState.searchQuery}, filterBy=${currentState.filterBy}');
      final result = await _jobsApiService.fetchJobs(
        search: currentState.searchQuery.isNotEmpty
            ? currentState.searchQuery
            : null,
        schoolId: event.schoolId,
        employmentType:
            currentState.filterBy != 'All' ? currentState.filterBy : null,
        page: 1,
        limit: 10,
        token: _token,
      );

      result.fold(
        (error) => emit(JobsError(error.message)),
        (response) {
          // if (response.data.isNotEmpty) {
          List<JobModel> filteredJobs = response.data;
          final totalPages = (response.total / response.limit).ceil();
          final hasMoreJobs = response.page < totalPages;

          emit(JobsLoaded(
            jobs: filteredJobs,
            searchQuery: currentState.searchQuery,
            filterBy: currentState.filterBy,
            selectedSchoolId: event.schoolId,
            schools: currentState.schools,
            currentPage: response.page,
            totalPages: totalPages,
            hasMoreJobs: hasMoreJobs,
          ));
          // } else {
          //   emit(JobsError('No jobs found for selected school'));
          // }
        },
      );
    } else {
      // If we don't have JobsLoaded state yet, just fetch jobs with the school filter
      log('State is not JobsLoaded, fetching jobs with school filter only');
      emit(JobsLoading());

      final result = await _jobsApiService.fetchJobs(
        schoolId: event.schoolId,
        page: 1,
        limit: 10,
        token: _token,
      );

      result.fold(
        (error) => emit(JobsError(error.message)),
        (response) {
          if (response.data.isNotEmpty) {
            List<JobModel> filteredJobs = response.data;
            final totalPages = (response.total / response.limit).ceil();
            final hasMoreJobs = response.page < totalPages;

            emit(JobsLoaded(
              jobs: filteredJobs,
              selectedSchoolId: event.schoolId,
              currentPage: response.page,
              totalPages: totalPages,
              hasMoreJobs: hasMoreJobs,
            ));
          } else {
            emit(JobsError('No jobs found for selected school'));
          }
        },
      );
    }
  }

  void _onLoadMoreJobs(LoadMoreJobsEvent event, Emitter<JobsState> emit) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      if (!currentState.hasMoreJobs || currentState.isLoadingMore) {
        return;
      }

      // Emit loading more state
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await _jobsApiService.fetchJobs(
        search: currentState.searchQuery.isNotEmpty
            ? currentState.searchQuery
            : null,
        schoolId: currentState.selectedSchoolId,
        employmentType:
            currentState.filterBy != 'All' ? currentState.filterBy : null,
        page: currentState.currentPage + 1,
        limit: 10,
        token: _token,
      );

      result.fold(
        (error) => emit(JobsError(error.message)),
        (response) {
          if (response.data.isNotEmpty) {
            List<JobModel> newJobs = response.data;

            // Apply client-side filtering for employment type
            if (currentState.filterBy != 'All') {
              newJobs = newJobs.where((job) {
                switch (currentState.filterBy) {
                  case 'Open':
                    return job.status == 'Open';
                  case 'Full-time':
                    return job.employmentType == 'Full-time';
                  case 'Part-time':
                    return job.employmentType == 'Part-time';
                  case 'Engineering':
                    return job.title.toLowerCase().contains('engineer') ||
                        job.title.toLowerCase().contains('developer') ||
                        job.title.toLowerCase().contains('programmer');
                  case 'Design':
                    return job.title.toLowerCase().contains('design') ||
                        job.title.toLowerCase().contains('ui') ||
                        job.title.toLowerCase().contains('ux');
                  case 'Marketing':
                    return job.title.toLowerCase().contains('marketing') ||
                        job.title.toLowerCase().contains('sales') ||
                        job.title.toLowerCase().contains('promotion');
                  default:
                    return true;
                }
              }).toList();
            }

            final totalPages = (response.total / response.limit).ceil();
            final hasMoreJobs = response.page < totalPages;

            emit(currentState.copyWith(
              jobs: [...currentState.jobs, ...newJobs],
              currentPage: response.page,
              totalPages: totalPages,
              hasMoreJobs: hasMoreJobs,
              isLoadingMore: false,
            ));
          } else {
            emit(currentState.copyWith(
              hasMoreJobs: false,
              isLoadingMore: false,
            ));
          }
        },
      );
    }
  }
}
