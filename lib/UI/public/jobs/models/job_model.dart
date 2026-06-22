import 'dart:convert';

import 'package:admin_app/UI/public/shared/models/careers_api_models.dart';

class SalaryInfo {
  final String range;
  final int minYears;
  final int? maxYears;

  SalaryInfo({required this.range, required this.minYears, this.maxYears});

  factory SalaryInfo.fromMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return SalaryInfo(range: '', minYears: 0);
    }
    return SalaryInfo(
      range: json['range'] ?? '',
      minYears: json['min_years'] ?? 0,
      maxYears: json['max_years'],
    );
  }

  Map<String, dynamic> toMap() => {
    'range': range,
    'min_years': minYears,
    'max_years': maxYears,
  };
}

class JobModel {
  final int jobId;
  final String title;
  final String location;
  final String schoolName;
  final String? country;
  final String createdAt;
  final String deadline;
  final String description;
  final SalaryInfo? salary;
  final String employmentType;
  final String? qualification;
  final String? requirements;
  final String? department;
  final bool isActive;
  final String status;

  JobModel({
    required this.jobId,
    required this.title,
    required this.location,
    required this.schoolName,
    this.country,
    required this.createdAt,
    required this.deadline,
    required this.description,
    this.salary,
    required this.employmentType,
    this.qualification,
    this.requirements,
    this.department,
    this.isActive = true,
    this.status = 'Open',
  });

  String get id => jobId.toString();
  String get company => schoolName;
  String get salaryRange => salary?.range ?? '';

  DateTime? get postedDate {
    final raw = createdAt.trim();
    if (raw.isEmpty) return null;
    if (raw.contains('/')) {
      final parts = raw.split('/');
      if (parts.length == 3) {
        return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      }
    }
    return DateTime.tryParse(raw);
  }

  String get experienceLevel {
    final min = salary?.minYears ?? 0;
    if (min <= 0) return 'Entry';
    if (min <= 2) return 'Junior';
    if (min <= 5) return 'Mid';
    return 'Senior';
  }

  factory JobModel.fromJson(String str) => JobModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory JobModel.fromMap(Map<String, dynamic> json) => JobModel(
    jobId: json['job_id'] ?? 0,
    title: json['title'] ?? '',
    location: json['location'] ?? '',
    schoolName: json['school_name'] ?? '',
    country: json['country'],
    createdAt: json['posted_date'] ?? json['created_at'] ?? '',
    deadline: json['deadline'] ?? '',
    description: json['description'] is Map
        ? (json['description']['html'] ?? '')
        : (json['description'] ?? ''),
    salary: json['salary'] != null
        ? SalaryInfo.fromMap(json['salary'] as Map<String, dynamic>?)
        : null,
    employmentType: json['employment_type'] ?? '',
    qualification: json['qualification'],
    requirements: json['requirements'] is Map
        ? (json['requirements']['skills'] ?? json['requirements']['qualification'])
        : json['requirements']?.toString(),
    department: json['department'],
    isActive: json['is_active'] ?? true,
    status: json['status'] ?? 'Open',
  );

  Map<String, dynamic> toMap() => {
    'job_id': jobId,
    'title': title,
    'location': location,
    'school_name': schoolName,
    'country': country,
    'posted_date': createdAt,
    'deadline': deadline,
    'description': description,
    if (salary != null) 'salary': salary!.toMap(),
    'employment_type': employmentType,
    if (qualification != null) 'qualification': qualification,
    'requirements': requirements,
    'department': department,
    'is_active': isActive,
    'status': status,
  };

  factory JobModel.fromDetail(JobDetailModel detail) => JobModel(
    jobId: detail.jobId,
    title: detail.title,
    location: detail.location,
    schoolName: detail.school.name,
    country: detail.country.name,
    createdAt: detail.dates.posted,
    deadline: detail.dates.deadline,
    description: detail.descriptionHtml,
    salary: detail.salary,
    employmentType: detail.details.employmentType,
    qualification: detail.requirements.qualification,
    requirements: detail.requirements.skills,
    isActive: detail.dates.isActive,
    status: detail.dates.isActive ? 'Open' : 'Closed',
  );

  JobModel copyWith({
    int? jobId,
    String? title,
    String? location,
    String? schoolName,
    String? country,
    String? createdAt,
    String? deadline,
    String? description,
    SalaryInfo? salary,
    String? employmentType,
    String? qualification,
    String? requirements,
    String? department,
    bool? isActive,
    String? status,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      title: title ?? this.title,
      location: location ?? this.location,
      schoolName: schoolName ?? this.schoolName,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      salary: salary ?? this.salary,
      employmentType: employmentType ?? this.employmentType,
      qualification: qualification ?? this.qualification,
      requirements: requirements ?? this.requirements,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
    );
  }
}

