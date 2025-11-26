import 'package:admin_app/UI/public/user/models/profile_data_models.dart';

abstract class UserEvent {}

// Login Events
class LoginEvent extends UserEvent {
  final String email;
  final String password;

  LoginEvent({
    required this.email,
    required this.password,
  });
}

// Signup Events
class SignupEvent extends UserEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? preferredLocation;
  final List<String> skills;

  SignupEvent({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.preferredLocation,
    this.skills = const [],
  });
}

// Logout Events
class LogoutEvent extends UserEvent {}

// Profile Update Events
class UpdateProfileEvent extends UserEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String? resumeUrl;

  final String? preferredLocation;
  final String? experienceLevel;

  UpdateProfileEvent({
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.resumeUrl,
    this.preferredLocation,
    this.experienceLevel,
  });
}

// Preferences Update Events
class UpdatePreferencesEvent extends UserEvent {
  final Map<String, dynamic> preferences;

  UpdatePreferencesEvent({
    required this.preferences,
  });
}

// Update Preferred Schools Event
class UpdatePreferredSchoolsEvent extends UserEvent {
  final List<int> schoolIds;

  UpdatePreferredSchoolsEvent({
    required this.schoolIds,
  });
}

// Update Skills Event
class UpdateSkillsEvent extends UserEvent {
  final List<String> skills;

  UpdateSkillsEvent({
    required this.skills,
  });
}

// Check Login Status Event
class CheckLoginStatusEvent extends UserEvent {}

// Clear User Data Event
class ClearUserDataEvent extends UserEvent {}

// Forgot Password Event
class ForgotPasswordEvent extends UserEvent {
  final String email;

  ForgotPasswordEvent({required this.email});
}

// Reset Password Event
class ResetPasswordEvent extends UserEvent {
  final String token;
  final String password;
  final String confirmPassword;

  ResetPasswordEvent({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });
}

// Resend Verification Event
class ResendVerificationEvent extends UserEvent {
  final String email;

  ResendVerificationEvent({required this.email});
}

// Verify Email Event
class VerifyEmailEvent extends UserEvent {
  final String token;

  VerifyEmailEvent({required this.token});
}

// Check Profile Completion Event
class CheckProfileCompletionEvent extends UserEvent {
  final String candidateId;

  CheckProfileCompletionEvent({required this.candidateId});
}

// Get Full Profile Event
class GetFullProfileEvent extends UserEvent {
  final int candidateId;

  GetFullProfileEvent({required this.candidateId});
}

// Update Profile Data Event
class UpdateProfileDataEvent extends UserEvent {
  final int candidateId;
  final Map<String, dynamic> profileData;

  UpdateProfileDataEvent({
    required this.candidateId,
    required this.profileData,
  });
}

// Update Education Event
class UpdateEducationEvent extends UserEvent {
  final int candidateId;
  final List<EducationRecord> educationRecords;

  UpdateEducationEvent({
    required this.candidateId,
    required this.educationRecords,
  });
}

// Update Experience Event
class UpdateExperienceEvent extends UserEvent {
  final int candidateId;
  final List<ExperienceRecord> experienceRecords;

  UpdateExperienceEvent({
    required this.candidateId,
    required this.experienceRecords,
  });
}

// Update Family Event
class UpdateFamilyEvent extends UserEvent {
  final int candidateId;
  final List<FamilyMember> familyMembers;

  UpdateFamilyEvent({
    required this.candidateId,
    required this.familyMembers,
  });
}

// Update References Event
class UpdateReferencesEvent extends UserEvent {
  final int candidateId;
  final List<Reference> references;

  UpdateReferencesEvent({
    required this.candidateId,
    required this.references,
  });
}

// Update Professional Programs Event
class UpdateProfessionalProgramsEvent extends UserEvent {
  final int candidateId;
  final List<ProfessionalProgram> programs;

  UpdateProfessionalProgramsEvent({
    required this.candidateId,
    required this.programs,
  });
}

// Get Education Event
class GetEducationEvent extends UserEvent {
  final int candidateId;

  GetEducationEvent({required this.candidateId});
}

// Get Experience Event
class GetExperienceEvent extends UserEvent {
  final int candidateId;

  GetExperienceEvent({required this.candidateId});
}

// Get Family Event
class GetFamilyEvent extends UserEvent {
  final int candidateId;

  GetFamilyEvent({required this.candidateId});
}

// Get References Event
class GetReferencesEvent extends UserEvent {
  final int candidateId;

  GetReferencesEvent({required this.candidateId});
}

// Get Professional Programs Event
class GetProfessionalProgramsEvent extends UserEvent {
  final int candidateId;

  GetProfessionalProgramsEvent({required this.candidateId});
}
