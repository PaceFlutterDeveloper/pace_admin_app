import '../models/application_models.dart';

abstract class ApplicationEvent {}

class LoadApplicationsEvent extends ApplicationEvent {
  final int candId;
  final int limit;

  LoadApplicationsEvent({
    required this.candId,
    this.limit = 20,
  });
}

class LoadMoreApplicationsEvent extends ApplicationEvent {
  final int candId;
  final int limit;

  LoadMoreApplicationsEvent({
    required this.candId,
    this.limit = 20,
  });
}

class RefreshApplicationsEvent extends ApplicationEvent {
  final int candId;

  RefreshApplicationsEvent({required this.candId});
}

class FilterApplicationsByStatusEvent extends ApplicationEvent {
  final ApplicationStatus? status;

  FilterApplicationsByStatusEvent({this.status});
}

class CheckApplicationEvent extends ApplicationEvent {
  final int jobId;
  final int candId;

  CheckApplicationEvent({required this.jobId, required this.candId});
}

class ApplyJobEvent extends ApplicationEvent {
  final int jobId;
  final int candId;
  final String cvFile;
  final String? coverLetter;

  ApplyJobEvent({
    required this.jobId,
    required this.candId,
    required this.cvFile,
    this.coverLetter,
  });
}

class ResetJobApplyStateEvent extends ApplicationEvent {}
