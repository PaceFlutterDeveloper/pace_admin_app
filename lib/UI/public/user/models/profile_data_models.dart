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
  final List<String> topics;

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
    this.topics = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      candidateId: json['candidate_id'] ?? json['id'],
      name: json['name'] ?? json['candidate_name'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: CareersApiDates.normalizeFromApi(json['date_of_birth']),
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      visaStatus: json['visa_status'],
      visaExpDate: CareersApiDates.normalizeFromApi(json['visa_exp_date']),
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
      avatarFile: _photoField(json),
      cvFile: _normalizeTextField(
        json['cv_file'] ?? json['resume_url'] ?? json['cv'],
      ),
      topics: parseFcmTopics(json['topics']),
    );
  }

  static List<String> parseFcmTopics(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((value) => value.toString().trim())
        .where((topic) => topic.isNotEmpty)
        .toList();
  }

  static bool? _parseBool(dynamic value) => parseCareersYn(value);

  static String? _normalizeTextField(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null' || text == '0') {
      return null;
    }
    return text;
  }

  static String? _photoField(Map<String, dynamic> json) {
    for (final key in [
      'avatar_file',
      'profile_image',
      'avatar',
      'photo',
      'profile_photo',
    ]) {
      final parsed = _photoValue(json[key]);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String? _photoValue(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return _photoValue(
        value['path'] ??
            value['url'] ??
            value['file'] ??
            value['avatar_file'] ??
            value['photo'] ??
            value['src'],
      );
    }
    return _normalizeTextField(value);
  }


  Map<String, dynamic> toJson() {
    return {
      if (candidateId != null) 'cand_id': candidateId,
      if (name != null) 'candidate_name': name,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (visaStatus != null) 'visa_status': visaStatus,
      if (visaExpDate != null) 'visa_exp_date': visaExpDate,
      if (currentLocation != null) 'current_location': currentLocation,
      if (provinceState != null) 'province_state': provinceState,
      if (addressLocal != null) 'address_local': addressLocal,
      if (nationalityCountryId != null && nationalityCountryId! > 0)
        'nationality_country_id': nationalityCountryId,
      if (currentCountryId != null && currentCountryId! > 0)
        'current_country_id': currentCountryId,
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
      if (noticePeriod != null) 'notice_period': noticePeriod,
      if (preferredPosition != null) 'preferred_position': preferredPosition,
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
    List<String>? topics,
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
      convictionYn: convictionYn ?? this.convictionYn,
      convictionDetails: convictionDetails ?? this.convictionDetails,
      govtIssueYn: govtIssueYn ?? this.govtIssueYn,
      govtIssueDetails: govtIssueDetails ?? this.govtIssueDetails,
      referencePermissionYn:
          referencePermissionYn ?? this.referencePermissionYn,
      portalVisibility: portalVisibility ?? this.portalVisibility,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      preferredPosition: preferredPosition ?? this.preferredPosition,
      avatarFile: avatarFile ?? this.avatarFile,
      cvFile: cvFile ?? this.cvFile,
      topics: topics ?? this.topics,
    );
  }
}

int? _careersRecordId(Map<String, dynamic> json, String altKey) {
  final raw = json['id'] ?? json[altKey];
  if (raw is int) return raw;
  return int.tryParse(raw?.toString() ?? '');
}

/// Parses `*_yn` flags from GET payloads (`1`/`0`, bool, or `"1"`/`"0"`).
bool? parseCareersYn(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return null;
  if (text == '1' || text == 'true' || text == 'yes' || text == 'y') {
    return true;
  }
  if (text == '0' || text == 'false' || text == 'no' || text == 'n') {
    return false;
  }
  return null;
}

List<T> mapCareersSectionRows<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is! List) return [];
  return raw
      .whereType<Map>()
      .map((row) => fromJson(Map<String, dynamic>.from(row)))
      .toList();
}

class EducationRecord {
  final int? id;
  final String? qualification;
  final String? institution;
  final String? fieldOfStudy;
  final String? graduationYear;
  final String? percentage;

  EducationRecord({
    this.id,
    this.qualification,
    this.institution,
    this.fieldOfStudy,
    this.graduationYear,
    this.percentage,
  });

  bool get isValidForApi {
    return (qualification?.trim().isNotEmpty ?? false) &&
        (institution?.trim().isNotEmpty ?? false);
  }