class JobSchoolInfo {
  final String name;
  final String code;
  final String baseUrl;

  const JobSchoolInfo({
    required this.name,
    this.code = '',
    this.baseUrl = '',
  });

  factory JobSchoolInfo.fromJson(Map<String, dynamic>? json) => JobSchoolInfo(
    name: json?['name'] ?? '',
    code: json?['code'] ?? '',
    baseUrl: json?['base_url'] ?? '',
  );
}

class JobCountryInfo {
  final String name;
  final String code;

  const JobCountryInfo({required this.name, this.code = ''});

  factory JobCountryInfo.fromJson(Map<String, dynamic>? json) => JobCountryInfo(
    name: json?['name'] ?? '',
    code: json?['code'] ?? '',
  );
}

class JobDatesInfo {
  final String posted;
  final String deadline;
  final bool isActive;

  const JobDatesInfo({
    required this.posted,
    required this.deadline,
    required this.isActive,
  });

  factory JobDatesInfo.fromJson(Map<String, dynamic>? json) => JobDatesInfo(
    posted: json?['posted'] ?? '',
    deadline: json?['deadline'] ?? '',
    isActive: json?['is_active'] == true || json?['is_active'] == 1,
  );
}

class JobRequirementsInfo {
  final String qualification;
  final int minYears;
  final int? maxYears;
  final String skills;

  const JobRequirementsInfo({
    this.qualification = '',
    this.minYears = 0,
    this.maxYears,
    this.skills = '',
  });

  factory JobRequirementsInfo.fromJson(Map<String, dynamic>? json) =>
      JobRequirementsInfo(
        qualification: json?['qualification'] ?? '',
        minYears: json?['min_years'] ?? 0,
        maxYears: json?['max_years'],
        skills: json?['skills'] ?? '',
      );
}

class JobDetailsInfo {
  final String employmentType;

  const JobDetailsInfo({this.employmentType = ''});

  factory JobDetailsInfo.fromJson(Map<String, dynamic>? json) =>
      JobDetailsInfo(employmentType: json?['employment_type'] ?? '');
}

class JobDetailModel {
  final int jobId;
  final String title;
  final String location;
  final JobSchoolInfo school;
  final JobCountryInfo country;
  final JobDatesInfo dates;
  final String descriptionHtml;
  final SalaryInfo? salary;
  final JobRequirementsInfo requirements;
  final JobDetailsInfo details;

  JobDetailModel({
    required this.jobId,
    required this.title,
    required this.location,
    required this.school,
    required this.country,
    required this.dates,
    required this.descriptionHtml,
    this.salary,
    required this.requirements,
    required this.details,
  });

  factory JobDetailModel.fromJson(Map<String, dynamic> json) => JobDetailModel(
    jobId: json['job_id'] ?? 0,
    title: json['title'] ?? '',
    location: json['location'] ?? '',
    school: JobSchoolInfo.fromJson(json['school'] as Map<String, dynamic>?),
    country: JobCountryInfo.fromJson(json['country'] as Map<String, dynamic>?),
    dates: JobDatesInfo.fromJson(json['dates'] as Map<String, dynamic>?),
    descriptionHtml: json['description']?['html'] ?? '',
    salary: json['salary'] != null
        ? SalaryInfo.fromMap(json['salary'] as Map<String, dynamic>?)
        : null,
    requirements: JobRequirementsInfo.fromJson(
      json['requirements'] as Map<String, dynamic>?,
    ),
    details: JobDetailsInfo.fromJson(json['details'] as Map<String, dynamic>?),
  );

  JobModel toJobModel() => JobModel.fromDetail(this);
}

class JobResponseModel {
  final List<JobModel> data;
  final CareersPagination pagination;

  JobResponseModel({required this.data, required this.pagination});

  int get total => pagination.totalItems;
  int get page => pagination.currentPage;
  int get limit => pagination.itemsPerPage;
  bool get hasNext => pagination.hasNext;
  bool get hasPrev => pagination.hasPrev;
  int get totalPages => pagination.totalPages;

  factory JobResponseModel.fromJson(String str) =>
      JobResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory JobResponseModel.fromMap(Map<String, dynamic> json) =>
      JobResponseModel(
        data: json['data'] == null
            ? []
            : List<JobModel>.from(json['data'].map((x) => JobModel.fromMap(x))),
        pagination: CareersPagination.fromJson(
          json['pagination'] as Map<String, dynamic>?,
        ),
      );

  Map<String, dynamic> toMap() => {
    'data': List<dynamic>.from(data.map((x) => x.toMap())),
    'pagination': pagination.toJson(),
  };
}
