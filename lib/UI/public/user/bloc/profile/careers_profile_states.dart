import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/models/country_model.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:equatable/equatable.dart';

abstract class CareersProfileState extends Equatable {
  const CareersProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends CareersProfileState {
  const ProfileInitial();
}

// Basic profile (get-profile) states
class ProfileLoading extends CareersProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends CareersProfileState {
  final ProfileModel profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends CareersProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Section list (education / experience / family / references / programs)
class ProfileSectionLoading extends CareersProfileState {
  final ProfileSection section;

  const ProfileSectionLoading(this.section);

  @override
  List<Object?> get props => [section];
}

class ProfileSectionError extends CareersProfileState {
  final ProfileSection section;
  final String message;

  const ProfileSectionError(this.section, {required this.message});

  @override
  List<Object?> get props => [section, message];
}

class EducationLoaded extends CareersProfileState {
  final List<EducationRecord> records;

  const EducationLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class ExperienceLoaded extends CareersProfileState {
  final List<ExperienceRecord> records;

  const ExperienceLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class FamilyLoaded extends CareersProfileState {
  final List<FamilyMember> members;

  const FamilyLoaded({required this.members});

  @override
  List<Object?> get props => [members];
}

class ReferencesLoaded extends CareersProfileState {
  final List<Reference> references;

  const ReferencesLoaded({required this.references});

  @override
  List<Object?> get props => [references];
}

class ProfessionalProgramsLoaded extends CareersProfileState {
  final List<ProfessionalProgram> programs;

  const ProfessionalProgramsLoaded({required this.programs});

  @override
  List<Object?> get props => [programs];
}

// Save (update-*) states
class ProfileSaving extends CareersProfileState {
  final ProfileSection section;

  const ProfileSaving(this.section);

  @override
  List<Object?> get props => [section];
}

class ProfileSaved extends CareersProfileState {
  final ProfileSection section;

  const ProfileSaved(this.section);

  @override
  List<Object?> get props => [section];
}

class ProfileSaveError extends CareersProfileState {
  final ProfileSection section;
  final String message;

  const ProfileSaveError(this.section, {required this.message});

  @override
  List<Object?> get props => [section, message];
}

// Profile completion states
class ProfileCompletionLoading extends CareersProfileState {
  const ProfileCompletionLoading();
}

class ProfileCompletionLoaded extends CareersProfileState {
  final ProfileCompletionModel completion;

  const ProfileCompletionLoaded({required this.completion});

  @override
  List<Object?> get props => [completion];
}

class ProfileCompletionError extends CareersProfileState {
  final String message;

  const ProfileCompletionError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Countries states
class CountriesLoading extends CareersProfileState {
  const CountriesLoading();
}

class CountriesLoaded extends CareersProfileState {
  final List<CountryModel> countries;

  const CountriesLoaded({required this.countries});

  @override
  List<Object?> get props => [countries];
}

class CountriesError extends CareersProfileState {
  final String message;

  const CountriesError({required this.message});

  @override
  List<Object?> get props => [message];
}

// File upload states
class ProfileFilesUploading extends CareersProfileState {
  const ProfileFilesUploading();
}

class ProfileFilesUploaded extends CareersProfileState {
  final Map<String, dynamic>? uploadData;

  const ProfileFilesUploaded({this.uploadData});

  @override
  List<Object?> get props => [uploadData];
}

class ProfileFilesUploadError extends CareersProfileState {
  final String message;

  const ProfileFilesUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}