  factory EducationRecord.fromJson(Map<String, dynamic> json) {
    return EducationRecord(
      id: _careersRecordId(json, 'edu_id'),
      qualification:
          json['grade_course'] ?? json['edu_course'] ?? json['qualification'],
      institution: json['board_univ'] ?? json['edu_board'] ?? json['institution'],
      fieldOfStudy:
          json['main_subject'] ?? json['edu_subject'] ?? json['field_of_study'],
      graduationYear:
          json['year_passing']?.toString() ??
          json['edu_year']?.toString() ??
          json['graduation_year']?.toString(),
      percentage:
          json['percentage']?.toString() ?? json['edu_percent']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final year = int.tryParse(graduationYear ?? '');
    return {
      if (qualification != null && qualification!.isNotEmpty)
        'grade_course': qualification,
      if (institution != null && institution!.isNotEmpty)
        'board_univ': institution,
      if (fieldOfStudy != null && fieldOfStudy!.isNotEmpty)
        'main_subject': fieldOfStudy,
      if (graduationYear != null && graduationYear!.isNotEmpty)
        'year_passing': year ?? graduationYear,
      if (percentage != null && percentage!.isNotEmpty) 'percentage': percentage,
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

  bool get isValidForApi => companyName?.trim().isNotEmpty ?? false;

  factory ExperienceRecord.fromJson(Map<String, dynamic> json) {
    return ExperienceRecord(
      id: _careersRecordId(json, 'exp_id'),
      companyName:
          json['organization'] ?? json['ex_org'] ?? json['company_name'],
      position: json['designation'] ?? json['ex_designation'] ?? json['position'],
      location: json['location'] ?? json['ex_location'],
      startDate: CareersApiDates.normalizeFromApi(
        json['from_date'] ?? json['ex_from'] ?? json['start_date'],
      ),
      endDate: CareersApiDates.normalizeFromApi(
        json['to_date'] ?? json['ex_to'] ?? json['end_date'],
      ),
      isCurrent:
          parseCareersYn(json['current_role_yn']) ??
          parseCareersYn(json['ex_current']) ??
          parseCareersYn(json['is_current']) ??
          false,
      jobDescription: json['job_desc'] ?? json['ex_desc'] ?? json['job_description'],
    );
  }

  Map<String, dynamic> toJson() {
    final current = isCurrent == true;
    return {
      if (companyName != null && companyName!.isNotEmpty)
        'organization': companyName,
      if (position != null && position!.isNotEmpty) 'designation': position,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (startDate != null && startDate!.isNotEmpty)
        'from_date': CareersApiDates.formatForApi(startDate) ?? startDate,
      if (!current && endDate != null && endDate!.isNotEmpty)
        'to_date': CareersApiDates.formatForApi(endDate) ?? endDate,
      if (jobDescription != null && jobDescription!.isNotEmpty)
        'job_desc': jobDescription,
      'current_role_yn': current ? 1 : 0,
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

  bool get isValidForApi {
    return (name?.trim().isNotEmpty ?? false) &&
        (relationship?.trim().isNotEmpty ?? false);
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: _careersRecordId(json, 'fam_id'),
      name: json['name'] ?? json['fam_name'],
      relationship: json['relation'] ?? json['fam_relation'] ?? json['relationship'],
      occupation: json['profession'] ?? json['fam_profession'] ?? json['occupation'],
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(
              (json['age'] ?? json['fam_age'])?.toString() ?? '',
            ),
      dependentYn:
          parseCareersYn(json['dependent_yn']) ??
          parseCareersYn(json['fam_dependent']) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null && name!.isNotEmpty) 'name': name,
      if (relationship != null && relationship!.isNotEmpty)
        'relation': relationship,
      if (occupation != null && occupation!.isNotEmpty)
        'profession': occupation,
      if (age != null) 'age': age,
      'dependent_yn': dependentYn == true ? 1 : 0,
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

  bool get isValidForApi => name?.trim().isNotEmpty ?? false;

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(
      id: _careersRecordId(json, 'ref_id'),
      name: json['ref_name'] ?? json['name'],
      position: json['designation'] ?? json['ref_designation'] ?? json['position'],
      address: json['address'] ?? json['ref_address'],
      phone: json['contact_no'] ?? json['ref_contact'] ?? json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  bool get isValidForApi => programName?.trim().isNotEmpty ?? false;

  factory ProfessionalProgram.fromJson(Map<String, dynamic> json) {
    return ProfessionalProgram(
      id: _careersRecordId(json, 'prog_id'),
      programName:
          json['course_name'] ?? json['pp_course'] ?? json['program_name'],
      institution:
          json['institute'] ?? json['pp_institute'] ?? json['institution'],
      durationText: json['duration_txt'] ?? json['pp_duration'],
      place: json['place'] ?? json['pp_place'],
      yearPassing:
          json['year_passing']?.toString() ?? json['pp_year']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final year = int.tryParse(yearPassing ?? '');
    return {
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
      educationRecords: mapCareersSectionRows(
        json['education_records'],
        EducationRecord.fromJson,
      ),
      experienceRecords: mapCareersSectionRows(
        json['experience_records'],
        ExperienceRecord.fromJson,
      ),
      familyMembers: mapCareersSectionRows(
        json['family_members'],
        FamilyMember.fromJson,
      ),
      references: mapCareersSectionRows(
        json['references'],
        Reference.fromJson,
      ),
      professionalPrograms: mapCareersSectionRows(
        json['professional_programs'],
        ProfessionalProgram.fromJson,
      ),
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
      educationRecords: mapCareersSectionRows(
        json['education_records'],
        EducationRecord.fromJson,
      ),
      experienceRecords: mapCareersSectionRows(
        json['experience_records'],
        ExperienceRecord.fromJson,
      ),
      familyMembers: mapCareersSectionRows(
        json['family_members'],
        FamilyMember.fromJson,
      ),
      references: mapCareersSectionRows(
        json['references'],
        Reference.fromJson,
      ),
      professionalPrograms: mapCareersSectionRows(
        json['professional_programs'],
        ProfessionalProgram.fromJson,
      ),
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
      'professional_programs':
          professionalPrograms.map((e) => e.toJson()).toList(),
    };
  }
}
