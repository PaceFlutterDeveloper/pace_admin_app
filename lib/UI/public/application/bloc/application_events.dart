import '../models/application_models.dart';

abstract class ApplicationEvent {}

// Load Applications Event
class LoadApplicationsEvent extends ApplicationEvent {
  final int candId;
  final int limit;

  LoadApplicationsEvent({
    required this.candId,
    this.limit = 20,
  });
}

// Load More Applications Event
class LoadMoreApplicationsEvent extends ApplicationEvent {
  final int candId;
  final int limit;

  LoadMoreApplicationsEvent({
    required this.candId,
    this.limit = 20,
  });
}

// Refresh Applications Event
class RefreshApplicationsEvent extends ApplicationEvent {
  final int candId;

  RefreshApplicationsEvent({required this.candId});
}

// Filter Applications by Status Event
class FilterApplicationsByStatusEvent extends ApplicationEvent {
  final ApplicationStatus? status;

  FilterApplicationsByStatusEvent({this.status});
}
