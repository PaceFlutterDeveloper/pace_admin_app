import 'package:hive/hive.dart';

class ApiConstants {
  // Method to get the current school code dynamically from Hive
  static Future<String> getSchoolCode() async {
    var box = await Hive.openBox('settingsBox');
    String? schoolCode = box.get(
      'schoolCode',
    ); // Retrieve the selected school code
    return schoolCode ??
        'defaultSchool'; // Provide a default school code if none selected
  }

  // Base URL with dynamic school code replacing 'demo'
  static Future<String> getBaseUrl() async {
    String schoolCode = await getSchoolCode();
    return "https://$schoolCode.paceeducation.com/erp-api/";
  }

  // API Endpoints with dynamic school code
  static Future<String> getLoginUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=login";
  }

  // API Endpoints with dynamic school code
  static Future<String> getNotifications() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=manageNotification";
  }

  static Future<String> adminNotifications() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=manageNotification";
  }

  // API Endpoints for getting attendance
  static Future<String> getAttendance() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=userAttendance";
  }

  // API Endpoints for getting menu
  static Future<String> getUserMenu() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=userMenu";
  }

  // API Endpoints for getting employee profile
  static Future<String> getEmpProfile() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=userProfile";
  }

  // API Endpoints for getting classAttendance
  static Future<String> getclassAttendance() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=classAttendance";
  }

  // API Endpoints for getting classAttendance
  static Future<String> getManageTickets() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=manageTickets";
  }

  static Future<String> getTickets() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=tickets";
  }

  static Future<String> logout() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}index.php?page=logout";
  }

  static Future<String> nfcMappy() async {
    String schoolCode = await getSchoolCode();
    return "https://paceeducation.com/website/transport/${schoolCode}/index.php?";
  }

  // ========================================
  // LEGACY SCHOOL-SCOPED CAREERS ENDPOINTS
  // Deprecated — use Careers API v2 static URLs below (careersEndpoint).
  // ========================================

  // User Authentication Endpoints
  @Deprecated('Use ApiConstants.authLoginUrl (Careers API v2)')
  static Future<String> getAuthLoginUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}auth-login.php";
  }

  static Future<String> getAuthRegisterUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}auth-register.php";
  }

  static Future<String> getAuthForgotPasswordUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}auth-forgot-password.php";
  }

  static Future<String> getAuthResetPasswordUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}auth-reset-password.php";
  }

  static Future<String> getAuthResendVerificationUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}auth-resend-verification.php";
  }

  static Future<String> getAuthVerifyEmailUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}auth-verify-email.php";
  }

  // ========================================
  // PROFILE MANAGEMENT ENDPOINTS
  // ========================================

  static Future<String> getProfileUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}get-profile.php";
  }

  static Future<String> getUpdateProfileUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}update-profile.php";
  }

  static Future<String> getUpdateEducationUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}update-education.php";
  }

  static Future<String> getUpdateExperienceUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}update-experience.php";
  }

  static Future<String> getUpdateFamilyUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}update-family.php";
  }

  static Future<String> getUpdateReferencesUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}update-references.php";
  }

  static Future<String> getUpdateProfessionalProgramsUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}update-professional-programs.php";
  }

  static Future<String> getUpdateCompleteProfileUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}update-complete-profile.php";
  }

  // ========================================
  // JOBS & CAREERS ENDPOINTS
  // ========================================

  // Job Listing Endpoints
  static Future<String> getJobsUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}jobs.php";
  }

  static Future<String> getJobDetailsUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}job-details.php";
  }

  static Future<String> getJobsSimpleUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}jobs-simple.php";
  }

  // Schools and Countries Endpoints
  static Future<String> getSchoolsUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}schools.php";
  }

  static Future<String> getCountriesUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}countries.php";
  }

  // Test and Debug Endpoints
  static Future<String> getTestUrl() async {
    String baseUrl = await getBaseUrl();
    return "${baseUrl}test.php";
  }

  // ========================================
  // CAREERS API v2 (unified router)
  // ========================================

  /// Base URL for careers media files returned as relative paths
  /// (e.g. `uploads/profile_photos/cand_123.jpg`).
  static const String careersMediaBaseUrl =
      'https://paceeducation.com/careers/';

  /// Single router entry point for all careers API v2 endpoints.
  static const String careersApiBaseUrl =
      'https://paceeducation.com/careers/erp-api/index.php';

  static String careersEndpoint(String path) =>
      '$careersApiBaseUrl/${path.startsWith('/') ? path.substring(1) : path}';

  // Authentication endpoints (public)
  static final String authLoginUrl = careersEndpoint('auth-login');
  static final String authRegisterUrl = careersEndpoint('auth-register');
  static final String authForgotPasswordUrl =
      careersEndpoint('auth-forgot-password');
  static final String authResetPasswordUrl =
      careersEndpoint('auth-reset-password');
  static final String authResendVerificationUrl =
      careersEndpoint('auth-resend-verification');
  static final String authVerifyEmailUrl = careersEndpoint('auth-verify-email');

  // Jobs endpoints (public)
  static final String jobsUrl = careersEndpoint('jobs');
  static final String jobDetailsUrl = careersEndpoint('job-details');
  static final String schoolsUrl = careersEndpoint('schools');
  static final String countriesUrl = careersEndpoint('countries');
  static final String startupUrl = careersEndpoint('startup');

  // Application endpoints
  static final String checkApplicationUrl =
      careersEndpoint('check-application');
  static final String applyJobUrl = careersEndpoint('apply-job');
  static final String myApplicationsUrl = careersEndpoint('my-applications');

  // Profile endpoints (protected)
  static final String profileCompletionUrl =
      careersEndpoint('profile-completion');
  static final String profileUrl = careersEndpoint('get-profile');
  static final String updateProfileUrl = careersEndpoint('update-profile');
  static final String updateEducationUrl = careersEndpoint('update-education');
  static final String updateExperienceUrl =
      careersEndpoint('update-experience');
  static final String updateFamilyUrl = careersEndpoint('update-family');
  static final String updateReferencesUrl = careersEndpoint('update-references');
  static final String updateProfessionalProgramsUrl =
      careersEndpoint('update-professional-programs');
  static final String updateCompleteProfileUrl =
      careersEndpoint('update-complete-profile');
  static final String getEducationUrl = careersEndpoint('get-education');
  static final String getExperienceUrl = careersEndpoint('get-experience');
  static final String getFamilyUrl = careersEndpoint('get-family');
  static final String getReferencesUrl = careersEndpoint('get-references');
  static final String getProfessionalProgramsUrl =
      careersEndpoint('get-professional-programs');
}
