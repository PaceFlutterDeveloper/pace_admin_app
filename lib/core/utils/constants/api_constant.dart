import 'package:hive/hive.dart';

class ApiConstants {
  // Method to get the current school code dynamically from Hive
  static Future<String> getSchoolCode() async {
    var box = await Hive.openBox('settingsBox');
    String? schoolCode =
        box.get('schoolCode'); // Retrieve the selected school code
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
  // AUTHENTICATION ENDPOINTS
  // ========================================

  // User Authentication Endpoints
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
  // STATIC ENDPOINTS (No school code needed)
  // ========================================

  // Static authentication endpoints (for public access)
  static const String authLoginUrl =
      "https://paceeducation.com/careers/erp-api/auth-login.php";
  static const String authRegisterUrl =
      "https://paceeducation.com/careers/erp-api/auth-register.php";
  static const String authForgotPasswordUrl =
      "https://paceeducation.com/careers/erp-api/auth-forgot-password.php";
  static const String authResetPasswordUrl =
      "https://paceeducation.com/careers/erp-api/auth-reset-password.php";
  static const String authResendVerificationUrl =
      "https://paceeducation.com/careers/erp-api/auth-resend-verification.php";
  static const String authVerifyEmailUrl =
      "https://paceeducation.com/careers/erp-api/auth-verify-email.php";

  // Static jobs endpoints (for public access)
  static const String jobsUrl =
      "https://paceeducation.com/careers/erp-api/jobs.php";
  static const String jobDetailsUrl =
      "https://paceeducation.com/careers/erp-api/job-details.php";

  static const String schoolsUrl =
      "https://paceeducation.com/careers/erp-api/schools.php";
  static const String countriesUrl =
      "https://paceeducation.com/careers/erp-api/countries.php";
  static const String testUrl =
      "https://paceeducation.com/careers/erp-api/test.php";
  static const String profileCompletionUrl =
      "https://paceeducation.com/careers/erp-api/index.php/profile-completion";
  static const String myApplicationsUrl =
      "https://paceeducation.com/careers/erp-api/index.php/my-applications";

  // Static profile endpoints (for public access)
  static const String profileUrl =
      "https://paceeducation.com/careers/erp-api/index.php/get-profile";
  static const String updateProfileUrl =
      "https://paceeducation.com/careers/erp-api/index.php/update-profile";
  static const String updateEducationUrl =
      "https://paceeducation.com/careers/erp-api/index.php/update-education";
  static const String updateExperienceUrl =
      "https://paceeducation.com/careers/erp-api/index.php/update-experience";
  static const String updateFamilyUrl =
      "https://paceeducation.com/careers/erp-api/index.php/update-family";
  static const String updateReferencesUrl =
      "https://paceeducation.com/careers/erp-api/index.php/update-references";
  static const String updateProfessionalProgramsUrl =
      "https://paceeducation.com/careers/erp-api/index.php/update-professional-programs";
  static const String updateCompleteProfileUrl =
      "https://paceeducation.com/careers/erp-api/index.php/update-complete-profile";

  // GET endpoints for fetching profile data
  static const String getEducationUrl =
      "https://paceeducation.com/careers/erp-api/index.php/get-education";
  static const String getExperienceUrl =
      "https://paceeducation.com/careers/erp-api/index.php/get-experience";
  static const String getFamilyUrl =
      "https://paceeducation.com/careers/erp-api/index.php/get-family";
  static const String getReferencesUrl =
      "https://paceeducation.com/careers/erp-api/index.php/get-references";
  static const String getProfessionalProgramsUrl =
      "https://paceeducation.com/careers/erp-api/index.php/get-professional-programs";
}
