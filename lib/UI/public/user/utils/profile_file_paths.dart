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
      final nested = Map<String, dynamic>.from(candidate);
      // GET /get-profile sometimes puts scalar flags on `data` while file
      // fields live under `data.candidate`. Fill any keys the nested map
      // does not already have.
      data.forEach((key, value) {
        if (key == 'candidate') return;
        if (!_hasValue(nested[key]) && _hasValue(value)) {
          nested[key] = value;
        }
      });
      return nested;
    }

    if (data.containsKey('avatar_file') ||
        data.containsKey('cv_file') ||
        data.containsKey('profile_image') ||
        data.containsKey('photo') ||
        data.containsKey('profile_photo') ||
        data.containsKey('candidate_id') ||
        data.containsKey('candidate_name') ||
        data.containsKey('name')) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  static String? extractAvatarPath(Map<String, dynamic> map) {
    for (final key in [
      'avatar_file',
      'profile_image',
      'avatar',
      'photo',
      'profile_photo',
    ]) {
      final value = _fileValue(map[key]);
      if (value != null) return value;
    }
    return null;
  }

  static String? _fileValue(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return _fileValue(
        value['path'] ??
            value['url'] ??
            value['file'] ??
            value['avatar_file'] ??
            value['photo'] ??
            value['src'],
      );
    }
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '0') return null;
    return text;
  }

  static String? extractCvPath(Map<String, dynamic> map) {
    for (final key in ['cv_file', 'resume_url', 'cv', 'resume']) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Fills missing CV / available-from values from the Hive session when
  /// get-profile omits them. Avatar is never filled from cache — it must
  /// come from the server.
  static ProfileModel mergeWithCachedFiles(ProfileModel profile) {
    final cached = CareersUserManager.getCurrentUser();
    final prefs = cached?.preferences ?? const {};

    return profile.copyWith(
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
