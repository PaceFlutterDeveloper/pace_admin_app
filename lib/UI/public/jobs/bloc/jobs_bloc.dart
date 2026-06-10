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
  List<SchoolModel> _schoolsCache = [];

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
    on<FilterByLocationEvent>(_onFilterByLocation);
    on<FilterBySearchEvent>(_onFilterBySearch);
    on<LoadMoreJobsEvent>(_onLoadMoreJobs);
  }

  /// Search (title only), location, and school are applied client-side so each
  /// filter stays scoped to its own field and they compose together.
  List<JobModel> _applyClientFilters(
    List<JobModel> jobs, {
    String? search,
    String? location,
  }) {
    return _filterBySearch(_filterByLocation(jobs, location), search);
  }

  List<JobModel> _filterBySearch(List<JobModel> jobs, String? search) {
    final query = search?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return jobs;

    final terms = query
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();

    return jobs.where((job) {
      final title = job.title.toLowerCase();
      return terms.every((term) => title.contains(term));
    }).toList();
  }

  List<JobModel> _filterByLocation(List<JobModel> jobs, String? location) {
    final query = location?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return jobs;

    return jobs.where((job) {
      return job.location.toLowerCase().contains(query) ||
          (job.country?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  bool _hasActiveClientFilters({String? search, String? location}) {
    return (search?.trim().isNotEmpty ?? false) ||
        (location?.trim().isNotEmpty ?? false);
  }

  void _onFetchJobs(FetchJobsEvent event, Emitter<JobsState> emit) async {
    emit(JobsLoading());

    final result = await _jobsApiService.fetchJobs(
      schoolId: event.schoolId,
      employmentType: event.filterBy,
      page: 1,
      limit: 10,
      token: _token,
    );

    result.fold((error) => emit(JobsError(error.message)), (response) {
      if (response.data.isNotEmpty) {
        List<JobModel> filteredJobs = _applyClientFilters(
          response.data,
          search: event.searchQuery,
          location: event.location,
        );

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

        emit(
          JobsLoaded(
            jobs: filteredJobs,
            searchQuery: event.searchQuery ?? '',
            filterBy: event.filterBy ?? 'All',
            selectedSchoolId: event.schoolId,
            locationQuery: event.location ?? '',
            schools: _schoolsCache,
            currentPage: response.page,
            totalPages: totalPages,
            hasMoreJobs: hasMoreJobs,
          ),
        );
      } else if (_hasActiveClientFilters(
        search: event.searchQuery,
        location: event.location,
      )) {
        emit(
          JobsLoaded(
            jobs: const [],
            searchQuery: event.searchQuery ?? '',
            filterBy: event.filterBy ?? 'All',
            selectedSchoolId: event.schoolId,
            locationQuery: event.location ?? '',
            schools: _schoolsCache,
          ),
        );
      } else {
        emit(JobsError('No jobs found'));
      }
    });
  }

  void _onSearchJobs(SearchJobsEvent event, Emitter<JobsState> emit) {
    add(FilterBySearchEvent(event.searchQuery));
  }

  void _onFilterBySearch(FilterBySearchEvent event, Emitter<JobsState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      add(
        FetchJobsEvent(
          searchQuery: event.searchQuery,
          filterBy: currentState.filterBy,
          schoolId: currentState.selectedSchoolId,
          location: currentState.locationQuery,
        ),
      );
    } else {
      add(FetchJobsEvent(searchQuery: event.searchQuery));
    }
  }

  void _onRefreshJobs(RefreshJobsEvent event, Emitter<JobsState> emit) {
    add(
      FetchJobsEvent(
        searchQuery: event.searchQuery,
        filterBy: event.filterBy,
        schoolId: event.schoolId,
        location: event.location,
      ),
    );
  }

  void _onFilterByLocation(
    FilterByLocationEvent event,
    Emitter<JobsState> emit,
  ) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      add(
        FetchJobsEvent(
          searchQuery: currentState.searchQuery.isNotEmpty
              ? currentState.searchQuery
              : null,
          filterBy: currentState.filterBy,
          schoolId: currentState.selectedSchoolId,
          location: event.location,
        ),
      );
    } else {
      add(FetchJobsEvent(location: event.location));
    }
  }

  void _onClearFilters(ClearFiltersEvent event, Emitter<JobsState> emit) {
    add(FetchJobsEvent());
  }

  void _onFetchJobDetails(
    FetchJobDetailsEvent event,
    Emitter<JobsState> emit,
  ) async {
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
    // Don't emit SchoolsLoading if we already have schools cached
    if (_schoolsCache.isEmpty && state is! JobsLoaded) {
      emit(SchoolsLoading());
    }

    final result = await _jobsApiService.fetchSchools(token: _token);

    result.fold(
      (error) {
        log('Failed to fetch schools: ${error.message}');
        // Never wipe cached schools on a transient error.
        if (_schoolsCache.isNotEmpty) {
          if (state is JobsLoaded) {
            final currentState = state as JobsLoaded;
            if (currentState.schools.isEmpty) {
              emit(currentState.copyWith(schools: _schoolsCache));
            }
          } else {
            emit(SchoolsLoaded(_schoolsCache));
          }
          return;
        }
        if (state is! JobsLoaded) {
          emit(SchoolsError(error.message));
        }
      },
      (schoolResponse) {
        _schoolsCache = schoolResponse.data;
        if (state is JobsLoaded) {
          emit((state as JobsLoaded).copyWith(schools: _schoolsCache));
        } else {
          emit(SchoolsLoaded(_schoolsCache));
        }
      },
    );
  }

  void _onSelectSchool(SelectSchoolEvent event, Emitter<JobsState> emit) async {
    log('_onSelectSchool called with schoolId: ${event.schoolId}');
    log('Current state type: ${state.runtimeType}');
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      log(
        'Current state: searchQuery=${currentState.searchQuery}, filterBy=${currentState.filterBy}, selectedSchoolId=${currentState.selectedSchoolId}',
      );

      // Fetch jobs with the selected school filter
      log(
        'Calling fetchJobs with: schoolId=${event.schoolId}, search=${currentState.searchQuery}, filterBy=${currentState.filterBy}',
      );
      final result = await _jobsApiService.fetchJobs(
        schoolId: event.schoolId,
        employmentType: currentState.filterBy != 'All'
            ? currentState.filterBy
            : null,
        page: 1,
        limit: 10,
        token: _token,
      );

      result.fold((error) => emit(JobsError(error.message)), (response) {
        // if (response.data.isNotEmpty) {
        final filteredJobs = _applyClientFilters(
          response.data,
          search: currentState.searchQuery,
          location: currentState.locationQuery,
        );
        final totalPages = (response.total / response.limit).ceil();
        final hasMoreJobs = response.page < totalPages;

        emit(
          JobsLoaded(
            jobs: filteredJobs,
            searchQuery: currentState.searchQuery,
            filterBy: currentState.filterBy,
            selectedSchoolId: event.schoolId,
            locationQuery: currentState.locationQuery,
            schools: _schoolsCache,
            currentPage: response.page,
            totalPages: totalPages,
            hasMoreJobs: hasMoreJobs,
          ),
        );
        // } else {
        //   emit(JobsError('No jobs found for selected school'));
        // }
      });
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

      result.fold((error) => emit(JobsError(error.message)), (response) {
        if (response.data.isNotEmpty) {
          List<JobModel> filteredJobs = response.data;
          final totalPages = (response.total / response.limit).ceil();
          final hasMoreJobs = response.page < totalPages;

          emit(
            JobsLoaded(
              jobs: filteredJobs,
              selectedSchoolId: event.schoolId,
              schools: _schoolsCache,
              currentPage: response.page,
              totalPages: totalPages,
              hasMoreJobs: hasMoreJobs,
            ),
          );
        } else {
          emit(JobsError('No jobs found for selected school'));
        }
      });
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
        schoolId: currentState.selectedSchoolId,
        employmentType: currentState.filterBy != 'All'
            ? currentState.filterBy
            : null,
        page: currentState.currentPage + 1,
        limit: 10,
        token: _token,
      );

      result.fold((error) => emit(JobsError(error.message)), (response) {
        if (response.data.isNotEmpty) {
          List<JobModel> newJobs = _applyClientFilters(
            response.data,
            search: currentState.searchQuery,
            location: currentState.locationQuery,
          );

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

          emit(
            currentState.copyWith(
              jobs: [...currentState.jobs, ...newJobs],
              currentPage: response.page,
              totalPages: totalPages,
              hasMoreJobs: hasMoreJobs,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(currentState.copyWith(hasMoreJobs: false, isLoadingMore: false));
        }
      });
    }
  }
}
