import 'package:admin_app/UI/public/notification/careers_fcm_service.dart';
import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class CareersUserManager {
  static final CareersUserService _careersUserService =
      GetIt.instance<CareersUserService>();

  /// Set when someone continues as a guest during this process.
  /// A saved candidate stays signed in across launches until they sign out.
  /// A fresh launch shows the login page only when nobody is saved.
  static bool browsingAsGuest = false;

  /// Bumped when login or guest mode should reveal the jobs home tab.
  static final ValueNotifier<int> homeTabRequest = ValueNotifier(0);

  static void openHomeTab() {
    homeTabRequest.value++;
  }

  // Get current careers user
  static CareersUserModel? getCurrentUser() {
    return _careersUserService.getCurrentCareersUser();
  }

  // Login careers user
  static Future<void> loginUser(CareersUserModel user) async {
    await _careersUserService.setCurrentCareersUser(user);
    await _careersUserService.updateLastLogin();
  }

  /// Clears the local session and unsubscribes this device from FCM topics.
  /// Used by both explicit logout and session-expiry handling.
  static Future<void> logoutUser() async {
    await Future.wait([
      CareersFcmService.unsubscribeForCurrentUser(),
      _careersUserService.clearCurrentCareersUser(),
    ]);
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _careersUserService.isCareersUserLoggedIn();
  }

  // Update user profile
  static Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? resumeUrl,
    List<String>? skills,
    String? preferredLocation,
    String? experienceLevel,
  }) async {
    final currentUser = getCurrentUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        phone: phone,
        profileImage: profileImage,
        resumeUrl: resumeUrl,
        skills: skills,
        preferredLocation: preferredLocation,
        experienceLevel: experienceLevel,
      );
      await _careersUserService.updateCurrentCareersUser(updatedUser);
    }
  }

  // Update user preferences
  static Future<void> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    await _careersUserService.updateUserPreferences(preferences);
  }

  // Update preferred schools
  static Future<void> updatePreferredSchools(List<int> schoolIds) async {
    await _careersUserService.updatePreferredSchoolIds(schoolIds);
  }

  // Update user skills
  static Future<void> updateSkills(List<String> skills) async {
    await _careersUserService.updateUserSkills(skills);
  }

  // Get user preferences
  static Map<String, dynamic> getPreferences() {
    return _careersUserService.getUserPreferences();
  }

  // Get preferred school IDs
  static List<int> getPreferredSchoolIds() {
    return _careersUserService.getPreferredSchoolIds();
  }

  // Get user skills
  static List<String> getSkills() {
    return _careersUserService.getUserSkills();
  }

  // Create a new careers user from API response
  static CareersUserModel createUserFromApiResponse(Map<String, dynamic> data) {
    return CareersUserModel.fromJson(data);
  }

  // Get user display name
  static String getDisplayName() {
    final user = getCurrentUser();
    return user?.name ?? 'Guest User';
  }

  // Get user email
  static String getEmail() {
    final user = getCurrentUser();
    return user?.email ?? '';
  }

  // Get user profile image
  static String? getProfileImage() {
    final user = getCurrentUser();
    return user?.profileImage;
  }

  // Check if user has resume
  static bool hasResume() {
    final user = getCurrentUser();
    return user?.resumeUrl != null && user!.resumeUrl!.isNotEmpty;
  }

  // Get resume URL
  static String? getResumeUrl() {
    final user = getCurrentUser();
    return user?.resumeUrl;
  }
}
