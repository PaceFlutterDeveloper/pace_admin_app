import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/utils/careers_api_dates.dart';

/// Normalizes careers API file fields (`avatar_file`, `cv_file`, etc.)
/// across upload and get-profile responses.
class ProfileFilePaths {
  ProfileFilePaths._();

  static Map<String, dynamic> normalizeUploadData(Map<String, dynamic> raw) {
    final data = Map<String, dynamic>.from(raw);
    final candidate = extractCandidateMap(data) ?? <String, dynamic>{};

    final avatar = extractAvatarPath(data) ?? extractAvatarPath(candidate);
    final cv = extractCvPath(data) ?? extractCvPath(candidate);

    if (avatar != null && !_hasValue(candidate['avatar_file'])) {
      candidate['avatar_file'] = avatar;
    }
    if (cv != null && !_hasValue(candidate['cv_file'])) {
      candidate['cv_file'] = cv;
    }

    return {...data, 'candidate': candidate};
  }

  static Map<String, dynamic>? extractCandidateMap(Map<String, dynamic>? data) {
    if (data == null) return null;

    final candidate = data['candidate'];
    if (candidate is Map) {
      return Map<String, dynamic>.from(candidate);
    }

    if (data.containsKey('avatar_file') ||
        data.containsKey('cv_file') ||
        data.containsKey('profile_image') ||
        data.containsKey('candidate_name') ||
        data.containsKey('name')) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  static String? extractAvatarPath(Map<String, dynamic> map) {
    for (final key in ['avatar_file', 'profile_image', 'avatar']) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? extractCvPath(Map<String, dynamic> map) {
    for (final key in ['cv_file', 'resume_url', 'cv', 'resume']) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Fills missing avatar/CV paths from the Hive session cache when get-profile
  /// omits them after a successful upload.
  static ProfileModel mergeWithCachedFiles(ProfileModel profile) {
    final cached = CareersUserManager.getCurrentUser();
    final prefs = cached?.preferences ?? const {};

    return profile.copyWith(
      avatarFile: _nonEmpty(profile.avatarFile) ?? _nonEmpty(cached?.profileImage),
      cvFile: _nonEmpty(profile.cvFile) ?? _nonEmpty(cached?.resumeUrl),
      availableFrom: _nonEmpty(profile.availableFrom) ??
          CareersApiDates.normalizeFromApi(prefs['available_from']),
    );
  }

  static bool hasAvatarPath(Map<String, dynamic>? data) {
    if (data == null) return false;
    final candidate = extractCandidateMap(data);
    if (candidate != null && _hasValue(extractAvatarPath(candidate))) {
      return true;
    }
    return _hasValue(extractAvatarPath(data));
  }

  static bool _hasValue(dynamic value) {
    return value != null && value.toString().trim().isNotEmpty;
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}
