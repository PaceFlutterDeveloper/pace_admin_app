// Events for Jobs Bloc
abstract class JobsEvent {}

class FetchJobsEvent extends JobsEvent {
  final String? searchQuery;
  final String? filterBy;
  final int? schoolId;
  final String? location;

  FetchJobsEvent({
    this.searchQuery,
    this.filterBy,
    this.schoolId,
    this.location,
  });
}

class SearchJobsEvent extends JobsEvent {
  final String searchQuery;

  SearchJobsEvent(this.searchQuery);
}

class RefreshJobsEvent extends JobsEvent {
  final String? searchQuery;
  final String? filterBy;
  final int? schoolId;
  final String? location;

  RefreshJobsEvent({
    this.searchQuery,
    this.filterBy,
    this.schoolId,
    this.location,
  });
}

class ClearFiltersEvent extends JobsEvent {}

class FetchJobDetailsEvent extends JobsEvent {
  final int jobId;

  FetchJobDetailsEvent(this.jobId);
}

class FetchSchoolsEvent extends JobsEvent {}

class SelectSchoolEvent extends JobsEvent {
  final int? schoolId;

  SelectSchoolEvent(this.schoolId);
}

class FilterByLocationEvent extends JobsEvent {
  final String location;

  FilterByLocationEvent(this.location);
}

class FilterBySearchEvent extends JobsEvent {
  final String searchQuery;

  FilterBySearchEvent(this.searchQuery);
}

class LoadMoreJobsEvent extends JobsEvent {}
