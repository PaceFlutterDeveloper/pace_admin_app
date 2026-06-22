import 'package:admin_app/UI/public/shared/models/careers_api_models.dart';

import '../models/application_models.dart';

abstract class ApplicationState {}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoadingMore extends ApplicationState {
  final List<Application> applications;
  final Candidate? candidate;
  final CareersPagination? pagination;
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

class ApplicationLoaded extends ApplicationState {
  final List<Application> applications;
  final Candidate? candidate;
  final CareersPagination? pagination;
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
        .where(
          (app) =>
              app.application.status.toLowerCase() ==
              selectedStatus!.displayName.toLowerCase(),
        )
        .toList();
  }
}

class ApplicationError extends ApplicationState {
  final String message;

  ApplicationError({required this.message});
}

// Job apply flow states (used on job detail page)
class JobApplyChecking extends ApplicationState {}

class JobApplyChecked extends ApplicationState {
  final CheckApplicationResponse response;

  JobApplyChecked({required this.response});
}

class JobApplyCheckError extends ApplicationState {
  final String message;

  JobApplyCheckError({required this.message});
}

class JobApplySubmitting extends ApplicationState {}

class JobApplySuccess extends ApplicationState {
  final ApplyJobResponse response;

  JobApplySuccess({required this.response});
}

class JobApplyError extends ApplicationState {
  final String message;
  final List<String> missingFields;

  JobApplyError({
    required this.message,
    this.missingFields = const [],
  });
}
