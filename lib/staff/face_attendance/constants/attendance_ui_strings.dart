/// User-facing copy for mark-attendance (single source of truth for this feature).
abstract final class AttendanceUiStrings {
  static const submitCouldNotSaveLead = 'Attendance could not be saved.';

  /// Server returned 404 for the mark-attendance request (endpoint missing / not rolled out).
  static const submitEndpointNotFound =
      'Attendance could not be saved. The attendance service is not available yet, '
      'or your app may need an update. Please try again later or contact support.';

  static const submitNetworkIssue =
      'Attendance could not be saved. Check your internet connection and try again.';

  static const submitServerIssue =
      'Attendance could not be saved. The server is temporarily unavailable. '
      'Please try again in a few minutes.';

  /// Non-auth 4xx after capture (validation, conflict, etc.).
  static const submitRequestNotAccepted =
      'Attendance could not be saved. Please try again or contact support.';
}
