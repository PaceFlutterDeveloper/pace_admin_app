/// HTTPS and custom-scheme URLs used when sharing a job post.
class JobShareLinks {
  static const String httpsHost = 'paceeducation.com';
  static const String httpsPathPrefix = '/careers/jobs';
  static const String customScheme = 'paceerp';
  static const String customHost = 'jobs';

  static String httpsUrl(int jobId) =>
      'https://$httpsHost$httpsPathPrefix/$jobId';

  /// Parses `https://paceeducation.com/careers/jobs/{id}` and
  /// `paceerp://jobs/{id}` (plus path variants). Returns null for unrelated URIs.
  static int? jobIdFromUri(Uri uri) {
    if (uri.scheme == customScheme) {
      if (uri.host == customHost) {
        if (uri.pathSegments.isEmpty) return null;
        return int.tryParse(uri.pathSegments.first);
      }
      return _idAfterJobsSegment(uri.pathSegments);
    }

    if (uri.scheme == 'https' || uri.scheme == 'http') {
      final host = uri.host.toLowerCase();
      if (host != httpsHost && host != 'www.$httpsHost') return null;
      final segments = uri.pathSegments;
      for (var i = 0; i + 2 < segments.length; i++) {
        if (segments[i] == 'careers' && segments[i + 1] == 'jobs') {
          return int.tryParse(segments[i + 2]);
        }
      }
    }

    return null;
  }

  static int? _idAfterJobsSegment(List<String> segments) {
    final jobsIndex = segments.lastIndexOf(customHost);
    if (jobsIndex < 0 || jobsIndex + 1 >= segments.length) return null;
    return int.tryParse(segments[jobsIndex + 1]);
  }
}
