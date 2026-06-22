import 'package:admin_app/UI/public/user/utils/careers_api_dates.dart';

class ProfileModel {
  final int? candidateId;
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? visaStatus;
  final String? visaExpDate;
  final String? nationality;
  final String? nationalityCountry;
  final String? currentCountry;
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
  final bool? portalVisibility;
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
    this.gender,
    this.maritalStatus,
    this.visaStatus,
    this.visaExpDate,
    this.nationality,
    this.nationalityCountry,
    this.currentCountry,
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
    this.portalVisibility,
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
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      visaStatus: json['visa_status'],
      visaExpDate: json['visa_exp_date'],
      nationality: json['nationality'],
      nationalityCountry: json['nationality_country'],
      currentCountry: json['current_country'],
      currentLocation: json['current_location'],
      provinceState: json['province_state'],
      addressLocal: json['address_local'],
      nationalityCountryId:
          json['nationality_country_id'] ?? json['nationality_id'],
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
      availableFrom: CareersApiDates.normalizeFromApi(json['available_from']),
      reasonLeaving: _normalizeTextField(json['reason_leaving']),
      convictionYn: _parseBool(json['conviction_yn']),
      convictionDetails: json['conviction_details'],
      govtIssueYn: _parseBool(json['govt_issue_yn']),
      govtIssueDetails: json['govt_issue_details'],
      referencePermissionYn: _parseBool(json['reference_permission_yn']),
      portalVisibility: _parseBool(json['portal_visibility']),
      noticePeriod: json['notice_period'],
      preferredPosition: _normalizeTextField(json['preferred_position']),
      avatarFile: _normalizeTextField(
        json['avatar_file'] ?? json['profile_image'] ?? json['avatar'],
      ),
      cvFile: _normalizeTextField(
        json['cv_file'] ?? json['resume_url'] ?? json['cv'],
      ),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    return value == 1 || value == true;
  }

  static String? _normalizeTextField(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }


  Map<String, dynamic> toJson() {
    return {
      if (candidateId != null) 'cand_id': candidateId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (visaStatus != null) 'visa_status': visaStatus,
      if (visaExpDate != null) 'visa_exp_date': visaExpDate,
      if (nationality != null) 'nationality': nationality,
      if (currentLocation != null) 'current_location': currentLocation,
      if (provinceState != null) 'province_state': provinceState,
      if (addressLocal != null) 'address_local': addressLocal,
      if (nationalityCountryId != null)
        'nationality_country_id': nationalityCountryId,
      if (nationalityCountryId != null) 'nationality_id': nationalityCountryId,
      if (currentCountryId != null) 'current_country_id': currentCountryId,
      if (experienceYears != null) 'experience_years': experienceYears,
      if (uaeExperienceYears != null) 'uae_experience_years': uaeExperienceYears,
      if (otherExperienceYears != null)
        'other_experience_years': otherExperienceYears,
      if (currentCtc != null) 'current_ctc': currentCtc,
      if (expectedCtc != null) 'expected_ctc': expectedCtc,
      if (availableFrom != null) 'available_from': availableFrom,
      if (reasonLeaving != null) 'reason_leaving': reasonLeaving,
      if (convictionYn != null) 'conviction_yn': convictionYn! ? 1 : 0,
      if (convictionDetails != null) 'conviction_details': convictionDetails,
      if (govtIssueYn != null) 'govt_issue_yn': govtIssueYn! ? 1 : 0,
      if (govtIssueDetails != null) 'govt_issue_details': govtIssueDetails,
      if (referencePermissionYn != null)
        'reference_permission_yn': referencePermissionYn! ? 1 : 0,
      if (portalVisibility != null)
        'portal_visibility': portalVisibility! ? 1 : 0,
      if (noticePeriod != null) 'notice_period': noticePeriod,
      if (preferredPosition != null) 'preferred_position': preferredPosition,
      if (avatarFile != null) 'avatar_file': avatarFile,
      if (cvFile != null) 'cv_file': cvFile,
    };
  }

  ProfileModel copyWith({
    int? candidateId,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? visaStatus,
    String? visaExpDate,
    String? nationality,
    String? nationalityCountry,
    String? currentCountry,
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
    bool? portalVisibility,
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
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      visaStatus: visaStatus ?? this.visaStatus,
      visaExpDate: visaExpDate ?? this.visaExpDate,
      nationality: nationality ?? this.nationality,
      nationalityCountry: nationalityCountry ?? this.nationalityCountry,
      currentCountry: currentCountry ?? this.currentCountry,
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
      portalVisibility: portalVisibility,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      preferredPosition: preferredPosition ?? this.preferredPosition,
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
      grade: json['grade'] ?? json['percentage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final year = int.tryParse(graduationYear ?? '');
    return {
      if (id != null) 'id': id,
      if (qualification != null && qualification!.isNotEmpty)
        'grade_course': qualification,
      if (institution != null && institution!.isNotEmpty)
        'board_univ': institution,
      if (fieldOfStudy != null && fieldOfStudy!.isNotEmpty)
        'main_subject': fieldOfStudy,
      if (graduationYear != null && graduationYear!.isNotEmpty)
        'year_passing': year ?? graduationYear,
      if (gpa != null)
        'percentage': gpa.toString()
      else if (grade != null && grade!.isNotEmpty)
        'percentage': grade,
    };
  }
}

class ExperienceRecord {
  final int? id;
  final String? companyName;
  final String? position;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool? isCurrent;
  final String? jobDescription;

  ExperienceRecord({
    this.id,
    this.companyName,
    this.position,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.jobDescription,
  });

  factory ExperienceRecord.fromJson(Map<String, dynamic> json) {
    return ExperienceRecord(
      id: json['id'],
      companyName: json['company_name'] ?? json['organization'],
      position: json['position'] ?? json['designation'],
      location: json['location'] ?? json['ex_location'],
      startDate: json['start_date'] ?? json['from_date'],
      endDate: json['end_date'] ?? json['to_date'],
      isCurrent:
          json['is_current'] == 1 ||
          json['is_current'] == true ||
          json['current_role_yn'] == 1 ||
          json['current_role_yn'] == true,
      jobDescription: json['job_description'] ?? json['job_desc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (companyName != null && companyName!.isNotEmpty)
        'organization': companyName,
      if (position != null && position!.isNotEmpty) 'designation': position,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (startDate != null && startDate!.isNotEmpty) 'from_date': startDate,
      if (endDate != null && endDate!.isNotEmpty) 'to_date': endDate,
      if (jobDescription != null && jobDescription!.isNotEmpty)
        'job_desc': jobDescription,
      'current_role_yn': isCurrent == true ? 1 : 0,
    };
  }
}

class FamilyMember {
  final int? id;
  final String? name;
  final String? relationship;
  final String? occupation;
  final int? age;
  final bool? dependentYn;

  FamilyMember({
    this.id,
    this.name,
    this.relationship,
    this.occupation,
    this.age,
    this.dependentYn,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      name: json['name'] ?? json['fam_name'],
      relationship: json['relationship'] ?? json['relation'],
      occupation: json['occupation'] ?? json['profession'],
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? ''),
      dependentYn:
          json['dependent_yn'] == 1 ||
          json['dependent_yn'] == true ||
          json['fam_dependent'] == 1 ||
          json['fam_dependent'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null && name!.isNotEmpty) 'name': name,
      if (relationship != null && relationship!.isNotEmpty)
        'relation': relationship,
      if (occupation != null && occupation!.isNotEmpty)
        'profession': occupation,
      if (age != null) 'age': age,
      if (dependentYn != null) 'dependent_yn': dependentYn! ? 1 : 0,
    };
  }
}

class Reference {
  final int? id;
  final String? name;
  final String? position;
  final String? address;
  final String? phone;

  Reference({
    this.id,
    this.name,
    this.position,
    this.address,
    this.phone,
  });

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(
      id: json['id'],
      name: json['name'] ?? json['ref_name'],
      position: json['position'] ?? json['designation'],
      address: json['address'] ?? json['ref_address'],
      phone: json['phone'] ?? json['contact_no'] ?? json['ref_contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null && name!.isNotEmpty) 'ref_name': name,
      if (position != null && position!.isNotEmpty) 'designation': position,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (phone != null && phone!.isNotEmpty) 'contact_no': phone,
    };
  }
}

class ProfessionalProgram {
  final int? id;
  final String? programName;
  final String? institution;
  final String? durationText;
  final String? place;
  final String? yearPassing;

  ProfessionalProgram({
    this.id,
    this.programName,
    this.institution,
    this.durationText,
    this.place,
    this.yearPassing,
  });

  factory ProfessionalProgram.fromJson(Map<String, dynamic> json) {
    return ProfessionalProgram(
      id: json['id'],
      programName: json['program_name'] ?? json['course_name'] ?? json['pp_course'],
      institution: json['institution'] ?? json['institute'] ?? json['pp_institute'],
      durationText: json['duration_txt'] ?? json['pp_duration'],
      place: json['place'] ?? json['pp_place'],
      yearPassing:
          json['year_passing']?.toString() ??
          json['completion_date'] ??
          json['pp_year']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final year = int.tryParse(yearPassing ?? '');
    return {
      if (id != null) 'id': id,
      if (programName != null && programName!.isNotEmpty)
        'course_name': programName,
      if (institution != null && institution!.isNotEmpty)
        'institute': institution,
      if (durationText != null && durationText!.isNotEmpty)
        'duration_txt': durationText,
      if (place != null && place!.isNotEmpty) 'place': place,
      if (yearPassing != null && yearPassing!.isNotEmpty)
        'year_passing': year ?? yearPassing,
    };
  }
}

class FullProfileResponse {
  final ProfileModel candidate;
  final List<EducationRecord> educationRecords;
  final List<ExperienceRecord> experienceRecords;
  final List<FamilyMember> familyMembers;
  final List<Reference> references;
  final List<ProfessionalProgram> professionalPrograms;

  FullProfileResponse({
    required this.candidate,
    required this.educationRecords,
    required this.experienceRecords,
    required this.familyMembers,
    required this.references,
    required this.professionalPrograms,
  });

  factory FullProfileResponse.fromJson(Map<String, dynamic> json) {
    return FullProfileResponse(
      candidate: ProfileModel.fromJson(json['candidate'] ?? {}),
      educationRecords:
          (json['education_records'] as List<dynamic>?)
              ?.map((e) => EducationRecord.fromJson(e))
              .toList() ??
          [],
      experienceRecords:
          (json['experience_records'] as List<dynamic>?)
              ?.map((e) => ExperienceRecord.fromJson(e))
              .toList() ??
          [],
      familyMembers:
          (json['family_members'] as List<dynamic>?)
              ?.map((e) => FamilyMember.fromJson(e))
              .toList() ??
          [],
      references:
          (json['references'] as List<dynamic>?)
              ?.map((e) => Reference.fromJson(e))
              .toList() ??
          [],
      professionalPrograms:
          (json['professional_programs'] as List<dynamic>?)
              ?.map((e) => ProfessionalProgram.fromJson(e))
              .toList() ??
          [],
    );
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
      educationRecords:
          (json['education_records'] as List<dynamic>?)
              ?.map((e) => EducationRecord.fromJson(e))
              .toList() ??
          [],
      experienceRecords:
          (json['experience_records'] as List<dynamic>?)
              ?.map((e) => ExperienceRecord.fromJson(e))
              .toList() ??
          [],
      familyMembers:
          (json['family_members'] as List<dynamic>?)
              ?.map((e) => FamilyMember.fromJson(e))
              .toList() ??
          [],
      references:
          (json['references'] as List<dynamic>?)
              ?.map((e) => Reference.fromJson(e))
              .toList() ??
          [],
      professionalPrograms:
          (json['professional_programs'] as List<dynamic>?)
              ?.map((e) => ProfessionalProgram.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory CompleteProfileModel.fromFullProfile(FullProfileResponse full) {
    return CompleteProfileModel(
      candidateId: full.candidate.candidateId ?? 0,
      profile: full.candidate,
      educationRecords: full.educationRecords,
      experienceRecords: full.experienceRecords,
      familyMembers: full.familyMembers,
      references: full.references,
      professionalPrograms: full.professionalPrograms,
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
      'professional_programs': professionalPrograms
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
