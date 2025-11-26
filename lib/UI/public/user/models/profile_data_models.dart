class ProfileModel {
  final int? candidateId;
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? maritalStatus;
  final String? visaStatus;
  final String? nationality;
  final String? currentLocation;
  final String? provinceState;
  final String? addressLocal;
  final int? nationalityCountryId;
  final int? currentCountryId;
  final double? experienceYears;
  final double? uaeExperienceYears;
  final double? otherExperienceYears;
  final double? currentCtc;
  final double? expectedCtc;
  final String? availableFrom;
  final String? reasonLeaving;
  final bool? convictionYn;
  final String? convictionDetails;
  final bool? govtIssueYn;
  final String? govtIssueDetails;
  final bool? referencePermissionYn;
  final String? noticePeriod;
  final String? preferredPosition;
  final String? avatarFile;
  final String? cvFile;

  ProfileModel({
    this.candidateId,
    this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.maritalStatus,
    this.visaStatus,
    this.nationality,
    this.currentLocation,
    this.provinceState,
    this.addressLocal,
    this.nationalityCountryId,
    this.currentCountryId,
    this.experienceYears,
    this.uaeExperienceYears,
    this.otherExperienceYears,
    this.currentCtc,
    this.expectedCtc,
    this.availableFrom,
    this.reasonLeaving,
    this.convictionYn,
    this.convictionDetails,
    this.govtIssueYn,
    this.govtIssueDetails,
    this.referencePermissionYn,
    this.noticePeriod,
    this.preferredPosition,
    this.avatarFile,
    this.cvFile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      candidateId: json['candidate_id'] ?? json['id'],
      name: json['name'] ?? json['candidate_name'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'],
      maritalStatus: json['marital_status'],
      visaStatus: json['visa_status'],
      nationality: json['nationality'],
      currentLocation: json['current_location'],
      provinceState: json['province_state'],
      addressLocal: json['address_local'],
      nationalityCountryId: json['nationality_country_id'],
      currentCountryId: json['current_country_id'],
      experienceYears: json['experience_years'] != null
          ? double.tryParse(json['experience_years'].toString())
          : null,
      uaeExperienceYears: json['uae_experience_years'] != null
          ? double.tryParse(json['uae_experience_years'].toString())
          : null,
      otherExperienceYears: json['other_experience_years'] != null
          ? double.tryParse(json['other_experience_years'].toString())
          : null,
      currentCtc: json['current_ctc'] != null
          ? double.tryParse(json['current_ctc'].toString())
          : null,
      expectedCtc: json['expected_ctc'] != null
          ? double.tryParse(json['expected_ctc'].toString())
          : null,
      availableFrom: json['available_from'],
      reasonLeaving: json['reason_leaving'],
      convictionYn: json['conviction_yn'] is bool
          ? json['conviction_yn']
          : json['conviction_yn'] == 1 || json['conviction_yn'] == true,
      convictionDetails: json['conviction_details'],
      govtIssueYn: json['govt_issue_yn'] is bool
          ? json['govt_issue_yn']
          : json['govt_issue_yn'] == 1 || json['govt_issue_yn'] == true,
      govtIssueDetails: json['govt_issue_details'],
      referencePermissionYn: json['reference_permission_yn'] is bool
          ? json['reference_permission_yn']
          : json['reference_permission_yn'] == 1 ||
              json['reference_permission_yn'] == true,
      noticePeriod: json['notice_period'],
      preferredPosition: json['preferred_position'],
      avatarFile: json['avatar_file'],
      cvFile: json['cv_file'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cand_id': candidateId,
      'name': name,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'marital_status': maritalStatus,
      'visa_status': visaStatus,
      'nationality': nationality,
      'current_location': currentLocation,
      'province_state': provinceState,
      'address_local': addressLocal,
      'nationality_country_id': nationalityCountryId,
      'current_country_id': currentCountryId,
      'experience_years': experienceYears,
      'uae_experience_years': uaeExperienceYears,
      'other_experience_years': otherExperienceYears,
      'current_ctc': currentCtc,
      'expected_ctc': expectedCtc,
      'available_from': availableFrom,
      'reason_leaving': reasonLeaving,
      'conviction_yn': convictionYn,
      'conviction_details': convictionDetails,
      'govt_issue_yn': govtIssueYn,
      'govt_issue_details': govtIssueDetails,
      'reference_permission_yn': referencePermissionYn,
      'notice_period': noticePeriod,
      'preferred_position': preferredPosition,
      'avatar_file': avatarFile,
      'cv_file': cvFile,
    };
  }

  ProfileModel copyWith({
    int? candidateId,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? maritalStatus,
    String? visaStatus,
    String? nationality,
    String? currentLocation,
    String? provinceState,
    String? addressLocal,
    int? nationalityCountryId,
    int? currentCountryId,
    double? experienceYears,
    double? uaeExperienceYears,
    double? otherExperienceYears,
    double? currentCtc,
    double? expectedCtc,
    String? availableFrom,
    String? reasonLeaving,
    bool? convictionYn,
    String? convictionDetails,
    bool? govtIssueYn,
    String? govtIssueDetails,
    bool? referencePermissionYn,
    String? noticePeriod,
    String? preferredPosition,
    String? avatarFile,
    String? cvFile,
  }) {
    return ProfileModel(
      candidateId: candidateId ?? this.candidateId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      visaStatus: visaStatus ?? this.visaStatus,
      nationality: nationality ?? this.nationality,
      currentLocation: currentLocation ?? this.currentLocation,
      provinceState: provinceState ?? this.provinceState,
      addressLocal: addressLocal ?? this.addressLocal,
      nationalityCountryId: nationalityCountryId ?? this.nationalityCountryId,
      currentCountryId: currentCountryId ?? this.currentCountryId,
      experienceYears: experienceYears ?? this.experienceYears,
      uaeExperienceYears: uaeExperienceYears ?? this.uaeExperienceYears,
      otherExperienceYears: otherExperienceYears ?? this.otherExperienceYears,
      currentCtc: currentCtc ?? this.currentCtc,
      expectedCtc: expectedCtc ?? this.expectedCtc,
      availableFrom: availableFrom ?? this.availableFrom,
      reasonLeaving: reasonLeaving ?? this.reasonLeaving,
      convictionYn: convictionYn,
      convictionDetails: convictionDetails ?? this.convictionDetails,
      govtIssueYn: govtIssueYn,
      govtIssueDetails: govtIssueDetails ?? this.govtIssueDetails,
      referencePermissionYn: referencePermissionYn,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      preferredPosition: preferredPosition,
      avatarFile: avatarFile ?? this.avatarFile,
      cvFile: cvFile ?? this.cvFile,
    );
  }
}

class EducationRecord {
  final int? id;
  final String? qualification;
  final String? institution;
  final String? fieldOfStudy;
  final String? graduationYear;
  final double? gpa;
  final String? grade;

  EducationRecord({
    this.id,
    this.qualification,
    this.institution,
    this.fieldOfStudy,
    this.graduationYear,
    this.gpa,
    this.grade,
  });

  factory EducationRecord.fromJson(Map<String, dynamic> json) {
    return EducationRecord(
      id: json['id'],
      qualification: json['qualification'] ?? json['grade_course'],
      institution: json['institution'] ?? json['board_univ'],
      fieldOfStudy: json['field_of_study'] ?? json['main_subject'],
      graduationYear:
          json['graduation_year'] ?? json['year_passing']?.toString(),
      gpa: json['gpa'] != null
          ? double.tryParse(json['gpa'].toString())
          : (json['percentage'] != null
              ? double.tryParse(json['percentage'].toString())
              : null),
      grade: json['grade'] ?? json['percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qualification': qualification,
      'institution': institution,
      'field_of_study': fieldOfStudy,
      'graduation_year': graduationYear,
      'gpa': gpa,
      'grade': grade,
    };
  }
}

class ExperienceRecord {
  final int? id;
  final String? companyName;
  final String? position;
  final String? startDate;
  final String? endDate;
  final bool? isCurrent;
  final String? jobDescription;
  final String? responsibilities;

  ExperienceRecord({
    this.id,
    this.companyName,
    this.position,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.jobDescription,
    this.responsibilities,
  });

  factory ExperienceRecord.fromJson(Map<String, dynamic> json) {
    return ExperienceRecord(
      id: json['id'],
      companyName: json['company_name'] ?? json['organization'],
      position: json['position'] ?? json['designation'],
      startDate: json['start_date'] ?? json['from_date'],
      endDate: json['end_date'] ?? json['to_date'],
      isCurrent: json['is_current'] == 1 ||
          json['is_current'] == true ||
          json['current_role_yn'] == 1 ||
          json['current_role_yn'] == true,
      jobDescription: json['job_description'] ?? json['job_desc'],
      responsibilities: json['responsibilities'] ?? json['job_desc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'position': position,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent == true ? 1 : 0,
      'job_description': jobDescription,
      'responsibilities': responsibilities,
    };
  }
}

class FamilyMember {
  final int? id;
  final String? name;
  final String? relationship;
  final String? occupation;
  final String? phone;
  final String? email;

  FamilyMember({
    this.id,
    this.name,
    this.relationship,
    this.occupation,
    this.phone,
    this.email,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      name: json['name'],
      relationship: json['relationship'] ?? json['relation'],
      occupation: json['occupation'] ?? json['profession'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'occupation': occupation,
      'phone': phone,
      'email': email,
    };
  }
}

class Reference {
  final int? id;
  final String? name;
  final String? position;
  final String? organization;
  final String? phone;
  final String? email;
  final String? relationship;

  Reference({
    this.id,
    this.name,
    this.position,
    this.organization,
    this.phone,
    this.email,
    this.relationship,
  });

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(
      id: json['id'],
      name: json['name'] ?? json['ref_name'],
      position: json['position'] ?? json['designation'],
      organization: json['organization'],
      phone: json['phone'] ?? json['contact_no'],
      email: json['email'],
      relationship: json['relationship'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'organization': organization,
      'phone': phone,
      'email': email,
      'relationship': relationship,
    };
  }
}

class ProfessionalProgram {
  final int? id;
  final String? programName;
  final String? institution;
  final String? completionDate;
  final String? certificateNumber;
  final String? expiryDate;

  ProfessionalProgram({
    this.id,
    this.programName,
    this.institution,
    this.completionDate,
    this.certificateNumber,
    this.expiryDate,
  });

  factory ProfessionalProgram.fromJson(Map<String, dynamic> json) {
    return ProfessionalProgram(
      id: json['id'],
      programName: json['program_name'] ?? json['course_name'],
      institution: json['institution'] ?? json['institute'],
      completionDate: json['completion_date'] ??
          (json['year_passing'] != null
              ? json['year_passing'].toString()
              : null),
      certificateNumber: json['certificate_number'],
      expiryDate: json['expiry_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_name': programName,
      'institution': institution,
      'completion_date': completionDate,
      'certificate_number': certificateNumber,
      'expiry_date': expiryDate,
    };
  }
}

class CompleteProfileModel {
  final int candidateId;
  final ProfileModel profile;
  final List<EducationRecord> educationRecords;
  final List<ExperienceRecord> experienceRecords;
  final List<FamilyMember> familyMembers;
  final List<Reference> references;
  final List<ProfessionalProgram> professionalPrograms;

  CompleteProfileModel({
    required this.candidateId,
    required this.profile,
    required this.educationRecords,
    required this.experienceRecords,
    required this.familyMembers,
    required this.references,
    required this.professionalPrograms,
  });

  factory CompleteProfileModel.fromJson(Map<String, dynamic> json) {
    return CompleteProfileModel(
      candidateId: json['candidate_id'] ?? json['cand_id'],
      profile: ProfileModel.fromJson(json['candidate'] ?? json),
      educationRecords: (json['education_records'] as List<dynamic>?)
              ?.map((e) => EducationRecord.fromJson(e))
              .toList() ??
          [],
      experienceRecords: (json['experience_records'] as List<dynamic>?)
              ?.map((e) => ExperienceRecord.fromJson(e))
              .toList() ??
          [],
      familyMembers: (json['family_members'] as List<dynamic>?)
              ?.map((e) => FamilyMember.fromJson(e))
              .toList() ??
          [],
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => Reference.fromJson(e))
              .toList() ??
          [],
      professionalPrograms: (json['professional_programs'] as List<dynamic>?)
              ?.map((e) => ProfessionalProgram.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cand_id': candidateId,
      ...profile.toJson(),
      'education_records': educationRecords.map((e) => e.toJson()).toList(),
      'experience_records': experienceRecords.map((e) => e.toJson()).toList(),
      'family_members': familyMembers.map((e) => e.toJson()).toList(),
      'references': references.map((e) => e.toJson()).toList(),
      'professional_programs':
          professionalPrograms.map((e) => e.toJson()).toList(),
    };
  }
}
