import 'package:admin_app/UI/public/shared/models/careers_api_models.dart';

class MyApplicationsResponse {
  final bool status;
  final String message;
  final MyApplicationsData data;

  MyApplicationsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MyApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return MyApplicationsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: MyApplicationsData.fromJson(json['data'] ?? {}),
    );
  }
}

class MyApplicationsData {
  final Candidate candidate;
  final List<Application> applications;
  final CareersPagination pagination;

  MyApplicationsData({
    required this.candidate,
    required this.applications,
    required this.pagination,
  });

  factory MyApplicationsData.fromJson(Map<String, dynamic> json) {
    return MyApplicationsData(
      candidate: Candidate.fromJson(json['candidate'] ?? {}),
      applications: (json['applications'] as List<dynamic>?)
              ?.map((e) => Application.fromJson(e))
              .toList() ??
          [],
      pagination: CareersPagination.fromJson(
        json['pagination'] as Map<String, dynamic>?,
      ),
    );
  }
}

class Candidate {
  final int id;
  final String name;
  final String email;

  Candidate({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Application {
  final int applicationId;
  final ApplicationJobSummary job;
  final ApplicationDetails application;

  Application({
    required this.applicationId,
    required this.job,
    required this.application,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationId: json['application_id'] ?? 0,
      job: ApplicationJobSummary.fromJson(json['job'] ?? {}),
      application: ApplicationDetails.fromJson(json['application'] ?? {}),
    );
  }
}

class ApplicationJobSummary {
  final int id;
  final String title;
  final String location;
  final String employmentType;
  final String salaryRange;
  final String school;

  ApplicationJobSummary({
    required this.id,
    required this.title,
    required this.location,
    required this.employmentType,
    required this.salaryRange,
    required this.school,
  });

  factory ApplicationJobSummary.fromJson(Map<String, dynamic> json) {
    return ApplicationJobSummary(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      employmentType: json['employment_type'] ?? '',
      salaryRange: json['salary_range'] ?? '',
      school: json['school'] ?? '',
    );
  }
}

class ApplicationDetails {
  final String coverLetter;
  final String source;
  final String cvFile;
  final String status;
  final bool availabilityOk;
  final String appliedDate;
  final String lastActivity;

  ApplicationDetails({
    required this.coverLetter,
    required this.source,
    required this.cvFile,
    required this.status,
    required this.availabilityOk,
    required this.appliedDate,
    required this.lastActivity,
  });

  factory ApplicationDetails.fromJson(Map<String, dynamic> json) {
    return ApplicationDetails(
      coverLetter: json['cover_letter'] ?? '',
      source: json['source'] ?? '',
      cvFile: json['cv_file'] ?? '',
      status: json['status'] ?? '',
      availabilityOk: json['availability_ok'] == true ||
          json['availability_ok'] == 1,
      appliedDate: json['applied_date'] ?? '',
      lastActivity: json['last_activity'] ?? '',
    );
  }
}

class CheckApplicationResponse {
  final bool hasApplied;
  final ApplicationDetails? application;
  final ApplicationJobSummary? job;

  CheckApplicationResponse({
    required this.hasApplied,
    this.application,
    this.job,
  });

  factory CheckApplicationResponse.fromJson(Map<String, dynamic> json) {
    return CheckApplicationResponse(
      hasApplied: json['has_applied'] == true || json['has_applied'] == 1,
      application: json['application'] != null
          ? ApplicationDetails.fromJson(
              json['application'] as Map<String, dynamic>,
            )
          : null,
      job: json['job'] != null
          ? ApplicationJobSummary.fromJson(json['job'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ApplyJobResponse {
  final int applicationId;
  final ApplicationJobSummary? job;
  final Candidate? candidate;
  final String applicationDate;
  final String status;

  ApplyJobResponse({
    required this.applicationId,
    this.job,
    this.candidate,
    required this.applicationDate,
    required this.status,
  });

  factory ApplyJobResponse.fromJson(Map<String, dynamic> json) {
    return ApplyJobResponse(
      applicationId: json['application_id'] ?? 0,
      job: json['job'] != null
          ? ApplicationJobSummary.fromJson(json['job'] as Map<String, dynamic>)
          : null,
      candidate: json['candidate'] != null
          ? Candidate.fromJson(json['candidate'] as Map<String, dynamic>)
          : null,
      applicationDate: json['application_date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class ApplyJobErrorData {
  final int? profileCompletion;
  final int? requiredCompletion;
  final bool isFresher;
  final List<String> missingFields;

  ApplyJobErrorData({
    this.profileCompletion,
    this.requiredCompletion,
    this.isFresher = false,
    this.missingFields = const [],
  });

  factory ApplyJobErrorData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ApplyJobErrorData();
    }
    return ApplyJobErrorData(
      profileCompletion: json['profile_completion'] is int
          ? json['profile_completion'] as int
          : int.tryParse(json['profile_completion']?.toString() ?? ''),
      requiredCompletion: json['required_completion'] is int
          ? json['required_completion'] as int
          : int.tryParse(json['required_completion']?.toString() ?? ''),
      isFresher: json['is_fresher'] == true || json['is_fresher'] == 1,
      missingFields: List<String>.from(json['missing_fields'] ?? []),
    );
  }
}

enum ApplicationStatus {
  applied('Applied'),
  reviewed('Reviewed'),
  shortlisted('Shortlisted'),
  interviewed('Interviewed'),
  rejected('Rejected'),
  accepted('Accepted');

  const ApplicationStatus(this.displayName);
  final String displayName;

  static ApplicationStatus fromString(String status) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.displayName.toLowerCase() == status.toLowerCase(),
      orElse: () => ApplicationStatus.applied,
    );
  }
}
