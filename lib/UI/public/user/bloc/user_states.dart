import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';

abstract class UserState {}

// Initial State
class UserInitial extends UserState {}

// Loading States
class UserLoading extends UserState {}

// Login States
class LoginLoading extends UserState {}

class LoginSuccess extends UserState {
  final CareersUserModel user;

  LoginSuccess({required this.user});
}

class LoginError extends UserState {
  final String message;

  LoginError({required this.message});
}

// Signup States
class SignupLoading extends UserState {}

class SignupSuccess extends UserState {
  final CareersUserModel? user;

  SignupSuccess({this.user});
}

class SignupError extends UserState {
  final String message;

  SignupError({required this.message});
}

// Logout States
class LogoutSuccess extends UserState {}

class LogoutError extends UserState {
  final String message;

  LogoutError({required this.message});
}

// Profile Update States
class ProfileUpdateLoading extends UserState {}

class ProfileUpdateSuccess extends UserState {
  final CareersUserModel user;

  ProfileUpdateSuccess({required this.user});
}

class ProfileUpdateError extends UserState {
  final String message;

  ProfileUpdateError({required this.message});
}

// Preferences Update States
class PreferencesUpdateLoading extends UserState {}

class PreferencesUpdateSuccess extends UserState {
  final Map<String, dynamic> preferences;

  PreferencesUpdateSuccess({required this.preferences});
}

class PreferencesUpdateError extends UserState {
  final String message;

  PreferencesUpdateError({required this.message});
}

// User Data States
class UserDataLoaded extends UserState {
  final CareersUserModel user;
  final bool isLoggedIn;

  UserDataLoaded({
    required this.user,
    required this.isLoggedIn,
  });
}

class UserDataEmpty extends UserState {}

// Error State
class UserError extends UserState {
  final String message;

  UserError({required this.message});
}

// Forgot Password States
class ForgotPasswordLoading extends UserState {}

class ForgotPasswordSuccess extends UserState {
  final String message;

  ForgotPasswordSuccess({required this.message});
}

class ForgotPasswordError extends UserState {
  final String message;

  ForgotPasswordError({required this.message});
}

// Reset Password States
class ResetPasswordLoading extends UserState {}

class ResetPasswordSuccess extends UserState {
  final String message;

  ResetPasswordSuccess({required this.message});
}

class ResetPasswordError extends UserState {
  final String message;

  ResetPasswordError({required this.message});
}

// Resend Verification States
class ResendVerificationLoading extends UserState {}

class ResendVerificationSuccess extends UserState {
  final String message;

  ResendVerificationSuccess({required this.message});
}

class ResendVerificationError extends UserState {
  final String message;

  ResendVerificationError({required this.message});
}

// Verify Email States
class VerifyEmailLoading extends UserState {}

class VerifyEmailSuccess extends UserState {
  final String message;

  VerifyEmailSuccess({required this.message});
}

class VerifyEmailError extends UserState {
  final String message;

  VerifyEmailError({required this.message});
}

// Profile Completion States
class ProfileCompletionLoading extends UserState {}

class ProfileCompletionSuccess extends UserState {
  final ProfileCompletionModel profileCompletion;

  ProfileCompletionSuccess({required this.profileCompletion});
}

class ProfileCompletionError extends UserState {
  final String message;

  ProfileCompletionError({required this.message});
}

// Full Profile States
class FullProfileLoading extends UserState {}

class FullProfileSuccess extends UserState {
  final ProfileModel profile;

  FullProfileSuccess({required this.profile});
}

class FullProfileError extends UserState {
  final String message;

  FullProfileError({required this.message});
}

// Profile Data Update States
class ProfileDataUpdateLoading extends UserState {}

class ProfileDataUpdateSuccess extends UserState {
  final Map<String, dynamic> data;

  ProfileDataUpdateSuccess({required this.data});
}

class ProfileDataUpdateError extends UserState {
  final String message;

  ProfileDataUpdateError({required this.message});
}

// Education Update States
class EducationUpdateLoading extends UserState {}

class EducationUpdateSuccess extends UserState {
  final Map<String, dynamic> data;

  EducationUpdateSuccess({required this.data});
}

class EducationUpdateError extends UserState {
  final String message;

  EducationUpdateError({required this.message});
}

// Experience Update States
class ExperienceUpdateLoading extends UserState {}

class ExperienceUpdateSuccess extends UserState {
  final Map<String, dynamic> data;

  ExperienceUpdateSuccess({required this.data});
}

class ExperienceUpdateError extends UserState {
  final String message;

  ExperienceUpdateError({required this.message});
}

// Family Update States
class FamilyUpdateLoading extends UserState {}

class FamilyUpdateSuccess extends UserState {
  final Map<String, dynamic> data;

  FamilyUpdateSuccess({required this.data});
}

class FamilyUpdateError extends UserState {
  final String message;

  FamilyUpdateError({required this.message});
}

// References Update States
class ReferencesUpdateLoading extends UserState {}

class ReferencesUpdateSuccess extends UserState {
  final Map<String, dynamic> data;

  ReferencesUpdateSuccess({required this.data});
}

class ReferencesUpdateError extends UserState {
  final String message;

  ReferencesUpdateError({required this.message});
}

// Professional Programs Update States
class ProfessionalProgramsUpdateLoading extends UserState {}

class ProfessionalProgramsUpdateSuccess extends UserState {
  final Map<String, dynamic> data;

  ProfessionalProgramsUpdateSuccess({required this.data});
}

class ProfessionalProgramsUpdateError extends UserState {
  final String message;

  ProfessionalProgramsUpdateError({required this.message});
}

// Education Loaded States
class EducationLoading extends UserState {}

class EducationLoaded extends UserState {
  final List<EducationRecord> educationRecords;

  EducationLoaded({required this.educationRecords});
}

class EducationError extends UserState {
  final String message;

  EducationError({required this.message});
}

// Experience Loaded States
class ExperienceLoading extends UserState {}

class ExperienceLoaded extends UserState {
  final List<ExperienceRecord> experienceRecords;

  ExperienceLoaded({required this.experienceRecords});
}

class ExperienceError extends UserState {
  final String message;

  ExperienceError({required this.message});
}

// Family Loaded States
class FamilyLoading extends UserState {}

class FamilyLoaded extends UserState {
  final List<FamilyMember> familyMembers;

  FamilyLoaded({required this.familyMembers});
}

class FamilyError extends UserState {
  final String message;

  FamilyError({required this.message});
}

// References Loaded States
class ReferencesLoading extends UserState {}

class ReferencesLoaded extends UserState {
  final List<Reference> references;

  ReferencesLoaded({required this.references});
}

class ReferencesError extends UserState {
  final String message;

  ReferencesError({required this.message});
}

// Professional Programs Loaded States
class ProfessionalProgramsLoading extends UserState {}

class ProfessionalProgramsLoaded extends UserState {
  final List<ProfessionalProgram> programs;

  ProfessionalProgramsLoaded({required this.programs});
}

class ProfessionalProgramsError extends UserState {
  final String message;

  ProfessionalProgramsError({required this.message});
}
