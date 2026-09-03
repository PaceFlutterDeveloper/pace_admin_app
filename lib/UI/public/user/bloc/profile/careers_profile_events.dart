import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:equatable/equatable.dart';

/// Profile data sections handled by [CareersProfileBloc].
enum ProfileSection {
  basic,
  education,
  experience,
  family,
  references,
  programs,
}

abstract class CareersProfileEvent extends Equatable {
  const CareersProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the candidate's basic profile (`get-profile`).
class LoadProfileEvent extends CareersProfileEvent {
  const LoadProfileEvent();
}

/// Saves the basic info form via JSON `POST /update-profile`.
class SaveBasicInfoEvent extends CareersProfileEvent {
  final Map<String, dynamic> profileData;

  const SaveBasicInfoEvent({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

/// Loads one of the list sections (education, experience, ...).
class LoadProfileSectionEvent extends CareersProfileEvent {
  final ProfileSection section;

  const LoadProfileSectionEvent(this.section);

  @override
  List<Object?> get props => [section];
}

class SaveEducationEvent extends CareersProfileEvent {
  final List<EducationRecord> records;

  const SaveEducationEvent({required this.records});

  @override
  List<Object?> get props => [records];
}

class SaveExperienceEvent extends CareersProfileEvent {
  final List<ExperienceRecord> records;

  const SaveExperienceEvent({required this.records});

  @override
  List<Object?> get props => [records];
}

class SaveFamilyEvent extends CareersProfileEvent {
  final List<FamilyMember> members;

  const SaveFamilyEvent({required this.members});

  @override
  List<Object?> get props => [members];
}

class SaveReferencesEvent extends CareersProfileEvent {
  final List<Reference> references;

  const SaveReferencesEvent({required this.references});

  @override
  List<Object?> get props => [references];
}

class SaveProfessionalProgramsEvent extends CareersProfileEvent {
  final List<ProfessionalProgram> programs;

  const SaveProfessionalProgramsEvent({required this.programs});

  @override
  List<Object?> get props => [programs];
}

/// Checks the API-driven profile completion state (`profile-completion`).
class CheckProfileCompletionEvent extends CareersProfileEvent {
  const CheckProfileCompletionEvent();
}

/// Loads the countries list for nationality / location dropdowns.
class LoadCountriesEvent extends CareersProfileEvent {
  const LoadCountriesEvent();
}

/// Uploads the avatar as multipart on `update-profile-photo`.
class UploadProfileFilesEvent extends CareersProfileEvent {
  final String? avatarFilePath;

  const UploadProfileFilesEvent({this.avatarFilePath});

  @override
  List<Object?> get props => [avatarFilePath];
}
