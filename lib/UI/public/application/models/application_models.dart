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
  final Pagination pagination;

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
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
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
  final Job job;
  final ApplicationDetails application;

  Application({
    required this.applicationId,
    required this.job,
    required this.application,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationId: json['application_id'] ?? 0,
      job: Job.fromJson(json['job'] ?? {}),
      application: ApplicationDetails.fromJson(json['application'] ?? {}),
    );
  }
}

class Job {
  final int id;
  final String title;
  final String location;
  final String employmentType;
  final String salaryRange;
  final String school;

  Job({
    required this.id,
    required this.title,
    required this.location,
    required this.employmentType,
    required this.salaryRange,
    required this.school,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
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
      availabilityOk: json['availability_ok'] ?? false,
      appliedDate: json['applied_date'] ?? '',
      lastActivity: json['last_activity'] ?? '',
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? 20,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
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
