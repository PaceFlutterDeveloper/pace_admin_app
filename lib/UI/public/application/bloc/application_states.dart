import '../models/application_models.dart';

abstract class ApplicationState {}

// Initial State
class ApplicationInitial extends ApplicationState {}

// Loading State
class ApplicationLoading extends ApplicationState {}

// Loading More State
class ApplicationLoadingMore extends ApplicationState {
  final List<Application> applications;
  final Candidate? candidate;
  final Pagination? pagination;
  final int currentPage;
  final bool hasReachedMax;

  ApplicationLoadingMore({
    required this.applications,
    this.candidate,
    this.pagination,
    required this.currentPage,
    required this.hasReachedMax,
  });
}

// Loaded State
class ApplicationLoaded extends ApplicationState {
  final List<Application> applications;
  final Candidate? candidate;
  final Pagination? pagination;
  final int currentPage;
  final bool hasReachedMax;
  final ApplicationStatus? selectedStatus;

  ApplicationLoaded({
    required this.applications,
    this.candidate,
    this.pagination,
    required this.currentPage,
    required this.hasReachedMax,
    this.selectedStatus,
  });

  List<Application> get filteredApplications {
    if (selectedStatus == null) return applications;
    return applications
        .where((app) =>
            app.application.status.toLowerCase() ==
            selectedStatus!.displayName.toLowerCase())
        .toList();
  }
}

// Error State
class ApplicationError extends ApplicationState {
  final String message;

  ApplicationError({required this.message});
}
