import 'dart:developer';

import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:admin_app/UI/public/user/services/auth_api_service.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/public/user/services/profile_api_service.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final CareersUserService _careersUserService;
  final AuthApiService _authApiService;
  final ProfileApiService _profileApiService;

  UserBloc({
    required ApiService apiService,
    required CareersUserService careersUserService,
  })  : _careersUserService = careersUserService,
        _authApiService = AuthApiService(apiService: apiService),
        _profileApiService = ProfileApiService(apiService: apiService),
        super(UserInitial()) {
    // Register event handlers
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdatePreferencesEvent>(_onUpdatePreferences);
    on<UpdatePreferredSchoolsEvent>(_onUpdatePreferredSchools);
    on<UpdateSkillsEvent>(_onUpdateSkills);
    on<CheckLoginStatusEvent>(_onCheckLoginStatus);
    on<ClearUserDataEvent>(_onClearUserData);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ResendVerificationEvent>(_onResendVerification);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<CheckProfileCompletionEvent>(_onCheckProfileCompletion);
    on<GetFullProfileEvent>(_onGetFullProfile);
    on<UpdateProfileDataEvent>(_onUpdateProfileData);
    on<UpdateEducationEvent>(_onUpdateEducation);
    on<UpdateExperienceEvent>(_onUpdateExperience);
    on<UpdateFamilyEvent>(_onUpdateFamily);
    on<UpdateReferencesEvent>(_onUpdateReferences);
    on<UpdateProfessionalProgramsEvent>(_onUpdateProfessionalPrograms);
    on<GetEducationEvent>(_onGetEducation);
    on<GetExperienceEvent>(_onGetExperience);
    on<GetFamilyEvent>(_onGetFamily);
    on<GetReferencesEvent>(_onGetReferences);
    on<GetProfessionalProgramsEvent>(_onGetProfessionalPrograms);
  }

  // Login handler
  Future<void> _onLogin(LoginEvent event, Emitter<UserState> emit) async {
    emit(LoginLoading());

    try {
      log('UserBloc: Attempting login for email: ${event.email}');

      final result = await _authApiService.login(
        email: event.email,
        password: event.password,
      );

      await result.fold(
        (error) async {
          log('UserBloc: Login failed - ${error.message}');
          if (!emit.isDone) {
            emit(LoginError(message: error.message));
          }
        },
        (data) async {
          log('UserBloc: Login successful, creating user model');

          // Create user model from API response
          final userJson = data['user'];
          final sessionToken = data['session_token'];

          // Add session_token to user data
          userJson['session_token'] = sessionToken;

          final user = CareersUserModel.fromJson(userJson);

          // Save user to local storage
          await _careersUserService.setCurrentCareersUser(user);
          await _careersUserService.updateLastLogin();

          log('UserBloc: User saved to local storage with session token');
          if (!emit.isDone) {
            emit(LoginSuccess(user: user));
          }
        },
      );
    } catch (e) {
      log('UserBloc: Unexpected error during login - $e');
      if (!emit.isDone) {
        emit(LoginError(message: 'Login failed: ${e.toString()}'));
      }
    }
  }

  // Signup handler
  Future<void> _onSignup(SignupEvent event, Emitter<UserState> emit) async {
    emit(SignupLoading());

    try {
      log('UserBloc: Attempting signup for email: ${event.email}');

      final result = await _authApiService.signup(
        name: event.name,
        email: event.email,
        phone: event.phone ?? '',
        password: event.password,
        confirmPassword: event.password, // Using same password for confirmation
      );

      await result.fold(
        (error) async {
          log('UserBloc: Signup failed - ${error.message}');
          if (!emit.isDone) {
            emit(SignupError(message: error.message));
          }
        },
        (data) async {
          log('UserBloc: Signup successful, redirecting to login');

          // After registration, redirect to login page (don't store user data)
          if (!emit.isDone) {
            emit(SignupSuccess());
          }
        },
      );
    } catch (e) {
      log('UserBloc: Unexpected error during signup - $e');
      if (!emit.isDone) {
        emit(SignupError(message: 'Signup failed: ${e.toString()}'));
      }
    }
  }

  // Logout handler
  Future<void> _onLogout(LogoutEvent event, Emitter<UserState> emit) async {
    try {
      await _careersUserService.clearCurrentCareersUser();
      emit(LogoutSuccess());
    } catch (e) {
      log('Logout error: $e');
      emit(LogoutError(message: 'Logout failed: ${e.toString()}'));
    }
  }

  // Update profile handler
  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<UserState> emit) async {
    emit(ProfileUpdateLoading());

    try {
      final currentUser = _careersUserService.getCurrentCareersUser();
      if (currentUser == null) {
        emit(ProfileUpdateError(message: 'No user logged in'));
        return;
      }

      final updatedUser = currentUser.copyWith(
        name: event.name,
        email: event.email,
        phone: event.phone,
        profileImage: event.profileImage,
        resumeUrl: event.resumeUrl,
        preferredLocation: event.preferredLocation,
        experienceLevel: event.experienceLevel,
      );

      await _careersUserService.updateCurrentCareersUser(updatedUser);
      emit(ProfileUpdateSuccess(user: updatedUser));
    } catch (e) {
      log('Profile update error: $e');
      emit(ProfileUpdateError(
          message: 'Profile update failed: ${e.toString()}'));
    }
  }

  // Update preferences handler
  Future<void> _onUpdatePreferences(
      UpdatePreferencesEvent event, Emitter<UserState> emit) async {
    emit(PreferencesUpdateLoading());

    try {
      await _careersUserService.updateUserPreferences(event.preferences);
      emit(PreferencesUpdateSuccess(preferences: event.preferences));
    } catch (e) {
      log('Preferences update error: $e');
      emit(PreferencesUpdateError(
          message: 'Preferences update failed: ${e.toString()}'));
    }
  }

  // Update preferred schools handler
  Future<void> _onUpdatePreferredSchools(
      UpdatePreferredSchoolsEvent event, Emitter<UserState> emit) async {
    try {
      await _careersUserService.updatePreferredSchoolIds(event.schoolIds);

      final currentUser = _careersUserService.getCurrentCareersUser();
      if (currentUser != null) {
        final updatedUser =
            currentUser.copyWith(preferredSchoolIds: event.schoolIds);
        await _careersUserService.updateCurrentCareersUser(updatedUser);
        emit(ProfileUpdateSuccess(user: updatedUser));
      }
    } catch (e) {
      log('Preferred schools update error: $e');
      emit(ProfileUpdateError(
          message: 'Preferred schools update failed: ${e.toString()}'));
    }
  }

  // Update skills handler
  Future<void> _onUpdateSkills(
      UpdateSkillsEvent event, Emitter<UserState> emit) async {
    try {
      await _careersUserService.updateUserSkills(event.skills);

      final currentUser = _careersUserService.getCurrentCareersUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(skills: event.skills);
        await _careersUserService.updateCurrentCareersUser(updatedUser);
        emit(ProfileUpdateSuccess(user: updatedUser));
      }
    } catch (e) {
      log('Skills update error: $e');
      emit(
          ProfileUpdateError(message: 'Skills update failed: ${e.toString()}'));
    }
  }

  // Check login status handler
  Future<void> _onCheckLoginStatus(
      CheckLoginStatusEvent event, Emitter<UserState> emit) async {
    try {
      final user = _careersUserService.getCurrentCareersUser();
      if (user != null) {
        emit(UserDataLoaded(user: user, isLoggedIn: true));
      } else {
        emit(UserDataEmpty());
      }
    } catch (e) {
      log('Check login status error: $e');
      emit(UserError(message: 'Failed to check login status: ${e.toString()}'));
    }
  }

  // Clear user data handler
  Future<void> _onClearUserData(
      ClearUserDataEvent event, Emitter<UserState> emit) async {
    try {
      await _careersUserService.clearAllUsers();
      emit(UserDataEmpty());
    } catch (e) {
      log('Clear user data error: $e');
      emit(UserError(message: 'Failed to clear user data: ${e.toString()}'));
    }
  }

  // Forgot password handler
  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<UserState> emit) async {
    emit(ForgotPasswordLoading());

    try {
      log('UserBloc: Attempting forgot password for email: ${event.email}');

      final result = await _authApiService.forgotPassword(email: event.email);

      await result.fold(
        (error) async {
          log('UserBloc: Forgot password failed - ${error.message}');
          if (!emit.isDone) {
            emit(ForgotPasswordError(message: error.message));
          }
        },
        (data) async {
          log('UserBloc: Forgot password successful');
          if (!emit.isDone) {
            emit(ForgotPasswordSuccess(
                message: 'Password reset link sent to your email'));
          }
        },
      );
    } catch (e) {
      log('UserBloc: Unexpected error during forgot password - $e');
      if (!emit.isDone) {
        emit(ForgotPasswordError(
            message: 'Failed to send reset link: ${e.toString()}'));
      }
    }
  }

  // Reset password handler
  Future<void> _onResetPassword(
      ResetPasswordEvent event, Emitter<UserState> emit) async {
    emit(ResetPasswordLoading());

    try {
      log('UserBloc: Attempting password reset');

      final result = await _authApiService.resetPassword(
        token: event.token,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );

      await result.fold(
        (error) async {
          log('UserBloc: Reset password failed - ${error.message}');
          if (!emit.isDone) {
            emit(ResetPasswordError(message: error.message));
          }
        },
        (data) async {
          log('UserBloc: Reset password successful');
          if (!emit.isDone) {
            emit(ResetPasswordSuccess(
                message: 'Password has been reset successfully'));
          }
        },
      );
    } catch (e) {
      log('UserBloc: Unexpected error during reset password - $e');
      if (!emit.isDone) {
        emit(ResetPasswordError(
            message: 'Failed to reset password: ${e.toString()}'));
      }
    }
  }

  // Resend verification handler
  Future<void> _onResendVerification(
      ResendVerificationEvent event, Emitter<UserState> emit) async {
    emit(ResendVerificationLoading());

    try {
      log('UserBloc: Attempting to resend verification for email: ${event.email}');

      final result =
          await _authApiService.resendVerification(email: event.email);

      await result.fold(
        (error) async {
          log('UserBloc: Resend verification failed - ${error.message}');
          if (!emit.isDone) {
            emit(ResendVerificationError(message: error.message));
          }
        },
        (data) async {
          log('UserBloc: Resend verification successful');
          if (!emit.isDone) {
            emit(ResendVerificationSuccess(
                message: 'Verification email sent to your inbox'));
          }
        },
      );
    } catch (e) {
      log('UserBloc: Unexpected error during resend verification - $e');
      if (!emit.isDone) {
        emit(ResendVerificationError(
            message: 'Failed to resend verification: ${e.toString()}'));
      }
    }
  }

  // Verify email handler
  Future<void> _onVerifyEmail(
      VerifyEmailEvent event, Emitter<UserState> emit) async {
    emit(VerifyEmailLoading());

    try {
      log('UserBloc: Attempting email verification');

      final result = await _authApiService.verifyEmail(token: event.token);

      await result.fold(
        (error) async {
          log('UserBloc: Email verification failed - ${error.message}');
          if (!emit.isDone) {
            emit(VerifyEmailError(message: error.message));
          }
        },
        (data) async {
          log('UserBloc: Email verification successful');

          // Update user's email verification status
          final currentUser = _careersUserService.getCurrentCareersUser();
          if (currentUser != null) {
            final updatedUser = currentUser.copyWith(isEmailVerified: true);
            await _careersUserService.updateCurrentCareersUser(updatedUser);
          }

          if (!emit.isDone) {
            emit(VerifyEmailSuccess(
                message: 'Email has been verified successfully'));
          }
        },
      );
    } catch (e) {
      log('UserBloc: Unexpected error during email verification - $e');
      if (!emit.isDone) {
        emit(VerifyEmailError(
            message: 'Failed to verify email: ${e.toString()}'));
      }
    }
  }

  // Check profile completion handler
  Future<void> _onCheckProfileCompletion(
      CheckProfileCompletionEvent event, Emitter<UserState> emit) async {
    emit(ProfileCompletionLoading());

    try {
      log('UserBloc: Checking profile completion for candidate: ${event.candidateId}');

      final result = await _authApiService.getProfileCompletion(
        candidateId: event.candidateId,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );

      await result.fold(
        (error) async {
          log('UserBloc: Profile completion check failed - ${error.message}');
          if (!emit.isDone) {
            emit(ProfileCompletionError(message: error.message));
          }
        },
        (profileCompletion) async {
          log('UserBloc: Profile completion check successful');
          if (!emit.isDone) {
            emit(
                ProfileCompletionSuccess(profileCompletion: profileCompletion));
          }
        },
      );
    } catch (e) {
      log('UserBloc: Unexpected error during profile completion check - $e');
      if (!emit.isDone) {
        emit(ProfileCompletionError(
            message: 'Profile completion check failed: ${e.toString()}'));
      }
    }
  }

  // Get full profile handler
  Future<void> _onGetFullProfile(
      GetFullProfileEvent event, Emitter<UserState> emit) async {
    emit(FullProfileLoading());
    try {
      final result = await _profileApiService.getProfile(
        candidateId: event.candidateId,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(FullProfileError(message: error.message)),
        (profile) async => emit(FullProfileSuccess(profile: profile)),
      );
    } catch (e) {
      emit(FullProfileError(message: e.toString()));
    }
  }

  // Update profile data handler
  Future<void> _onUpdateProfileData(
      UpdateProfileDataEvent event, Emitter<UserState> emit) async {
    emit(ProfileDataUpdateLoading());
    try {
      final result = await _profileApiService.updateProfile(
        candidateId: event.candidateId,
        profileData: event.profileData,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(ProfileDataUpdateError(message: error.message)),
        (data) async => emit(ProfileDataUpdateSuccess(data: data)),
      );
    } catch (e) {
      emit(ProfileDataUpdateError(message: e.toString()));
    }
  }

  // Update education handler
  Future<void> _onUpdateEducation(
      UpdateEducationEvent event, Emitter<UserState> emit) async {
    emit(EducationUpdateLoading());
    try {
      final result = await _profileApiService.updateEducation(
        candidateId: event.candidateId,
        educationRecords: event.educationRecords,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(EducationUpdateError(message: error.message)),
        (data) async => emit(EducationUpdateSuccess(data: data)),
      );
    } catch (e) {
      emit(EducationUpdateError(message: e.toString()));
    }
  }

  // Update experience handler
  Future<void> _onUpdateExperience(
      UpdateExperienceEvent event, Emitter<UserState> emit) async {
    emit(ExperienceUpdateLoading());
    try {
      final result = await _profileApiService.updateExperience(
        candidateId: event.candidateId,
        experienceRecords: event.experienceRecords,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(ExperienceUpdateError(message: error.message)),
        (data) async => emit(ExperienceUpdateSuccess(data: data)),
      );
    } catch (e) {
      emit(ExperienceUpdateError(message: e.toString()));
    }
  }

  // Update family handler
  Future<void> _onUpdateFamily(
      UpdateFamilyEvent event, Emitter<UserState> emit) async {
    emit(FamilyUpdateLoading());
    try {
      final result = await _profileApiService.updateFamily(
        candidateId: event.candidateId,
        familyMembers: event.familyMembers,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(FamilyUpdateError(message: error.message)),
        (data) async => emit(FamilyUpdateSuccess(data: data)),
      );
    } catch (e) {
      emit(FamilyUpdateError(message: e.toString()));
    }
  }

  // Update references handler
  Future<void> _onUpdateReferences(
      UpdateReferencesEvent event, Emitter<UserState> emit) async {
    emit(ReferencesUpdateLoading());
    try {
      final result = await _profileApiService.updateReferences(
        candidateId: event.candidateId,
        references: event.references,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(ReferencesUpdateError(message: error.message)),
        (data) async => emit(ReferencesUpdateSuccess(data: data)),
      );
    } catch (e) {
      emit(ReferencesUpdateError(message: e.toString()));
    }
  }

  // Update professional programs handler
  Future<void> _onUpdateProfessionalPrograms(
      UpdateProfessionalProgramsEvent event, Emitter<UserState> emit) async {
    emit(ProfessionalProgramsUpdateLoading());
    try {
      final result = await _profileApiService.updateProfessionalPrograms(
        candidateId: event.candidateId,
        programs: event.programs,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async =>
            emit(ProfessionalProgramsUpdateError(message: error.message)),
        (data) async => emit(ProfessionalProgramsUpdateSuccess(data: data)),
      );
    } catch (e) {
      emit(ProfessionalProgramsUpdateError(message: e.toString()));
    }
  }

  // Get education handler
  Future<void> _onGetEducation(
      GetEducationEvent event, Emitter<UserState> emit) async {
    emit(EducationLoading());
    try {
      final result = await _profileApiService.getEducation(
        candidateId: event.candidateId,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(EducationError(message: error.message)),
        (records) async => emit(EducationLoaded(educationRecords: records)),
      );
    } catch (e) {
      emit(EducationError(message: e.toString()));
    }
  }

  // Get experience handler
  Future<void> _onGetExperience(
      GetExperienceEvent event, Emitter<UserState> emit) async {
    emit(ExperienceLoading());
    try {
      final result = await _profileApiService.getExperience(
        candidateId: event.candidateId,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(ExperienceError(message: error.message)),
        (records) async => emit(ExperienceLoaded(experienceRecords: records)),
      );
    } catch (e) {
      emit(ExperienceError(message: e.toString()));
    }
  }

  // Get family handler
  Future<void> _onGetFamily(
      GetFamilyEvent event, Emitter<UserState> emit) async {
    emit(FamilyLoading());
    try {
      final result = await _profileApiService.getFamily(
        candidateId: event.candidateId,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(FamilyError(message: error.message)),
        (members) async => emit(FamilyLoaded(familyMembers: members)),
      );
    } catch (e) {
      emit(FamilyError(message: e.toString()));
    }
  }

  // Get references handler
  Future<void> _onGetReferences(
      GetReferencesEvent event, Emitter<UserState> emit) async {
    emit(ReferencesLoading());
    try {
      final result = await _profileApiService.getReferences(
        candidateId: event.candidateId,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async => emit(ReferencesError(message: error.message)),
        (references) async => emit(ReferencesLoaded(references: references)),
      );
    } catch (e) {
      emit(ReferencesError(message: e.toString()));
    }
  }

  // Get professional programs handler
  Future<void> _onGetProfessionalPrograms(
      GetProfessionalProgramsEvent event, Emitter<UserState> emit) async {
    emit(ProfessionalProgramsLoading());
    try {
      final result = await _profileApiService.getProfessionalPrograms(
        candidateId: event.candidateId,
        token: _careersUserService.getCurrentCareersUser()?.sessionToken,
      );
      await result.fold(
        (error) async =>
            emit(ProfessionalProgramsError(message: error.message)),
        (programs) async =>
            emit(ProfessionalProgramsLoaded(programs: programs)),
      );
    } catch (e) {
      emit(ProfessionalProgramsError(message: e.toString()));
    }
  }
}
