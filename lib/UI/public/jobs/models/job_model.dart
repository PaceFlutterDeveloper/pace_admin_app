import 'dart:convert';

class SalaryInfo {
  final String range;
  final int minYears;
  final int? maxYears;

  SalaryInfo({required this.range, required this.minYears, this.maxYears});

  factory SalaryInfo.fromMap(Map<String, dynamic> json) => SalaryInfo(
    range: json["range"] ?? "",
    minYears: json["min_years"] ?? 0,
    maxYears: json["max_years"],
  );

  Map<String, dynamic> toMap() => {
    "range": range,
    "min_years": minYears,
    "max_years": maxYears,
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
  final SalaryInfo salary;
  final String employmentType;
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
    required this.salary,
    required this.employmentType,
    this.requirements,
    this.department,
    this.isActive = true,
    this.status = 'Open',
  });

  // Legacy getters for backward compatibility
  String get id => jobId.toString();
  String get company => schoolName;
  DateTime get postedDate =>
      DateTime.parse(createdAt.split('/').reversed.join('-'));
  String get experienceLevel => 'Entry'; // Default since not in API
  String get salaryRange => salary.range;

  factory JobModel.fromJson(String str) => JobModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory JobModel.fromMap(Map<String, dynamic> json) => JobModel(
    jobId: json["job_id"] ?? 0,
    title: json["title"] ?? "",
    location: json["location"] ?? "",
    schoolName: json["school_name"] ?? "",
    country: json["country"],
    createdAt: json["created_at"] ?? "",
    deadline: json["deadline"] ?? "",
    description: json["description"] ?? "",
    salary: SalaryInfo.fromMap(json["salary"] ?? {}),
    employmentType: json["employment_type"] ?? "",
    requirements: json["requirements"],
    department: json["department"],
    isActive: json["is_active"] ?? true,
    status: json["status"] ?? "Open",
  );

  Map<String, dynamic> toMap() => {
    "job_id": jobId,
    "title": title,
    "location": location,
    "school_name": schoolName,
    "country": country,
    "created_at": createdAt,
    "deadline": deadline,
    "description": description,
    "salary": salary.toMap(),
    "employment_type": employmentType,
    "requirements": requirements,
    "department": department,
    "is_active": isActive,
    "status": status,
  };

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
      requirements: requirements ?? this.requirements,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
    );
  }
}

class JobResponseModel {
  final List<JobModel> data;
  final int total;
  final int page;
  final int limit;

  JobResponseModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory JobResponseModel.fromJson(String str) =>
      JobResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory JobResponseModel.fromMap(Map<String, dynamic> json) =>
      JobResponseModel(
        data: json["data"] == null
            ? []
            : List<JobModel>.from(json["data"].map((x) => JobModel.fromMap(x))),
        total: json["total"] ?? 0,
        page: json["page"] ?? 1,
        limit: json["limit"] ?? 10,
      );

  Map<String, dynamic> toMap() => {
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
    "total": total,
    "page": page,
    "limit": limit,
  };
}
