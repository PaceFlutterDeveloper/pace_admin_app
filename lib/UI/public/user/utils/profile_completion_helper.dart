import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';

class ProfileCompletionHelper {
  /// Determines if the user should be navigated to complete profile page
  /// Returns true if profile is not complete or user cannot apply
  static bool shouldNavigateToCompleteProfile(
      ProfileCompletionModel profileCompletion) {
    return !profileCompletion.isComplete || !profileCompletion.canApply;
  }

  /// Gets a user-friendly message about profile completion status
  static String getProfileCompletionMessage(
      ProfileCompletionModel profileCompletion) {
    if (profileCompletion.isComplete && profileCompletion.canApply) {
      return 'Your profile is complete and you can apply for jobs!';
    } else if (profileCompletion.isComplete && !profileCompletion.canApply) {
      return 'Your profile is complete but you cannot apply yet. Please contact support.';
    } else {
      return 'Please complete your profile to apply for jobs. ${profileCompletion.percentage}% complete.';
    }
  }

  /// Gets the completion percentage for display
  static int getCompletionPercentage(ProfileCompletionModel profileCompletion) {
    return profileCompletion.percentage;
  }

  /// Checks if the user can apply for jobs
  static bool canApplyForJobs(ProfileCompletionModel profileCompletion) {
    return profileCompletion.canApply;
  }

  /// Checks if the profile is complete
  static bool isProfileComplete(ProfileCompletionModel profileCompletion) {
    return profileCompletion.isComplete;
  }

  /// Gets the list of missing fields for display
  static List<String> getMissingFields(
      ProfileCompletionModel profileCompletion) {
    return profileCompletion.missingFields;
  }
}
