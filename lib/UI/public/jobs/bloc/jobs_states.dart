import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';

// States for Jobs Bloc
abstract class JobsState {}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<JobModel> jobs;
  final String searchQuery;
  final String filterBy;
  final int? selectedSchoolId;
  final String locationQuery;
  final List<SchoolModel> schools;
  final int currentPage;
  final int totalPages;
  final bool hasMoreJobs;
  final bool isLoadingMore;

  JobsLoaded({
    required this.jobs,
    this.searchQuery = '',
    this.filterBy = 'All',
    this.selectedSchoolId,
    this.locationQuery = '',
    this.schools = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMoreJobs = false,
    this.isLoadingMore = false,
  });

  JobsLoaded copyWith({
    List<JobModel>? jobs,
    String? searchQuery,
    String? filterBy,
    int? selectedSchoolId,
    String? locationQuery,
    List<SchoolModel>? schools,
    int? currentPage,
    int? totalPages,
    bool? hasMoreJobs,
    bool? isLoadingMore,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      searchQuery: searchQuery ?? this.searchQuery,
      filterBy: filterBy ?? this.filterBy,
      selectedSchoolId: selectedSchoolId ?? this.selectedSchoolId,
      locationQuery: locationQuery ?? this.locationQuery,
      schools: schools ?? this.schools,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMoreJobs: hasMoreJobs ?? this.hasMoreJobs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class JobsError extends JobsState {
  final String message;

  JobsError(this.message);
}

class JobDetailsLoading extends JobsState {}

class JobDetailsLoaded extends JobsState {
  final JobModel job;

  JobDetailsLoaded(this.job);
}

class JobDetailsError extends JobsState {
  final String message;

  JobDetailsError(this.message);
}

class SchoolsLoading extends JobsState {}

class SchoolsLoaded extends JobsState {
  final List<SchoolModel> schools;

  SchoolsLoaded(this.schools);
}

class SchoolsError extends JobsState {
  final String message;

  SchoolsError(this.message);
}
