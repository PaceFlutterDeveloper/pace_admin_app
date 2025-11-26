// Events for Jobs Bloc
abstract class JobsEvent {}

class FetchJobsEvent extends JobsEvent {
  final String? searchQuery;
  final String? filterBy;
  final int? schoolId;

  FetchJobsEvent({this.searchQuery, this.filterBy, this.schoolId});
}

class SearchJobsEvent extends JobsEvent {
  final String searchQuery;

  SearchJobsEvent(this.searchQuery);
}

class RefreshJobsEvent extends JobsEvent {
  final String? searchQuery;
  final String? filterBy;
  final int? schoolId;

  RefreshJobsEvent({this.searchQuery, this.filterBy, this.schoolId});
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

class LoadMoreJobsEvent extends JobsEvent {}
